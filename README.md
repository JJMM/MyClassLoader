# MyClassLoader
- +load方法替代工具（解决+load滥用导致启动时间超长问题）<br>
- Swift pod工程类似+load方法的调用方式（Swift没有+load，难以实现注册模式）<br>
- 建议所有用到+load方法的库，都使用MyClassLoader替换

## 背景
Objective-C的+Load方法设计的天然缺陷和开发者的滥用，导致系统启动时间大大增加，原来请参考pre-main过程<br>
Swift语言抛弃+Load，连苹果自身都认为+Load方法不应该存在，其他现代语言基本也没有+Load这种特性<br>
结论：+Load不应该使用<br>
不用+Load解决方案：目前pod库组件化解耦基本都是在+Load里注册，统一调用，MyClassLoader提供类似+Load的调用能力，调用时机由开发者控制，建议在开屏广告、介绍引导页面调用<br>

## 如何开始

### Podfile
推荐此方式
```
pod "MyClassLoader"
```
### 源码
源代码只有4个文件，直接放到子工程、子pod库中也可以

## 使用介绍
参照Example工程，实现MyClassLoader的任意Category类方法，在开屏广告、引导页面（系统闪屏后的第一个页面）调用MyClassLoaderInvoker callDefaultClassLoader方法即可

###调用方式
```objective-c
[MyClassLoaderInvoker callDefaultClassLoader];
```

###实现的类方法
```objective-c
@implementation MyClassLoader(Test0)

+ (void)classLoader0 {
    NSLog(@"TestFile0 classLoader0");
}

+ (void)classLoader1 {
    NSLog(@"TestFile0 classLoader1");
}

@end
```

###支持特性
- Category类方法任意取名，可以带业务含义
- Category类方法可以重名，但必须实现在不同的Category中才行，如MyClassLoader(Test0)、MyClassLoader(Test1)两个Category都实现了classLoader0方法，都被调用了
- Category类调用的顺序可在编译文件添加的顺序中修改，后添加的先调用，同一Category类中的方法名按照自上而下的顺序调用
- MyClassLoader是默认类加载器，支持自定义类型
- Swift语言是默认类加载器，支持自定义类型
- 系统的类方法load和initialize由系统调用，MyClassLoader不会重复调用

## 思路以及原理介绍，感兴趣的可以看
想法是替换+load，实现个可控的自定义的方式调用，大体经过如下几次尝试摸索

第一次尝试，想到的思路是找下runtime中+load源码，照着源码把+load换个方法，+load源码如下：

```objective-c
__private_extern__ const char *
load_images(enum dyld_image_states state, uint32_t infoCount,
            const struct dyld_image_info infoList[])
{
    BOOL found;

    recursive_mutex_lock(&loadMethodLock);

    // Discover load methods
    rwlock_write(&runtimeLock);
    found = load_images_nolock(state, infoCount, infoList);
    rwlock_unlock_write(&runtimeLock);

    // Call +load methods (without runtimeLock - re-entrant)
    if (found) {
        call_load_methods();
    }

    recursive_mutex_unlock(&loadMethodLock);

    return NULL;
}
```
```objective-c
__private_extern__ BOOL 
load_images_nolock(enum dyld_image_states state,uint32_t infoCount,
                   const struct dyld_image_info infoList[])
{
    BOOL found = NO;
    uint32_t i;

    i = infoCount;
    while (i--) {
        header_info *hi;
        for (hi = FirstHeader; hi != NULL; hi = hi->next) {
            const headerType *mhdr = (headerType*)infoList[i].imageLoadAddress;
            if (hi->mhdr == mhdr) {
                prepare_load_methods(hi);
                found = YES;
            }
        }
    }

    return found;
}
```
```objective-c
__private_extern__ void prepare_load_methods(header_info *hi)
{
    size_t count, i;

    rwlock_assert_writing(&runtimeLock);

    class_t **classlist = 
        _getObjc2NonlazyClassList(hi, &count);
    for (i = 0; i < count; i++) {
        class_t *cls = remapClass(classlist[i]);
        schedule_class_load(cls);
    }

    category_t **categorylist = _getObjc2NonlazyCategoryList(hi, &count);
    for (i = 0; i < count; i++) {
        category_t *cat = categorylist[i];
        // Do NOT use cat->cls! It may have been remapped.
        class_t *cls = remapClass(cat->cls);
        realizeClass(cls);
        assert(isRealized(cls->isa));
        add_category_to_loadable_list((Category)cat);
    }
}
```
比较复杂，并且使用了大量私有方法，无法抄作业，换个思路自己实现

第二次尝试，思路是获取所有Class的列表，遍历，调用指定的类方法

```objective-c
- (void)findAllClass{
	int numClasses;
    Class * classes = NULL;
	numClasses = objc_getClassList(NULL, 0);
	if (numClasses > 0 ) {
	classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
	numClasses = objc_getClassList(classes, numClasses);
	for (int i = 0; i < numClasses; i++) {
		Class class = classes[i];
		const char *className = class_getName(class);
		NSLog(@"class name = %s", className);
	}
	free(classes);
}
```
这个方式是可以实现的，但是看时间复杂度，性能估计有问题，经过测试，项目中有24000+个类，6核Mac pro上objc_getClassList方法执行需要100毫秒左右，性能太低，此路不通。插个题外话，runtime中的+load无法测试，但原理也是遍历，时间应该和objc_getClassList相近，由此也可以看出+load设计是多么的不科学

第三次尝试，大量查找rumtime源码，试图找到高效的类查找过程，无果。换个思路，objc_getClassList获取的是整数，既然是整数，那么首次调用时将整数缓存下来，下次就不需要这个时间了，遍历过程约5毫秒，还是可以接受的，尝试后运行没问题，但是考虑系统升级，通过rumtime方式动态追加类和方法，还是不够完美，无法做到通用

第四次尝试，思路被卡了很久，重新翻出来rumtime源码，所有的方法和结构体都过了一遍，最后锁定在类结构的methodLists成员上

```objective-c
struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
```

methodLists结构存储了类的所有的方法，Category是一种非常灵活的添加方法的方式，两者结合就能满足我们的需求，不同的Category还可以支持同名方法，可以实现+load效果，但问题是Category同名时，只会调用编译顺序最后添加的方法，这是消息机制的特性，不过这只是表象，事实上methodLists中该添加的方法都加进去了，消息机制顺序查找方法，先添加进去的方法位于链表尾部，被后加入的方法截胡了，我们不用消息机制，直接把methodLists所有方法都调用一次即可，实现非常简单，性能更不用说了，都是指针直接调用，比消息机制还快

```objective-c
+ (void)callDefaultClassLoader {
    [MyClassLoaderInvoker callAllClassMethod: [MyClassLoader class]];
}

+ (void)callAllClassMethod:(nonnull Class)cls {
    // Class method saved in meta class method list
    Class metaClass = object_getClass(cls);
    unsigned int count;
    Method *methods = class_copyMethodList(metaClass, &count);
    for (int i = 0; i < count; i++) {
        Method class_Method = methods[i];
        const char *methodName = sel_getName(method_getName(class_Method));
        // Class method of load and initialize invoked by OC runtime
        if (strcmp(methodName, "load") == 0 || strcmp(methodName, "initialize") == 0) {
            continue;
        }
        ((void(*)(id,Method))method_invoke)(metaClass, class_Method);
    }
}
```

callDefaultClassLoader有默认的MyClassLoader调用，如果需求特别复杂，可以自定义类，使用callAllClassMethod调用即可