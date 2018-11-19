//
//  ZHFindViewController.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/7.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHFindViewController.h"
#import "ZHConstans.h"

@interface ZHFindViewController ()

//书城
@property (weak, nonatomic) IBOutlet UIView *bookCity;
//排行榜
@property (weak, nonatomic) IBOutlet UIView *rankingList;
//书单
@property (weak, nonatomic) IBOutlet UIView *bookList;
//分类
@property (weak, nonatomic) IBOutlet UIView *classity;

@property (weak, nonatomic) IBOutlet UIScrollView *findScrollView;

@end

@implementation ZHFindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.findScrollView.scrollEnabled = YES;
    //设置是否可以缩放
    self.findScrollView.alwaysBounceVertical = YES;
    self.findScrollView.userInteractionEnabled = YES;
    
    //初始化视图按钮
    [self initBtnView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  初始化视图按钮
 */
- (void) initBtnView
{
    //开启可点击
    _bookCity.userInteractionEnabled = YES;
    _rankingList.userInteractionEnabled = YES;
    _bookList.userInteractionEnabled = YES;
    _classity.userInteractionEnabled = YES;
    
    //设置tag标识
    _bookCity.tag = 101;
    _rankingList.tag = 102;
    _bookList.tag = 103;
    _classity.tag = 104;
    
    //添加点击事件
    UITapGestureRecognizer *bookCityGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnPress:)];
    UITapGestureRecognizer *rankingListGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnPress:)];
    UITapGestureRecognizer *bookListGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnPress:)];
    UITapGestureRecognizer *classityGesturRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnPress:)];
   
    [_bookCity addGestureRecognizer:bookCityGesturRecognizer];
    [_rankingList addGestureRecognizer:rankingListGesturRecognizer];
    [_bookList addGestureRecognizer:bookListGesturRecognizer];
    [_classity addGestureRecognizer:classityGesturRecognizer];
    
}

- (void) btnPress:(UITapGestureRecognizer*)sender
{
    NSLog(@"视图TAG：%ld",[sender.view tag]);
    //判断点击了哪个视图
    switch ([sender.view tag]) {
        case 101:
            //书城
            [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
            break;
        case 102:
            //排行榜
            [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
            break;
        case 103:
            //主题书单
            [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
            break;
        case 104:
            //分类
            [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
            break;
            
        default:
            break;
    }
}

@end
