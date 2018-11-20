//
//  TestFile2.m
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import "TestFile2.h"
#import "MyClassLoader.h"

@implementation TestFile2

@end

@implementation MyClassLoader(Test0)

+ (void)classLoader0 {
    NSLog(@"TestFile2 classLoader0");
}

+ (void)classLoader1 {
    NSLog(@"TestFile2 classLoader1");
}

+ (void)classLoader2 {
    NSLog(@"TestFile2 classLoader2");
}

@end
