//
//  ZHTabBarViewController.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/7.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHTabBarViewController.h"
#import "UIColor+Addition.h"
#import "ZHNavigationController.h"
#import "ZHBookViewController.h"
#import "ZHConstans.h"
#import "LLSearchViewController.h"

@interface ZHTabBarViewController ()

@end

@implementation ZHTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIViewController *vcBook = [self addChildViewControllerWithClassName:@"ZHBookViewController" andTabBarItemTitle:@"追书" andImageName:@"Book"];
    
    UIViewController *vcCommunity = [self addChildViewControllerWithClassName:@"ZHCommunityViewController" andTabBarItemTitle:@"社区" andImageName:@"Community"];
    
    UIViewController *vcFind = [self addChildViewControllerWithClassName:@"ZHFindViewController" andTabBarItemTitle:@"发现" andImageName:@"Find"];
    
    self.viewControllers = @[vcBook,vcCommunity,vcFind];
    
    self.tabBar.tintColor = [UIColor colorWithHex:0xA6A6A6];
    
    self.tabBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIViewController *) addChildViewControllerWithClassName:(NSString *) className andTabBarItemTitle:(NSString *)title andImageName:(NSString *) imageName{
    
    // 1.把字符串形式的类的名称转换成类
    Class class = NSClassFromString(className);
    
    // 创建控制器
    UIViewController *vc = [[class alloc] init];
    
    // 设置标签栏上的文字及图片
    vc.tabBarItem.title = title;
    
    vc.tabBarItem.image = [UIImage imageNamed:imageName];
    
    // 拼接图片名称
    NSString *selImageNmae = [imageName stringByAppendingString:@"_Sel"];
    
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selImageNmae] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 在子控制和标签控制器之间嵌套导航控制器
    ZHNavigationController *nav = [[ZHNavigationController alloc] initWithRootViewController:vc];
    
    [nav.navigationBar setBarTintColor:[UIColor colorWithHex:0x101010]];
    
    [nav.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //设置导航栏元素项目按钮的颜色
    nav.navigationBar.tintColor = [UIColor whiteColor];
    
    // 设置导航条的标题
    vc.navigationItem.title = @"追书神器";
    
    UIButton *btnMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMessage setImage:[UIImage imageNamed:@"Search"] forState:UIControlStateNormal];
    btnMessage.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width/375 * 15,[UIScreen mainScreen].bounds.size.height/667 * 18);
    [btnMessage addTarget:self action:@selector(searchPress) forControlEvents:UIControlEventTouchUpInside];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnMessage];
    
    vc.view.backgroundColor = [UIColor whiteColor];
    
    return nav;
}

- (void) searchPress{
    LLSearchViewController *vcSearch = [[LLSearchViewController alloc] init];
    
    vcSearch.hidesBottomBarWhenPushed = YES;
    
    [(ZHNavigationController*)self.childViewControllers[self.selectedIndex] pushViewController:vcSearch animated:YES];
}


@end
