//
//  ViewController.m
//  statusBarFrameChangeDemo
//
//  Created by Ios_Developer on 2018/5/3.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"command + T";
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100)/2, 200, 100, 40)];
    [btn setBackgroundColor:[UIColor greenColor]];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(gotoVC:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [self.view addSubview:btn];
}


- (void)gotoVC:(id)sender
{
    UIViewController *vc = [[NSClassFromString(@"StatusBarChangeVC") class] new];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
