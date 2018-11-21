//
//  ZHBookCommunityViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/20.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHBookCommunityViewController.h"
#import "UIColor+Addition.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ZHConstans.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ZHDiscussTableViewCell.h"
#import "MJRefreshNormalHeader.h"
#import "MJRefreshAutoNormalFooter.h"

@interface ZHBookCommunityViewController ()<UITableViewDataSource,UITableViewDelegate>

//讨论列表
@property (weak, nonatomic) IBOutlet UITableView *discussTableView;
//书评暂无提示信息
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
//讨论 数据
@property (nonatomic, strong) NSMutableArray *dicDiscuss;

@property (nonatomic, assign) int i;

@end

@implementation ZHBookCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _dicDiscuss = [NSMutableArray array];
    
    self.discussTableView.delegate = self;
    self.discussTableView.dataSource = self;
    
    //讨论
    [self getNetWorkingData];
    
    _i = 1;
    
    //上啦加载更多
    self.discussTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.i += 20;
        [self getNetWorkingData];
    }];
    //下拉刷新
    self.discussTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.i = 1;
        [self.dicDiscuss removeAllObjects];
        [self getNetWorkingData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segPress:(id)sender {
    UISegmentedControl *seg = sender;
    if(seg.selectedSegmentIndex){
        //书评
        _tipLabel.hidden = NO;
        _discussTableView.hidden = YES;
    }else{
        //讨论
        _tipLabel.hidden = YES;
        _discussTableView.hidden = NO;
        [self getNetWorkingData];
    }
}

- (void) getNetWorkingData{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHBookCommunityViewController *weakSelf = self;
    
    [manager GET:[NSString stringWithFormat:@"http://api.zhuishushenqi.com/post/by-book?book=%@&start=%d&limit=20",_bookId,_i] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取书籍讨论成功：%@",responseObject);
        for(int i = 0;i < ((NSMutableArray*)responseObject[@"posts"]).count; i++){
            [weakSelf.dicDiscuss addObject:((NSMutableArray*)responseObject[@"posts"])[i]];
        }
        [weakSelf.discussTableView reloadData];
        [weakSelf.discussTableView.mj_footer endRefreshing];
        [weakSelf.discussTableView.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书籍讨论失败：%@",error);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHDiscussTableViewCell";
    //从重用队列查找可用的cell
    ZHDiscussTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHDiscussTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //设置用户头像
    [cell.head sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:[NSString stringWithFormat:@"%@",[[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"author"] objectForKey:@"avatar"]]]]];
    //设置用户昵称和等级
    cell.userNameClass.text = [[[NSString stringWithFormat:@"%@",[[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"author"] objectForKey:@"nickname"]] stringByAppendingString:@" lv"] stringByAppendingString:[NSString stringWithFormat:@"%@",[[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"author"] objectForKey:@"lv"]]];
    //设置讨论内容
    cell.content.text = [NSString stringWithFormat:@"%@",[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"title"]];
    //设置评论数量
    cell.discussNumber.text = [NSString stringWithFormat:@"%d",[[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"commentCount"] intValue]];
    //设置点赞数量
    cell.likeNumber.text = [NSString stringWithFormat:@"%d",[[[_dicDiscuss objectAtIndex:indexPath.row] objectForKey:@"likeCount"] intValue]];;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dicDiscuss.count;
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
