//
//  MyClassLoaderInvoker.h
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyClassLoaderInvoker : NSObject

/**
 Call MyClassLoader class methods
 @code
 [MyClassLoaderExecuter callAllClassMethod: [MyClassLoader class]];
 @endcode
 */
+ (void)callDefaultClassLoader;

/**
 Call all class methods from the meta class, including the duplicate method in category
 @param cls Define a class loader object by yourself. such as [MyClassLoader class]
 @code
 + (void)classLoader {
 
 }
 @endcode
 */
+ (void)callAllClassMethod:(nonnull Class)cls;

@end

NS_ASSUME_NONNULL_END
