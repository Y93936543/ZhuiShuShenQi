//
//  ZHCommunityViewController.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/7.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHCommunityViewController.h"
#import "MJRefreshNormalHeader.h"
#import "ZHConstans.h"
#import "ZHCoummunityTableViewCell.h"
#import "UIColor+Addition.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ZHBookCommunityViewController.h"

@interface ZHCommunityViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIScrollView *communityScrollView;
//公共板块
@property (weak, nonatomic) IBOutlet UIScrollView *publicScrollView;
//公共板块指示器
@property (weak, nonatomic) IBOutlet UIPageControl *publicPageController;
//书籍社区列表
@property (weak, nonatomic) IBOutlet UITableView *bookCoummunity;

@property (nonatomic, strong) NSMutableArray *bookCoummunityData;

//动态
@property (weak, nonatomic) IBOutlet UIView *dybamicView;
//综合讨论
@property (weak, nonatomic) IBOutlet UIView *discussView;



@end

@implementation ZHCommunityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.communityScrollView.scrollEnabled = YES;
    self.communityScrollView.mj_header.automaticallyChangeAlpha = YES;
    self.communityScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        NSLog(@"刷新");
        [self loadDate];
        [self.bookCoummunity reloadData];
    }];
    
    //设置scrollView分页效果
    self.publicScrollView.pagingEnabled = YES;
    //允许用户点击触摸事件
    self.publicScrollView.userInteractionEnabled = YES;
    //设置scrollView的偏移大小
    self.publicScrollView.contentSize = CGSizeMake(2 * self.view.bounds.size.width, 0);
    //隐藏scrollView的滚动条
    self.publicScrollView.showsHorizontalScrollIndicator = NO;
    self.publicScrollView.delegate = self;
    
    self.bookCoummunity.delegate = self;
    self.bookCoummunity.dataSource = self;
    self.bookCoummunity.separatorColor = [UIColor colorWithHex:0xEFEFF4];
    [self setExtraCellLineHidden:self.bookCoummunity];
    
    [self loadDate];
    
    __weak ZHCommunityViewController *weakSelf = self;
    
    [ZHConstans shareConstants].bookCommunity = ^{
        [weakSelf loadDate];
        [weakSelf.bookCoummunity reloadData];
    };
   
    
    //初始化公共板块
    [self initPublic];
    
    self.dybamicView.userInteractionEnabled = YES;
    self.discussView.userInteractionEnabled = YES;
}

- (void) loadDate{
    //获取BookId
    NSMutableArray *arrayID = [NSKeyedUnarchiver unarchiveObjectWithFile:BookIdPath];
    if (!arrayID) {
        arrayID = [NSMutableArray array];
    }
    _bookCoummunityData = arrayID;
}


//设置pageControl的控制显示。通过scrollView的scrollViewDidScroll方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //计算pagecontroll相应地页(滚动视图可以滚动的总宽度/单个滚动视图的宽度=滚动视图的页数)
    NSInteger currentPage = (int)(scrollView.contentOffset.x) / (int)(self.view.frame.size.width);
    self.publicPageController.currentPage = currentPage;//将上述的滚动视图页数重新赋给当前视图页数,进行分页
}

//设置风分割线
-(void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view = [UIView new];
    [tableView setTableFooterView:view];
}

//点击cell事件方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ZHBookCommunityViewController *bookCommunityVC = [[ZHBookCommunityViewController alloc] init];
    bookCommunityVC.bookId = [_bookCoummunityData objectAtIndex:indexPath.row];
    bookCommunityVC.hidesBottomBarWhenPushed = YES;
    bookCommunityVC.title = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+title",[_bookCoummunityData objectAtIndex:indexPath.row]]];
    //设置返回按钮文字，本界面设置，下一个界面显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:bookCommunityVC animated:YES];
}


//返回cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//返回UItableview的cell的数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _bookCoummunityData.count;
}

//设置最后一根分割线
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //判断是否是最后一根
    if (indexPath.row == ([_bookCoummunityData count])) {
        self.bookCoummunity.separatorInset = UIEdgeInsetsMake(0,0,0,0);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHCoummunityTableViewCell";
    //从重用队列查找可用的cell
    ZHCoummunityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHCoummunityTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //设置书籍名称
    cell.bookName.text = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+title",[_bookCoummunityData objectAtIndex:indexPath.row]]];
    //设置书籍封面
    [cell.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:[[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+cover",[_bookCoummunityData objectAtIndex:indexPath.row]]]]]];
    
    [self.communityScrollView.mj_header endRefreshing];
    
    return cell;
}

- (void) publicPress:(UITapGestureRecognizer*) sender{
    [[ZHConstans shareConstants] showToast:self.view showText:@"功能开发中，请耐心等待！"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) initPublic
{
    UIView *dynamicView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 35, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *dynamicImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dynamic"]];
    dynamicImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 30, HeightScale * 30);
    [dynamicView addSubview:dynamicImageView];
    UILabel *dynamicLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 15, HeightScale * 30, WidthScale * 38, HeightScale * 38)];
    dynamicLabel.font = [UIFont systemFontOfSize:10];
    dynamicLabel.text = @"动态";
    [dynamicView addSubview:dynamicLabel];
    UITapGestureRecognizer *tapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(publicPress:)];
    [dynamicView addGestureRecognizer:tapGestrue];
    [self.publicScrollView addSubview:dynamicView];

    UIView *discussView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 118.75, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *discussImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"discuss"]];
    discussImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 30, HeightScale * 30);
    [discussView addSubview:discussImageView];
    UILabel *discussLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 5, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    discussLabel.font = [UIFont systemFontOfSize:10];
    discussLabel.text = @"综合讨论";
    [discussView addSubview:discussLabel];
    [self.publicScrollView addSubview:discussView];

    UIView *cooperationView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 202.5, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *cooperationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cooperation"]];
    cooperationImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 40, HeightScale * 30);
    [cooperationView addSubview:cooperationImageView];
    UILabel *cooperationLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 5, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    cooperationLabel.font = [UIFont systemFontOfSize:10];
    cooperationLabel.text = @"书荒互助";
    [cooperationView addSubview:cooperationLabel];
    [self.publicScrollView addSubview:cooperationView];

    UIView *reviewView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 286.25, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *reviewImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"review"]];
    reviewImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 30, HeightScale * 30);
    [reviewView addSubview:reviewImageView];
    UILabel *reviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 5, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    reviewLabel.font = [UIFont systemFontOfSize:10];
    reviewLabel.text = @"精彩书评";
    [reviewView addSubview:reviewLabel];
    [self.publicScrollView addSubview:reviewView];

    UIView *welfareView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 35, HeightScale * 103.75, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *welfareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"welfare"]];
    welfareImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 30, HeightScale * 30);
    [welfareView addSubview:welfareImageView];
    UILabel *welfareLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 5, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    welfareLabel.font = [UIFont systemFontOfSize:10];
    welfareLabel.text = @"活动福利";
    [welfareView addSubview:welfareLabel];
    [self.publicScrollView addSubview:welfareView];

    UIView *writingView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 118.75, HeightScale * 103.75, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *writingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"writing"]];
    writingImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 33, HeightScale * 33);
    [writingView addSubview:writingImageView];
    UILabel *writingLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 7, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    writingLabel.font = [UIFont systemFontOfSize:10];
    writingLabel.text = @"原创写作";
    [writingView addSubview:writingLabel];
    [self.publicScrollView addSubview:writingView];

    UIView *heartView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 202.5, HeightScale * 103.75, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *heartImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart"]];
    heartImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 33, HeightScale * 33);
    [heartView addSubview:heartImageView];
    UILabel *heartLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 7, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    heartLabel.font = [UIFont systemFontOfSize:10];
    heartLabel.text = @"女生密语";
    [heartView addSubview:heartLabel];
    [self.publicScrollView addSubview:heartView];

    UIView *gameView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 286.25, HeightScale * 103.75, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *gameImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"game"]];
    gameImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 33, HeightScale * 33);
    [gameView addSubview:gameImageView];
    UILabel *gameLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 7, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    gameLabel.font = [UIFont systemFontOfSize:10];
    gameLabel.text = @"游戏竞技";
    [gameView addSubview:gameLabel];
    [self.publicScrollView addSubview:gameView];

    UIView *monsterView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 410, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *monsterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"monster"]];
    monsterImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 36, HeightScale * 36);
    [monsterView addSubview:monsterImageView];
    UILabel *monsterLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 14, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    monsterLabel.font = [UIFont systemFontOfSize:10];
    monsterLabel.text = @"二次元";
    [monsterView addSubview:monsterLabel];
    [self.publicScrollView addSubview:monsterView];

    UIView *medalView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 493.75, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *medalImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"medal"]];
    medalImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 30, HeightScale * 30);
    [medalView addSubview:medalImageView];
    UILabel *medalLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 5, HeightScale * 33.75, WidthScale * 45, HeightScale * 30)];
    medalLabel.font = [UIFont systemFontOfSize:10];
    medalLabel.text = @"网文江湖";
    [medalView addSubview:medalLabel];
    [self.publicScrollView addSubview:medalView];

    UIView *historyView = [[UIView alloc] initWithFrame:CGRectMake(WidthScale * 577.5, HeightScale * 20, WidthScale * 43.75, HeightScale * 43.75)];
    UIImageView *historyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history"]];
    historyImageView.frame = CGRectMake(WidthScale * 10, 0, WidthScale * 36, HeightScale * 36);
    [historyView addSubview:historyImageView];
    UILabel *historyLabel = [[UILabel alloc] initWithFrame:CGRectMake(WidthScale * 7, HeightScale * 34.75, WidthScale * 45, HeightScale * 30)];
    historyLabel.font = [UIFont systemFontOfSize:10];
    historyLabel.text = @"大话历史";
    [historyView addSubview:historyLabel];
    [self.publicScrollView addSubview:historyView];
}
@end
