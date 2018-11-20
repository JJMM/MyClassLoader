//
//  ViewController.m
//  MyClassLoaderExample
//
//  Created by zhangyu on 2018/11/20.
//  Copyright © 2018年 zhangyu. All rights reserved.
//

#import "ViewController.h"
#import "MyClassLoaderInvoker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MyClassLoaderInvoker callDefaultClassLoader];
}

@end
