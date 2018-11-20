//
//  TestFile0.m
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import "TestFile0.h"
#import "MyClassLoader.h"

@implementation TestFile0

@end

@implementation MyClassLoader(Test0)

+ (void)classLoader0 {
    NSLog(@"TestFile0 classLoader0");
}

+ (void)classLoader1 {
    NSLog(@"TestFile0 classLoader1");
}

+ (void)classLoader2 {
    NSLog(@"TestFile0 classLoader2");
}

@end
