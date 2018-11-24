//
//  ZHBookCommunityDetailViewController.m
//  追书神器
//
//  Created by 叶文吉 on 2018/11/24.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHBookCommunityDetailViewController.h"
#import "ZHConstans.h"
#import "UIColor+Addition.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface ZHBookCommunityDetailViewController ()

//滚动试图
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ZHBookCommunityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.scrollView.scrollEnabled = YES;
    //设置是否可以缩放
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
    
}


- (void) initView{
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dicCommunityDetail[@"author"][@"avatar"]]]];
    imageView.layer.cornerRadius = 2;
    imageView.frame = CGRectMake(20, 20, 35, 35);
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, ScreenWidth - 95, 16)];
    userName.font = [UIFont systemFontOfSize:14];
    userName.textColor = [UIColor colorWithHex:0x9E7655];
    userName.text = [_dicCommunityDetail[@"author"][@"nickname"] stringByAppendingString:[NSString stringWithFormat:@" lv.%@",_dicCommunityDetail[@"author"][@"lv"]]];
    
    UILabel *updateTime = [[UILabel alloc] initWithFrame:CGRectMake(75, 39, ScreenWidth - 150, 15)];
    updateTime.font = [UIFont systemFontOfSize:12];
    updateTime.textColor = [UIColor colorWithHex:0xAAAAAA];
    updateTime.text = @"1年前";//[_dicBookLists[@"created"]
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, ScreenWidth - 40, 16)];
    title.text = _dicCommunityDetail[@"title"];
    title.font = [UIFont systemFontOfSize:13];
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth - 40, 0)];
    desc.numberOfLines = 0;
    desc.font = [UIFont systemFontOfSize:13];
    desc.textColor = [UIColor grayColor];
    desc.text = _dicCommunityDetail[@"content"];
    [desc sizeToFit];
    
    //TODO:同感 分享 更多
    
    [_scrollView addSubview:imageView];
    [_scrollView addSubview:userName];
    [_scrollView addSubview:updateTime];
    [_scrollView addSubview:title];
    [_scrollView addSubview:desc];
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth, 120 + desc.bounds.size.height);
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
