//
//  MyClassLoaderInvoker.m
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import "MyClassLoaderInvoker.h"
#import "MyClassLoader.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation MyClassLoaderInvoker

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

@end
