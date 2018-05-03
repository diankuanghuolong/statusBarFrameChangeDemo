//
//  StatusBarChangeVC.m
//  statusBarFrameChangeDemo
//
//  Created by Ios_Developer on 2018/5/3.
//  Copyright © 2018年 com.Hai.app. All rights reserved.
//

#import "StatusBarChangeVC.h"

@interface StatusBarChangeVC ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,assign)int currentPage;
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSMutableArray *dataSource;
@property (nonatomic ,strong)UIView *footerView;
@end

@implementation StatusBarChangeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"状态栏，别动！";
     self.view.backgroundColor = [UIColor whiteColor];
    
    //init
    _currentPage = 1;
    
    //load
    [self.view addSubview:self.footerView];
    [self.view addSubview:self.tableView];
    
    //request
    [self requestMethod];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //download
    [self downLoadWithPage:_currentPage];
}
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
#pragma mark ===== downLoad  =====
-(void)requestMethod
{
    //下拉刷新
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.currentPage = 1;
        [self downLoadWithPage:_currentPage];
    }];
    //上拉加载
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        ++self.currentPage;
        [self downLoadWithPage:_currentPage];
    }];
    
    if(self.tableView.contentSize.height < /*CGRectGetHeight(self.tableView.frame)*/(SCREEN_HEIGHT - SafeAreaTopHeight))
        self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
}
-(void)downLoadWithPage:(int)page
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DataSource.plist" ofType:nil];
    NSArray *plistArr = [NSArray arrayWithContentsOfFile:path];
    
    //模拟分页效果，取数据
    NSMutableArray *listArr = [NSMutableArray new];
    NSUInteger count= plistArr.count;//数组元素个数
    int max= PAGESIZE;//几个分割一次
    NSUInteger segment= count / max + (count % max== 0 ? 0 : 1);//需要分割几次
    for (int i= 0;i< segment; i++)
    {
        NSUInteger star= i*max; //开始位置
        NSUInteger end= (i==(segment-1))?(count-i*max)%(max+1):max; //结束位置
        NSLog(@"%lu,%lu",(unsigned long)star,(unsigned long)end);
        NSRange range= NSMakeRange(star,end); //分割范围
        NSArray *subArray= [plistArr subarrayWithRange:range];//开始抽取
        
        [listArr addObject:subArray];
        NSLog(@"subArray=-----------%@,arr ====== %@",subArray,listArr);
    }
    
    NSMutableArray *arr = [NSMutableArray new];
    arr = listArr.count == 0 ? @[] : (page - 1 > (listArr.count - 1) ? @[] : listArr[page - 1]);
    
    if (arr.count == 0)
    {
        [self handleDatas:@[]];
    }
    else
        [self handleDatas:arr];
}
-(void)handleDatas:(NSArray *)datas
{
    //是否是小于每页请求数量
    if (datas.count < PAGESIZE)
    {
        [self.tableView.mj_footer setState:MJRefreshStateNoMoreData];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    else
        [self.tableView.mj_footer setState:MJRefreshStateIdle];
    
    //数据
    if (self.currentPage == 1)
        self.dataSource = datas.mutableCopy;
    else
        [self.dataSource addObjectsFromArray:datas];
    //
    if(!self.dataSource||self.dataSource.count <= 0)
    {
        NSLog(@"没数据了，给占位图吧。");
    }
    
    [self.tableView reloadData];
    
    [self stopLoadAnimation];
}
-(void)stopLoadAnimation
{
    if ([self.tableView.mj_header isRefreshing])
        [self.tableView.mj_header endRefreshing];
    if ([self.tableView.mj_footer isRefreshing])
        [self.tableView.mj_footer endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
#pragma mark ===== lazyLoad  =====
-(UITableView *)tableView
{
    if (!_tableView)
    {
        CGFloat h = self.tabBarController.tabBar.frame.size.height;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight - h - _footerView.frame.size.height) style:UITableViewStylePlain];
        _tableView.backgroundColor = BG_COlOR;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 5)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        _tableView.showsVerticalScrollIndicator = NO;
        if (@available (iOS 11,*)) {
            _tableView.estimatedRowHeight = 0;
        }
    }
    return _tableView;
}
-(UIView *)footerView
{
    if (!_footerView)
    {
        CGFloat tabBarH = self.tabBarController.tabBar.frame.size.height;
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - tabBarH - 55, SCREEN_WIDTH - 20, 50)];
        _footerView.backgroundColor = [UIColor greenColor];
        _footerView.layer.cornerRadius = 7;
        _footerView.layer.masksToBounds = YES;
        [self.view addSubview:_footerView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:_footerView.bounds];
        label.userInteractionEnabled = NO;
        label.text = @"点击底部按钮，啥也不干";
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        [_footerView addSubview:label];
    }
    return _footerView;
}
#pragma mark -- table view delegate/datasource method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * str = @"statusBarChange_cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
    }
    //fuzhi
    cell.textLabel.text = self.dataSource[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.numberOfLines = 3;
    
    return cell;
}
@end
