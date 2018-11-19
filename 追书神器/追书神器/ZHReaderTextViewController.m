//
//  ZHReaderTextViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHReaderTextViewController.h"
#import "TYAttributedLabel.h"
#import "TReaderManager.h"
#import "ZHReaderPager.h"
#import "UIColor+TReaderTheme.h"

#define yTextLabelHorEdge 15    //开始坐标x
#define yTextLabelTopEdge 25    //开始坐标y
#define yTextLabelBottomEdge 10 //距离底边距离

@interface ZHReaderTextViewController ()

@property (nonatomic, weak) TYAttributedLabel *label;

@end

@implementation ZHReaderTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addAttributedLabel];
    
    [self changeReaderThemeNofication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeReaderThemeNofication) name:TReaderThemeChangeNofication object:nil];
    
}

- (void)viewWillLayoutSubviews
{
    _label.frame = [[self class]renderFrameWithFrame:self.view.frame];
}

- (void)addAttributedLabel
{
    TYAttributedLabel *label = [[TYAttributedLabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.attributedText = _readerPager.attString;
    [self.view addSubview:label];
    _label = label;
}


#pragma mark - renderSize

//获取当前图文frame 全屏减四周边距
+ (CGRect)renderFrameWithFrame:(CGRect)frame
{
    return CGRectMake(yTextLabelHorEdge, yTextLabelTopEdge, CGRectGetWidth(frame)-2*yTextLabelHorEdge, CGRectGetHeight(frame)-yTextLabelTopEdge-yTextLabelBottomEdge);
}

//获取当前图文大小
+ (CGSize)renderSizeWithFrame:(CGRect)frame
{
    return [self renderFrameWithFrame:frame].size;
}

#pragma mark - notification

- (void)changeReaderThemeNofication
{
    self.view.backgroundColor = [UIColor whiteBgReaderThemeColor];
    _label.textColor = [UIColor darkTextReaderThemeColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
