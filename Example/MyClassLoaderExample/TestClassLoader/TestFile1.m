//
//  TestFile1.m
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import "TestFile1.h"
#import "MyClassLoader.h"

@implementation TestFile1

@end

@implementation MyClassLoader(Test0)

+ (void)classLoader0 {
    NSLog(@"TestFile1 classLoader0");
}

+ (void)classLoader1 {
    NSLog(@"TestFile1 classLoader1");
}

+ (void)classLoader2 {
    NSLog(@"TestFile1 classLoader2");
}

@end
