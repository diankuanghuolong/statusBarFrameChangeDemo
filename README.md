# statusBarFrameChangeDemo
statusBarFrameChangeDemo

####
当我们的APP正在使用的时候，突然有电话打入、开启热点、语音接入、录音开启等情况下，会出现，状态栏高度改变，界面下移的情况。如果我们没有做相关适配，那么有些界面会出现底部按钮遮挡、界面下移导致的部分数据遮挡等等情况。为了处理这种问题，下面提供一种解决思路，如有更好解决方案，万望指教。

```
UIApplicationWillChangeStatusBarFrameNotification 
这个通知，是监听状态栏改变的通知。通过该通知，可以获得状态栏改变的rect值。
```

知道了这些，我们就有了一个大致的方向。那么接下来就是如何方便快捷的解决界面下移导致的问题了。

如果项目开始前，我们就把这个情况考虑进去，那么最好的方案应该是，先写一个基类，然后把要做的操作尽量多的放入这个基类当中。
如果项目已经成形，相信你的VC也是有继承基类的吧。如果没有，你先去哭会吧。哭完了，可以开始加班了。还是去创建一个基类，然后一个一个的去使你的VC继承于他。即使你创建的这个基类现在只有这个解决界面下移的一个功能，以后也是有用的。好，不废话。

先说下主体思路，然后开始详细解释：
1.通过UIApplicationWillChangeStatusBarFrameNotification通知方法可以监听到状态栏的改变，并做处理。（其实我只是打印了状态栏的改变情况，并未在此处做什么处理。如果你有什么好的方法可以在这里统一处理，万望指点哪！）
2.由于项目中大量使用宏定义的屏幕高度导致替换不便。那么在需要的子控制器中添加方法 viewDidLayoutSubviews，就很有必要了：（-(void)viewDidLayoutSubviews//在某个类的内部调整子视图位置时，就会调用）。在该方法中，去修改要修改的控件的frame；


具体如下：
一：在BaseViewController中，监听并处理。（[点击查看](https://github.com/diankuanghuolong/statusBarFrameChangeDemo/blob/master/statusBarFrameChangeDemo/Base/BaseViewController.m)）

```
1.viewDidload中添加监听，如下：
 /*
     ⚠️此处用的是 WillChange ，将要改变的状态监听。
     */
    //监听状态栏改变的通知 UIApplicationWillChangeStatusBarFrameNotification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(layoutControllerSubViews:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
                                                 
2.#pragma mark  ===== 状态栏改变的通知  =====
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
这里你会发现，self.view.frame.size.height的值是会跟随状态栏的改变而改变的。
```

二：通过viewDidLayoutSubviews方法修改需要处理的控件的frame。([点击查看](https://github.com/diankuanghuolong/statusBarFrameChangeDemo/blob/master/statusBarFrameChangeDemo/StatusBarChangeVC/StatusBarChangeVC.m))

```
#pragma mark  =====  viewDidLayoutSubviews  =====
-(void)viewDidLayoutSubviews//在某个类的内部调整子视图位置时，就会调用
{
    //刷新页面布局情况，解决打电话、开热点等，导致的状态栏高度改变引起界面下移情况
    
    //1.刷新当前VC中tableview的布局
    CGFloat h = self.tabBarController.tabBar.frame.size.height;
    _tableView.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaTopHeight - SafeAreaBottomHeight - - h - _footerView.frame.size.height);
    //2.刷新footerView的布局
    CGFloat tabBarH = self.tabBarController.tabBar.frame.size.height;
    [UIView animateWithDuration:0.4 animations:^{
        _footerView.frame = CGRectMake(10, self.view.frame.size.height - tabBarH - 55, SCREEN_WIDTH - 20, 50);
    }];
}
```

![展示视图](https://github.com/diankuanghuolong/statusBarFrameChangeDemo/tree/master/statusBarFrameChangeDemo/showImages)
