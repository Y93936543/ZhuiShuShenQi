//
//  ZHThematicListViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/19.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHThematicListViewController.h"
#import "ZHSearchResultTableViewCell.h"
#import "UIColor+Addition.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ZHConstans.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface ZHThematicListViewController ()<UITableViewDelegate,UITableViewDataSource>

//书单
@property (weak, nonatomic) IBOutlet UITableView *themeList;
//本周最热
@property (weak, nonatomic) IBOutlet UIButton *collectorCount;
//最新发布
@property (weak, nonatomic) IBOutlet UIButton *created;
//最多收藏
@property (weak, nonatomic) IBOutlet UIButton *shoucangMore;

@property (nonatomic, strong) NSMutableArray *arrayBookList;

//遮罩层视图
@property (nonatomic, strong) UIView *waitView;

@end

@implementation ZHThematicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"书单"];
    self.navigationItem.backBarButtonItem.title = @"返回";
    self.hidesBottomBarWhenPushed = YES;
    
    self.themeList.delegate = self;
    self.themeList.dataSource = self;
    
    //页面展示之前进行等待提示框 和 网络请求
    self.waitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.waitView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waitView];
    
    [self getThemeList:@"booklists?sort=collectorCount&duration=last-seven-days&start=0"];
    
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayBookList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHSearchResultTableViewCell";
    //从重用队列查找可用的cell
    ZHSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHSearchResultTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:[NSString stringWithFormat:@"%@",[_arrayBookList objectAtIndex:indexPath.row][@"cover"]]]]];
    
    cell.bookName.text = _arrayBookList[indexPath.row][@"title"];
    
    cell.bookAuthor.text = _arrayBookList[indexPath.row][@"author"];
    
    cell.bookSynopsis.text = _arrayBookList[indexPath.row][@"desc"];
    
    cell.bookPopularity.text = [NSString stringWithFormat:@"共%d本书 | %d人收藏",[[NSString stringWithFormat:@"%@",_arrayBookList[indexPath.row][@"bookCount"]] intValue],[[NSString stringWithFormat:@"%@",_arrayBookList[indexPath.row][@"collectorCount"]] intValue] ];
    return cell;
}

- (IBAction)hotPress:(id)sender {
    [self clearBtnColor];
    [self.collectorCount setTitleColor:[UIColor colorWithHex:0xFF0000] forState:UIControlStateNormal];
    [self getThemeList:@"booklists?sort=collectorCount&duration=last-seven-days&start=0"];
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)createdPress:(id)sender {
    [self clearBtnColor];
    [self.created setTitleColor:[UIColor colorWithHex:0xFF0000] forState:UIControlStateNormal];
    [self getThemeList:@"booklists?sort=created&duration=all"];
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (IBAction)collectorPress:(id)sender {
    [self clearBtnColor];
    [self.shoucangMore setTitleColor:[UIColor colorWithHex:0xFF0000] forState:UIControlStateNormal];
    [self getThemeList:@"booklists?sort=collectorCount&duration=all"];
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


- (void) clearBtnColor{
    [_collectorCount setTitleColor:[UIColor colorWithHex:0x9A9A9A] forState:UIControlStateNormal];
    [_created setTitleColor:[UIColor colorWithHex:0x9A9A9A] forState:UIControlStateNormal];
    [_shoucangMore setTitleColor:[UIColor colorWithHex:0x9A9A9A] forState:UIControlStateNormal];
}

-(void) getThemeList:(NSString*) tag{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHThematicListViewController *weakSelf = self;
    
    [manager GET:[Service stringByAppendingString:tag] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取主题书单成功：%@",responseObject);
        weakSelf.arrayBookList = responseObject[@"bookLists"];
        [weakSelf.themeList reloadData];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.waitView removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取主题书单失败：%@",error);
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
}


@end
