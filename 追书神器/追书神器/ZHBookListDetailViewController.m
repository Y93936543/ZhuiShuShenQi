//
//  ZHBookListDetailViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/23.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHBookListDetailViewController.h"
#import "ZHConstans.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIColor+Addition.h"
#import "ZHBookListDetailTableViewCell.h"
#import "ZHBookDetailViewController.h"

@interface ZHBookListDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

//书单详情列表
@property (weak, nonatomic) IBOutlet UITableView *bookListDetail;

@property (nonatomic, strong) NSDictionary *dicBookLists;
//遮罩层视图
@property (nonatomic, strong) UIView *waitView;

@end

@implementation ZHBookListDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //页面展示之前进行等待提示框 和 网络请求
    self.waitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.waitView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waitView];
    
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self getBookListDetail];
    
    _bookListDetail.delegate = self;
    _bookListDetail.dataSource = self;
    [_bookListDetail setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _bookListDetail.showsVerticalScrollIndicator = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHBookDetailViewController *bookDetailVC = [[ZHBookDetailViewController alloc] init];
    bookDetailVC.bookId = _dicBookLists[@"books"][indexPath.row][@"book"][@"_id"];
    //设置返回按钮文字，本界面设置，下一个界面显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_dicBookLists[@"books"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHBookListDetailTableViewCell";
    //从重用队列查找可用的cell
    ZHBookListDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHBookListDetailTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //设置书籍封面
    [cell.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dicBookLists[@"books"][indexPath.row][@"book"][@"cover"]]]];
    //设置书籍名称
    cell.bookName.text = _dicBookLists[@"books"][indexPath.row][@"book"][@"title"];
    //设置书籍信息
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[[[NSString stringWithFormat:@"%@ | ",_dicBookLists[@"books"][indexPath.row][@"book"][@"author"]] stringByAppendingString:[NSString stringWithFormat:@"%@ | ",_dicBookLists[@"books"][indexPath.row][@"book"][@"cat"]]] stringByAppendingString:[NSString stringWithFormat:@"%.2f万人气",[[NSString stringWithFormat:@"%@",_dicBookLists[@"books"][indexPath.row][@"book"][@"latelyFollower"]] floatValue]/10000]]];
    
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xA20000] range:NSMakeRange([[NSString stringWithFormat:@"%@ | ",_dicBookLists[@"books"][indexPath.row][@"book"][@"author"]] stringByAppendingString:[NSString stringWithFormat:@"%@ | ",_dicBookLists[@"books"][indexPath.row][@"book"][@"cat"]]].length, 5)];
    cell.shortIntro.attributedText = str;
    
    return cell;
}

- (void) getBookListDetail{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHBookListDetailViewController *weakSelf = self;
    
    [manager GET:[Service stringByAppendingString:[NSString stringWithFormat:@"booklists/%@",_bookId]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取书单详情成功：%@",responseObject);
        weakSelf.dicBookLists = responseObject[@"bookList"];
        [weakSelf initView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书单详情失败：%@",error);
    }];
}


- (void) initView{
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dicBookLists[@"author"][@"avatar"]]]];
    imageView.layer.cornerRadius = 2;
    imageView.frame = CGRectMake(20, 20, 35, 35);
    
    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(75, 20, ScreenWidth - 95, 16)];
    userName.font = [UIFont systemFontOfSize:14];
    userName.textColor = [UIColor colorWithHex:0x9E7655];
    userName.text = [_dicBookLists[@"author"][@"nickname"] stringByAppendingString:[NSString stringWithFormat:@" lv.%@",_dicBookLists[@"author"][@"lv"]]];
    
    UILabel *updateTime = [[UILabel alloc] initWithFrame:CGRectMake(75, 39, ScreenWidth - 150, 15)];
    updateTime.font = [UIFont systemFontOfSize:12];
    updateTime.textColor = [UIColor colorWithHex:0xAAAAAA];
    updateTime.text = @"1年前";//[_dicBookLists[@"created"]
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 75, ScreenWidth - 40, 16)];
    title.text = _dicBookLists[@"title"];
    title.font = [UIFont systemFontOfSize:13];
    
    UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, ScreenWidth - 40, 0)];
    desc.numberOfLines = 0;
    desc.font = [UIFont systemFontOfSize:13];
    desc.textColor = [UIColor grayColor];
    desc.text = _dicBookLists[@"desc"];
    [desc sizeToFit];
    
    UIImageView *head = [[UIImageView alloc] initWithFrame:CGRectMake(25, 121 + desc.frame.size.height, 30, 30)];
    head.layer.cornerRadius = head.bounds.size.width / 2;
    head.layer.masksToBounds = YES;
    [head sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dicBookLists[@"author"][@"avatar"]]]];
    
    UILabel *from = [[UILabel alloc] initWithFrame:CGRectMake(75, 130 + desc.frame.size.height, ScreenWidth - 95, 16)];
    from.textColor = [UIColor grayColor];
    //TODO:变色字体
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"创建来自 %@",_dicBookLists[@"author"][@"nickname"]]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0x9E7655] range:NSMakeRange(4, [NSString stringWithFormat:@"%@",_dicBookLists[@"author"][@"nickname"]].length + 1)];
    from.attributedText = str;
    from.font = [UIFont systemFontOfSize:13];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(ScreenWidth - 80, 121 + desc.frame.size.height, WidthScale * 60, HeightScale * 30);
    shareBtn.layer.cornerRadius = 15;
    [shareBtn setFont:[UIFont systemFontOfSize:14]];
    shareBtn.layer.borderColor = [UIColor colorWithHex:0xA20000].CGColor;
    shareBtn.layer.borderWidth = 1.0;
    shareBtn.layer.masksToBounds = YES;
    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn setTitle:@" 分享" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor colorWithHex:0xA20000] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 171 + desc.frame.size.height)];
    [view addSubview:imageView];
    [view addSubview:userName];
    [view addSubview:updateTime];
    [view addSubview:title];
    [view addSubview:desc];
    [view addSubview:head];
    [view addSubview:from];
    [view addSubview:shareBtn];
    
    self.bookListDetail.tableHeaderView = view;
    [_bookListDetail reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_waitView removeFromSuperview];
}

- (void) shareBtn{
    [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
}
@end
