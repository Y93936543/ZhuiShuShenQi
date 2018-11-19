//
//  LLSearchResultViewController.m
//  LLSearchView
//
//  Created by 王龙龙 on 2017/7/25.
//  Copyright © 2017年 王龙龙. All rights reserved.
//

#import "LLSearchResultViewController.h"
#import "LLSearchViewController.h"
#import "LLSearchSuggestionVC.h"
#import "LLSearchResultView.h"
#import "LLSearchView.h"
#import "ZHConstans.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ZHBookDetailViewController.h"

@interface LLSearchResultViewController ()<UISearchBarDelegate>

//搜索结果数组
@property (nonatomic, strong) NSMutableArray *searchArray;
//搜索bar
@property (nonatomic, strong) UISearchBar *searchBar;
//标题视图
@property (nonatomic, strong) UIView *titleView;
//返回视图
@property (nonatomic, strong) UIView *backView;
//输入文本
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL activity;
//导航栏右边按钮
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) LLSearchResultView *resultView;
@property (nonatomic, strong) LLSearchView *searchView;
@property (nonatomic, strong) LLSearchSuggestionVC *searchSuggestVC;

@end

@implementation LLSearchResultViewController

- (LLSearchResultView *)resultView
{
    if (!_resultView) {
        __weak LLSearchResultViewController *weakSelf = self;
        self.resultView = [[LLSearchResultView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) dataSource:self.searchArray];
        self.resultView.bookDetailBlock = ^(NSString *bookId) {
            ZHBookDetailViewController *bookDeatilVC = [[ZHBookDetailViewController alloc] init];
            bookDeatilVC.bookId = bookId;
            [weakSelf.navigationController pushViewController:bookDeatilVC animated:YES];
            //设置返回按钮文字，本界面设置，下一个界面显示
            weakSelf.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
        };
    }
    return _resultView;
}


- (LLSearchView *)searchView
{
    if (!_searchView) {
        self.searchView = [[LLSearchView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64) hotArray:self.hotArray historyArray:self.historyArray];
        __weak LLSearchResultViewController *weakSelf = self;
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.tapAction = ^(NSString *str) {
            [weakSelf setSearchResultWithStr:str];
        };
    }
    return _searchView;
}

- (LLSearchSuggestionVC *)searchSuggestVC
{
    if (!_searchSuggestVC) {
        self.searchSuggestVC = [[LLSearchSuggestionVC alloc] init];
        _searchSuggestVC.view.frame = CGRectMake(0, 64, ScreenWidth, ScreenHeight - 64);
        _searchSuggestVC.view.hidden = YES;
        __weak LLSearchResultViewController *weakSelf = self;
        _searchSuggestVC.searchBlock = ^(NSString *searchTest) {
            [weakSelf setSearchResultWithStr:searchTest];
        };
    }
    return _searchSuggestVC;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self searchBookWithName];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setBarButtonItem];
    
    [self.view addSubview:self.searchSuggestVC.view];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)setBarButtonItem
{
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    UIImage *img = [UIImage imageNamed:@"back"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(-10, 10, 22, 22);
    [btn setImage:img forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(presentVCFirstBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbiBack = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, self.view.frame.size.width - 44 * 2 - 16, 30)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_titleView.frame), 30)];
    _searchBar.text = _searchStr;
    _searchBar.backgroundImage = [UIImage imageNamed:@"clearImage"];
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor redColor];
    
    UIView *searchTextField = searchTextField = [self.searchBar valueForKey:@"_searchField"];
    searchTextField.backgroundColor = [UIColor colorWithRed:234/255.0 green:235/255.0 blue:237/255.0 alpha:1];
    
    [self.searchBar setImage:[UIImage imageNamed:@"sort_magnifier"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [_titleView addSubview:_searchBar];
    
    self.navigationItem.titleView = _titleView;
    self.navigationItem.leftBarButtonItem = bbiBack;
    
}

- (void)cancelDidClick
{
    [_searchBar resignFirstResponder];
}

- (void)presentVCFirstBackClick:(UIButton *)sender
{
    [_searchBar resignFirstResponder];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)setSearchResultWithStr:(NSString *)str
{
    [self.searchBar resignFirstResponder];
    _searchBar.text = str;
    [_searchView removeFromSuperview];
    _searchSuggestVC.view.hidden = YES;
}


#pragma mark -  UISearchBarDelegate  -

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldBeginEditing");
    _activity = !_activity;
    if (_activity) {
        self.navigationItem.rightBarButtonItem = nil;
        _titleView.frame = CGRectMake(0, 7, self.view.frame.size.width - 44 - 16, 30);
        _searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(_titleView.frame), 30);
        searchBar.showsCancelButton = YES;
        UIButton *cancleBtn = [_searchBar valueForKey:@"cancelButton"];
        //修改标题和标题颜色
        [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancleBtn.alpha = 1;
        [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return YES;
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidBeginEditing-searchTest:%@",searchBar.text);
    if ([searchBar.text length] > 0) {
        _searchSuggestVC.view.hidden = NO;
        [self.view bringSubviewToFront:_searchSuggestVC.view];
        [_searchSuggestVC searchTestChangeWithTest:searchBar.text];
    }
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarShouldEndEditing");
    self.navigationItem.rightBarButtonItem = _rightItem;
    _titleView.frame = CGRectMake(0, 7, self.view.frame.size.width - 44 * 2 - 16, 30);
    _searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(_titleView.frame), 30);
    searchBar.showsCancelButton = NO;
    _activity = NO;
    if (![searchBar.text length]) {
        _searchBar.text = _searchStr;
        [_searchView removeFromSuperview];
    };
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"searchBarTextDidEndEditing");
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"textDidChange");
    
    if (searchBar.text == nil || [searchBar.text length] <= 0) {
        _searchSuggestVC.view.hidden = YES;
        [self.view addSubview:self.searchView];
        [self.view bringSubviewToFront:_searchView];
    } else {
        _searchSuggestVC.view.hidden = NO;
        [self.view bringSubviewToFront:_searchSuggestVC.view];
        [_searchSuggestVC searchTestChangeWithTest:searchBar.text];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = _rightItem;
    _titleView.frame = CGRectMake(0, 7, self.view.frame.size.width - 44 * 2 - 16, 30);
    _searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(_titleView.frame), 30);
    searchBar.showsCancelButton = NO;
    _activity = NO;
    
    _searchSuggestVC.view.hidden = YES;
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
    [_searchView removeFromSuperview];
    [self setSearchResultWithStr:searchBar.text];
}

- (void) searchBookWithName{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    NSDictionary *dic = @{ @"keyword":_searchStr };
    
    __block NSMutableArray *book = [NSMutableArray array];
    
    [manager GET:[Service stringByAppendingString:@"search"] parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取搜索结果成功：%@",responseObject);
        NSArray *books = responseObject[@"books"];
        for (int i = 0; i < books.count; i++) {
            [book addObject:books[i]];
        }
        self.searchArray = book;
        [self.view addSubview:self.resultView];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取搜索结果失败：%@",error);
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
