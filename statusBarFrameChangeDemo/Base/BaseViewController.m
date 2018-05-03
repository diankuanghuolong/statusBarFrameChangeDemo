//
//  BaseViewController.m
//  statusBarFrameChangeDemo
//
//  Created by Ios_Developer on 2018/5/3.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "BaseViewController.h"
/*
 基类控制器，其他控制器集成这个类。这里可以添加项目中所需要的东西，比如转场动画、返回按钮及其事件、导航栏、导航条、通用网络请求处理等。
 我不写，因为我懒、因为我笨、我还要写bug呢。
 */
@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
     ⚠️此处用的是 WillChange ，将要改变的状态监听。
     */
    //监听状态栏改变的通知 UIApplicationWillChangeStatusBarFrameNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(layoutControllerSubViews:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}
#pragma mark  ===== 状态栏改变的通知  =====
-(void)layoutControllerSubViews:(NSNotification *)notification
{
    NSValue *statusBarFrameValue =
    [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    NSLog(@"statusBarFrameValue =====  %@",statusBarFrameValue);
    //
    CGRect rect;
    [statusBarFrameValue getValue:&rect];
    
    NSLog(@"statusBarFrameValue =====  %@,rect.Height  ===  %f,self.view.height === %f",statusBarFrameValue,rect.size.height,self.view.frame.size.height);
    /*
     因为是 WillChange，你会发现，self.view.height 会是改变前的。多比较打印和界面，就可以明白了。
     */
}

@end
