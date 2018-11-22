//
//  ZHInterestViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/22.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHInterestViewController.h"
#import "ZHInterestTableViewCell.h"
#import "ZHConstans.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ZHBookDetailViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface ZHInterestViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *interestTableView;

@end

@implementation ZHInterestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_author) {
        _interestBook = nil;
        [self getAuthorBookList];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [self setExtraCellLineHidden:_interestTableView];
    _interestTableView.delegate = self;
    _interestTableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _interestBook.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHInterestTableViewCell";
    //从重用队列查找可用的cell
    ZHInterestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHInterestTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:[[_interestBook objectAtIndex:indexPath.row] objectForKey:@"cover"]]]];
    cell.bookName.text = [[_interestBook objectAtIndex:indexPath.row] objectForKey:@"title"];
    cell.bookIntro.text = [[_interestBook objectAtIndex:indexPath.row] objectForKey:@"shortIntro"];
    cell.bookAuthor_type.text = [NSString stringWithFormat:@"%@ | %@",[[_interestBook objectAtIndex:indexPath.row] objectForKey:@"author"],[[_interestBook objectAtIndex:indexPath.row] objectForKey:@"majorCate"]];
    cell.bookPopularity.text = [NSString stringWithFormat:@"%d人气 | %.2f%%读者留存",[[[_interestBook objectAtIndex:indexPath.row] objectForKey:@"latelyFollower"] intValue],[[[_interestBook objectAtIndex:indexPath.row] objectForKey:@"retentionRatio"] floatValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHBookDetailViewController *bookDetailVC = [[ZHBookDetailViewController alloc] init];
    bookDetailVC.bookId = _interestBook[indexPath.row][@"_id"];
    //设置返回按钮文字，本界面设置，下一个界面显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:bookDetailVC animated:YES];
}

- (void) getAuthorBookList{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHInterestViewController *weakSelf = self;
    
    NSDictionary *dic = @{
                          @"author":_author
                          };
    
    [manager GET:[Service stringByAppendingString:@"author-books"] parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取作者名下书籍成功：%@",responseObject);
        weakSelf.interestBook = (NSMutableArray*)responseObject[@"books"];
        [weakSelf.interestTableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取作者名下书籍失败：%@",error);
    }];
}

//设置风分割线
-(void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [UIView new];
    [tableView setTableFooterView:view];
}

@end
