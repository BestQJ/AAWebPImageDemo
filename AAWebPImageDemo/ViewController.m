//
//  ViewController.m
//  AAWebPImageDemo
//
//  Created by 乔杰 on 2018/11/6.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "ViewController.h"
#import "AAWebpImage.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    UIImageView *imageView = [[UIImageView alloc] initWithImage: [AAWebpImage imageNamed: @"1"]];
    imageView.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 240)/2.0, ([UIScreen mainScreen].bounds.size.height - 240)/2.0, 240, 240);
    [self.view addSubview: imageView];


}


@end
