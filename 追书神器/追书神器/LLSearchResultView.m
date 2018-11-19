//
//  LLSearchResultView.m
//  LLSearchView
//
//  Created by 王龙龙 on 2017/7/25.
//  Copyright © 2017年 王龙龙. All rights reserved.
//

#import "LLSearchResultView.h"
#import "ZHConstans.h"
#import "ZHSearchResultTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface LLSearchResultView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UICollectionView *contentCollectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
@implementation LLSearchResultView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSMutableArray *)dataArr
{
    if (self = [super initWithFrame:frame]) {
        self.dataSource = dataArr;
        [self addSubview:self.contentTableView];
    }
    return self;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    return _dataSource;
}


- (UITableView *)contentTableView
{
    if (!_contentTableView) {
        self.contentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
    }
    return _contentTableView;
}

#pragma mark - UITableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    [cell.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dataSource[indexPath.row][@"cover"]]]];
    
    cell.bookName.text = _dataSource[indexPath.row][@"title"];
    
    cell.bookAuthor.text = _dataSource[indexPath.row][@"author"];
    
    cell.bookSynopsis.text = _dataSource[indexPath.row][@"shortIntro"];
    
//    cell.readerRetain.text = [NSString stringWithFormat:@"%.2f%%",[[NSString stringWithFormat:@"%@",_dataSource[indexPath.row][@"retentionRatio"]] floatValue]];
    
    cell.bookPopularity.text = [NSString stringWithFormat:@"%.2f万",[[NSString stringWithFormat:@"%@",_dataSource[indexPath.row][@"latelyFollower"]] floatValue]/10000];

    return cell;
}


#pragma mark - UITableViewDelegate -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bookDetailBlock) {
        self.bookDetailBlock(_dataSource[indexPath.row][@"_id"]);
    }
}

@end
