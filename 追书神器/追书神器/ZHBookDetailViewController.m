//
//  ZHBookDetailViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/15.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHBookDetailViewController.h"
#import "UIColor+Addition.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "ZHConstans.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "ZHChapterModel.h"
#import "ZHReaderViewController.h"
#import "YYLabel.h"
#import "ZHBookCommunityViewController.h"
#import "ZHInterestViewController.h"

@interface ZHBookDetailViewController ()

//滚动视图
@property (weak, nonatomic) IBOutlet UIScrollView *bookDetailScrollView;
//书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
//书籍名称
@property (weak, nonatomic) IBOutlet UILabel *bookName;
//书籍作者
@property (weak, nonatomic) IBOutlet UILabel *bookAuthor;
//书籍类型
@property (weak, nonatomic) IBOutlet UILabel *bookType;
//更新时间
@property (weak, nonatomic) IBOutlet UILabel *updateTime;
//书籍字数
@property (weak, nonatomic) IBOutlet UILabel *bookWord;
//+追更新 按钮
@property (weak, nonatomic) IBOutlet UIButton *readUpdate;
//开始阅读 按钮
@property (weak, nonatomic) IBOutlet UIButton *startRead;
//追书人气
@property (weak, nonatomic) IBOutlet UILabel *bookPopularity;
//读者留存率
@property (weak, nonatomic) IBOutlet UILabel *readerRetain;
//更新字数/天
@property (weak, nonatomic) IBOutlet UILabel *updateWordDay;

//热门评论
//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *userHead1;
@property (weak, nonatomic) IBOutlet UIImageView *userHead2;
//用户昵称
@property (weak, nonatomic) IBOutlet UILabel *userName1;
@property (weak, nonatomic) IBOutlet UILabel *userName2;
//评论标题
@property (weak, nonatomic) IBOutlet UILabel *plTitle1;
@property (weak, nonatomic) IBOutlet UILabel *plTitle2;
//评论时间
@property (weak, nonatomic) IBOutlet UILabel *commTime1;
@property (weak, nonatomic) IBOutlet UILabel *commTime2;
//赞数量
@property (weak, nonatomic) IBOutlet UILabel *likeNumber1;
@property (weak, nonatomic) IBOutlet UILabel *likeNumber2;
//更多
@property (weak, nonatomic) IBOutlet UILabel *moreBtn;
//社区视图
@property (weak, nonatomic) IBOutlet UIView *communityView;
//热门评论视图
@property (weak, nonatomic) IBOutlet UIView *hotCommView1;
@property (weak, nonatomic) IBOutlet UIView *hotCommView2;
//书籍社区
@property (weak, nonatomic) IBOutlet UILabel *bookNameCommunity;
//帖子数量
@property (weak, nonatomic) IBOutlet UILabel *tzNumber;
//你可能感兴趣
//视图
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (weak, nonatomic) IBOutlet UIView *view4;
//图片
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIImageView *imageView4;
//标签 书籍名称
@property (weak, nonatomic) IBOutlet UILabel *label11;
@property (weak, nonatomic) IBOutlet UILabel *label22;
@property (weak, nonatomic) IBOutlet UILabel *label33;
@property (weak, nonatomic) IBOutlet UILabel *label44;
//更多按钮
@property (weak, nonatomic) IBOutlet UILabel *moreBtn_xq;

//图书版权
@property (weak, nonatomic) IBOutlet UILabel *bookCopyright;

//标签1、2、3、4
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;

//书籍详细信息字典
@property (nonatomic, strong) NSDictionary *dicBookDeatail;
//遮罩层视图
@property (nonatomic, strong) UIView *waitView;
//保存在本地的书籍id
@property (nonatomic, strong) NSMutableArray *localBookId;
//判断该本书籍是否在追书
@property (nonatomic, assign) BOOL isRead;
//书籍简介 长
@property (nonatomic, strong) YYLabel *yyLabel;
//可能感兴趣的书籍都信息
@property (nonatomic, strong) NSMutableArray *interestBookInfo;

@end

@implementation ZHBookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //页面展示之前进行等待提示框 和 网络请求
    self.waitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.waitView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.waitView];
    
    //执行网络加载，等待提示框
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _yyLabel = [YYLabel new];
    _yyLabel.frame = CGRectMake(25, 317, WidthScale * 335, 83);
    _yyLabel.font = [UIFont systemFontOfSize:14];
    _yyLabel.textColor = [UIColor colorWithHex:0x696969];
    
    _yyLabel.numberOfLines = 6;
    [self.bookDetailScrollView addSubview:_yyLabel];
    
    if (!_localBookId) {
        _localBookId = [NSKeyedUnarchiver unarchiveObjectWithFile:BookIdPath];
        if (!_localBookId) {
            self.localBookId = [NSMutableArray array];
        }
    }
    
    //通过书籍ID获取书籍详细信息
    [self getBookDetailByBookId:0];
    //通过书籍ID获取书籍热门评论
    [self getBookDetailByBookId:1];
    //通过书籍ID获取书籍社区帖子数量
    [self getBookDetailByBookId:2];
    //通过书籍ID获取你可能感兴趣书籍
    [self getBookDetailByBookId:3];
    
    [self setTitle:@"书籍详情"];
    
    //设置 +追更新 按钮边框 颜色 圆角
    _readUpdate.layer.cornerRadius = 5;
    
    _readUpdate.layer.borderColor = [UIColor colorWithHex:0xA20000].CGColor;
    _readUpdate.layer.borderWidth = 1.0;
    _isRead = NO;
    
    for (int i = 0; i < _localBookId.count; i++) {
        if ([_localBookId[i] isEqualToString:_bookId]) {
            _isRead = YES;
            [self.readUpdate setTitle:@"- 不追了" forState:UIControlStateNormal];
            [self.readUpdate setBackgroundColor:[UIColor colorWithHex:0xC8C8C8]];
            [_readUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.readUpdate.layer.borderWidth = 0;
        }
    }
    
    //设置开始阅读按钮圆角
    _startRead.layer.cornerRadius = 5;
    
    //书籍的社区的点击事件
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(communityViewPress:)];
    _communityView.tag = 108;
    _communityView.userInteractionEnabled = YES;
    [_communityView addGestureRecognizer:gesture];
    
    //你可能感兴趣的点击事件
    UITapGestureRecognizer *gestrueView1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _view1.userInteractionEnabled = YES;
    _view1.tag = 101;
    [_view1 addGestureRecognizer:gestrueView1];
    UITapGestureRecognizer *gestrueView2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _view2.userInteractionEnabled = YES;
    _view2.tag = 102;
    [_view2 addGestureRecognizer:gestrueView2];
    UITapGestureRecognizer *gestrueView3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _view3.userInteractionEnabled = YES;
    _view3.tag = 103;
    [_view3 addGestureRecognizer:gestrueView3];
    UITapGestureRecognizer *gestrueView4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _view4.userInteractionEnabled = YES;
    _view4.tag = 104;
    [_view4 addGestureRecognizer:gestrueView4];
    //更多
    UITapGestureRecognizer *gestrueView5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _moreBtn_xq.userInteractionEnabled = YES;
    _moreBtn_xq.tag = 105;
    [_moreBtn_xq addGestureRecognizer:gestrueView5];
    
    //书籍作者 跳转到作者名下的书籍
    UITapGestureRecognizer *gestrueView6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestPress:)];
    _bookAuthor.userInteractionEnabled = YES;
    _bookAuthor.tag = 106;
    [_bookAuthor addGestureRecognizer:gestrueView6];
    
    //热门评论 更多 按钮
    UITapGestureRecognizer *gestrueView7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(communityViewPress:)];
    _moreBtn.userInteractionEnabled = YES;
    _moreBtn.tag = 107;
    [_moreBtn addGestureRecognizer:gestrueView7];
}

//你可能感兴趣的点击事件函数
-(void) interestPress:(UITapGestureRecognizer*) sender{
    ZHBookDetailViewController *bookDetailVC = [[ZHBookDetailViewController alloc] init];
    ZHInterestViewController *interestVC = [[ZHInterestViewController alloc] init];
    //设置返回按钮文字，本界面设置，下一个界面显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    switch ([sender.view tag]) {
        case 101:
            bookDetailVC.bookId = _interestBookInfo[0][@"_id"];
            [self.navigationController pushViewController:bookDetailVC animated:YES];
            break;
            
        case 102:
            bookDetailVC.bookId = _interestBookInfo[1][@"_id"];
            [self.navigationController pushViewController:bookDetailVC animated:YES];
            break;
            
        case 103:
            bookDetailVC.bookId = _interestBookInfo[2][@"_id"];
            [self.navigationController pushViewController:bookDetailVC animated:YES];
            break;
            
        case 104:
            bookDetailVC.bookId = _interestBookInfo[3][@"_id"];
            [self.navigationController pushViewController:bookDetailVC animated:YES];
            break;
            
        case 105:
            //TODO:你可能感兴趣更多按钮点击事件
            interestVC.interestBook = _interestBookInfo;
            interestVC.title = @"你可能感兴趣";
            [self.navigationController pushViewController:interestVC animated:YES];
            break;
            
        case 106:
            //TODO:作者名下的书籍
            interestVC.author = _dicBookDeatail[@"author"];
            interestVC.title = @"作者书单";
            [self.navigationController pushViewController:interestVC animated:YES];
            break;
            
        default:
            break;
    }
}

//书籍的社区的点击事件函数
-(void) communityViewPress:(UITapGestureRecognizer*) sender{
    ZHBookCommunityViewController *bookCommunityVC = [[ZHBookCommunityViewController alloc] init];
    bookCommunityVC.bookId = _bookId;
    if (sender.view.tag == 108) {
        bookCommunityVC.isWhat = YES;
    }else{
        bookCommunityVC.isWhat = NO;
    }
    
    bookCommunityVC.title = _dicBookDeatail[@"title"];
    //设置返回按钮文字，本界面设置，下一个界面显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:bookCommunityVC animated:YES];
}


- (void) getBookDetailByBookId:(int) i{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHBookDetailViewController *weakSelf = self;
    
    if (i == 0) {
        [manager GET:[Service stringByAppendingString:[NSString stringWithFormat:@"book-info/%@",_bookId]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取书籍详细信息成功：%@",responseObject);
            //保存书籍详细信息
            weakSelf.dicBookDeatail = responseObject;
            [self updateView];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取书籍详细信息失败：%@",error);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else if(i == 1){
        [manager GET:[NSString stringWithFormat:@"http://api.zhuishushenqi.com/post/review/by-book?book=%@&sort=comment-count&start=0&limit=2",_bookId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取书籍热门评论成功：%@",responseObject);
            [weakSelf.userHead1 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"reviews"][0][@"author"][@"avatar"]]]];
            [weakSelf.userHead2 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"reviews"][1][@"author"][@"avatar"]]]];
            weakSelf.userName1.text = responseObject[@"reviews"][0][@"author"][@"nickname"];
            weakSelf.userName2.text = responseObject[@"reviews"][1][@"author"][@"nickname"];
            weakSelf.plTitle1.text = responseObject[@"reviews"][0][@"title"];
            weakSelf.plTitle2.text = responseObject[@"reviews"][1][@"title"];
            weakSelf.likeNumber1.text = [NSString stringWithFormat:@"%d",[responseObject[@"reviews"][0][@"likeCount"] intValue]];
            weakSelf.likeNumber2.text = [NSString stringWithFormat:@"%d",[responseObject[@"reviews"][1][@"likeCount"] intValue]];
            
            int x = 0;
            int y = 0;
            
            for (int i = 0; i < [responseObject[@"reviews"][0][@"rating"] intValue]; i++) {
                x = 70 + (i * 15);
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
                imageView.frame = CGRectMake(x, 50, 10, 10);
                [self.hotCommView1 addSubview:imageView];
            }
            for (int j = 0; j < (5 - [responseObject[@"reviews"][0][@"rating"] intValue]); j++) {
                y = x + ((j + 1) * 15);
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star_nil"]];
                imageView.frame = CGRectMake(y, 50, 10, 10);
                [self.hotCommView1 addSubview:imageView];
            }
            
            for (int i = 0; i < [responseObject[@"reviews"][0][@"rating"] intValue]; i++) {
                x = 70 + (i * 15);
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star"]];
                imageView.frame = CGRectMake(x, 50, 10, 10);
                [self.hotCommView2 addSubview:imageView];
            }
            for (int j = 0; j < (5 - [responseObject[@"reviews"][0][@"rating"] intValue]); j++) {
                y = x + ((j + 1) * 15);
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Star_nil"]];
                imageView.frame = CGRectMake(y, 50, 10, 10);
                [self.hotCommView2 addSubview:imageView];
            }
            
            YYLabel *label = [YYLabel new];
            label.frame = CGRectMake(70, 60, WidthScale * 290, 50);
            label.font = [UIFont systemFontOfSize:14];
            label.attributedText = [[ZHConstans shareConstants] getAttributedStringWithString:[NSString stringWithFormat:@"%@",responseObject[@"reviews"][0][@"content"]] lineSpace:3];
            label.numberOfLines = 2;
            [weakSelf.hotCommView1 addSubview:label];
            
            YYLabel *label1 = [YYLabel new];
            label1.frame = CGRectMake(70, 60, WidthScale * 290, 50);
            label1.font = [UIFont systemFontOfSize:14];
            label1.attributedText = [[ZHConstans shareConstants] getAttributedStringWithString:[NSString stringWithFormat:@"%@",responseObject[@"reviews"][1][@"content"]] lineSpace:3];
            label1.numberOfLines = 2;
            [weakSelf.hotCommView2 addSubview:label1];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取书籍热门评论失败：%@",error);
        }];
    }else if(i == 2){
        [manager GET:[NSString stringWithFormat:@"http://api.zhuishushenqi.com/post/by-book?book=%@&start=%d&limit=20",_bookId,1] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取书籍社区帖子数量成功：%@",responseObject);
            weakSelf.tzNumber.text = [NSString stringWithFormat:@"共有 %d 个帖子",[responseObject[@"total"] intValue]];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取书籍社区帖子数量失败：%@",error);
        }];
    }else if(i == 3){
        [manager GET:[NSString stringWithFormat:@"https://novel.juhe.im/recommend/%@",_bookId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取你可能感兴趣成功：%@",responseObject);
            weakSelf.interestBookInfo = (NSMutableArray*)responseObject[@"books"];
            [weakSelf.imageView1 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"books"][0][@"cover"]]]];
            [weakSelf.imageView2 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"books"][1][@"cover"]]]];
            [weakSelf.imageView3 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"books"][2][@"cover"]]]];
            [weakSelf.imageView4 sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:responseObject[@"books"][3][@"cover"]]]];
            weakSelf.label11.text = responseObject[@"books"][0][@"title"];
            weakSelf.label22.text = responseObject[@"books"][1][@"title"];
            weakSelf.label33.text = responseObject[@"books"][2][@"title"];
            weakSelf.label44.text = responseObject[@"books"][3][@"title"];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取你可能感兴趣失败：%@",error);
        }];
    }
    
    

}

- (void) updateView{
    //设置书籍封面
    [self.bookCover sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:_dicBookDeatail[@"cover"]]]];
    //设置书籍名称
    self.bookName.text = _dicBookDeatail[@"title"];
    //设置书籍作者
    self.bookAuthor.text = _dicBookDeatail[@"author"];
    //设置书籍类型
    self.bookType.text = _dicBookDeatail[@"minorCate"];
    //设置书籍总字数
    self.bookWord.text = [NSString stringWithFormat:@"%d万字",([[NSString stringWithFormat:@"%@",_dicBookDeatail[@"wordCount"]] intValue] / 10000)];
    //设置书籍人气
    self.bookPopularity.text = [NSString stringWithFormat:@"%@",_dicBookDeatail[@"latelyFollower"]];
    //设置书籍留存率
    self.readerRetain.text = [NSString stringWithFormat:@"%.2f%%",[[NSString stringWithFormat:@"%@",_dicBookDeatail[@"retentionRatio"]] floatValue]];
    //设置书籍每天更新字数
    self.updateWordDay.text = [NSString stringWithFormat:@"%@",_dicBookDeatail[@"serializeWordCount"]];
    //设置书籍简介
    self.yyLabel.attributedText = [[ZHConstans shareConstants] getAttributedStringWithString:[NSString stringWithFormat:@"%@",_dicBookDeatail[@"longIntro"]] lineSpace:3];
    //设置书籍版权
    self.bookCopyright.text = [NSString stringWithFormat:@"版权：%@",_dicBookDeatail[@"copyright"]];
    //设置书籍社区
    _bookNameCommunity.text = [NSString stringWithFormat:@"%@的社区",_dicBookDeatail[@"title"]];
    
    //设置书籍标签
    NSArray *array = _dicBookDeatail[@"tags"];
    
    //TODO:创建标签视图添加到视图中
    _label1.layer.masksToBounds = YES;
    _label1.layer.cornerRadius = 2;
    _label2.layer.masksToBounds = YES;
    _label2.layer.cornerRadius = 2;
    _label3.layer.masksToBounds = YES;
    _label3.layer.cornerRadius = 2;
    _label4.layer.masksToBounds = YES;
    _label4.layer.cornerRadius = 2;
    if (array.count > 3) {
        _label1.text = array[0];
        _label2.text = array[1];
        _label3.text = array[2];
        _label4.text = array[3];
    }else if(array.count > 2){
        _label1.text = array[0];
        _label2.text = array[1];
        _label3.text = array[2];
    }else if(array.count > 1){
        _label1.text = array[0];
        _label2.text = array[1];
    }else if(array.count > 0){
        _label1.text = array[0];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.waitView removeFromSuperview];
}

//+追更新按钮点击事件
- (IBAction)readUpdatePress:(id)sender {
    if (_isRead) {
        for (int i = 0; i < self.localBookId.count; i++) {
            if ([self.localBookId[i] isEqualToString:_bookId]) {
                [self.localBookId removeObjectAtIndex:i];
                break;
            }
        }
        _readUpdate.layer.cornerRadius = 5;
        _readUpdate.layer.borderColor = [UIColor colorWithHex:0xA20000].CGColor;
        _readUpdate.layer.borderWidth = 1.0;
        [_readUpdate setTitle:@"+ 追更新" forState:UIControlStateNormal];
        [_readUpdate setBackgroundColor:[UIColor whiteColor]];
        [_readUpdate setTitleColor:[UIColor colorWithHex:0xA20000] forState:UIControlStateNormal];
        [[ZHConstans shareConstants] removeBookInfo:[NSString stringWithFormat:@"%@+title",_bookId]];
        [[ZHConstans shareConstants] removeBookInfo:[NSString stringWithFormat:@"%@+cover",_bookId]];
        [[ZHConstans shareConstants] removeBookInfo:[NSString stringWithFormat:@"%@+author",_bookId]];
        [[ZHConstans shareConstants] removeBookInfo:[NSString stringWithFormat:@"%@+lastChapter",_bookId]];
        _isRead = NO;
        NSLog(@"移除书籍成功，书籍id：%@",_bookId);
    }else{
        [self.localBookId insertObject:_bookId atIndex:0];
        [self.readUpdate setTitle:@"- 不追了" forState:UIControlStateNormal];
        [_readUpdate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_readUpdate setBackgroundColor:[UIColor colorWithHex:0xC8C8C8]];
        _readUpdate.layer.borderWidth = 0;
        [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+title",_bookId] withValue:_dicBookDeatail[@"title"]];
        [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+cover",_bookId] withValue:_dicBookDeatail[@"cover"]];
        [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+author",_bookId] withValue:_dicBookDeatail[@"author"]];
        [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+lastChapter",_bookId] withValue:_dicBookDeatail[@"lastChapter"]];
        _isRead = YES;
        NSLog(@"保存书籍成功，书籍id：%@",_bookId);
    }
    [NSKeyedArchiver archiveRootObject:self.localBookId toFile:BookIdPath];
   
    if ([ZHConstans shareConstants].addBook) {
        [ZHConstans shareConstants].addBook();
    }
    if ([ZHConstans shareConstants].bookCommunity){
        [ZHConstans shareConstants].bookCommunity();
    }
}

//开始阅读按钮点击事件
- (IBAction)startReadPress:(id)sender {
    //弹出等待对话框，开始网络请求加载数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __block NSInteger totle = 0;
    __block NSString *_id = @"";
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    //根据书籍id获取书籍源
    [manager GET:[[Service stringByAppendingString:@"book-sources?view=summary&book="] stringByAppendingString:_bookId] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取书籍源成功：%@",responseObject);
        
        //将获取的数据转换成字典数组
        NSArray<NSDictionary*> *dic = responseObject;
        NSMutableArray<ZHBookSourceModel*> *bookSource = [NSMutableArray array];
        for (int i = 0; i < dic.count; i++) {
            ZHBookSourceModel *bookSourceModel = [ZHBookSourceModel bookListWithDict:dic[i]];
            //TODO:保存书籍源，提供换源功能所需
            [bookSource addObject:bookSourceModel];
        }
        //保存书籍源
        [[ZHConstans shareConstants] setBookSource:bookSource];
        
        //保存书籍总章节
        totle = [dic[0][@"chaptersCount"] integerValue];
        _id = dic[0][@"_id"];
        
        //通过书籍源id获取书籍章节
        [manager GET:[[Service stringByAppendingString:@"book-chapters/"] stringByAppendingString:_id] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"获取书籍章节成功：%@",responseObject);
            
            //将获取的数据转换成字典数组
            NSArray<NSDictionary*> *dic = responseObject[@"chapters"];
            NSMutableArray<ZHChapterModel*> *bookChapter = [NSMutableArray array];
            for (int i = 0; i < dic.count; i++) {
                ZHChapterModel *bookChapterModel = [ZHChapterModel bookListWithDict:dic[i]];
                //TODO:保存书籍章节
                [bookChapter addObject:bookChapterModel];
            }
            //保存书籍章节
            [[ZHConstans shareConstants] setbookChapter:bookChapter];
            
            //执行完成之后
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            ZHReaderViewController *readVC = [[ZHReaderViewController alloc] init];
            readVC.style = 0;
            readVC.totleChapter = totle;
            [self presentViewController:readVC animated:YES completion:nil];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取书籍章节失败：%@",error);
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书籍源失败：%@",error);
    }];
}

@end
