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
//书籍标签视图 动态添加标签
@property (weak, nonatomic) IBOutlet UIView *labelView;
//书籍简介 长
@property (weak, nonatomic) IBOutlet UILabel *longIntro;


//书籍详细信息字典
@property (nonatomic, strong) NSDictionary *dicBookDeatail;
//遮罩层视图
@property (nonatomic, strong) UIView *waitView;
//保存在本地的书籍id
@property (nonatomic, strong) NSMutableArray *localBookId;
//判断该本书籍是否在追书
@property (nonatomic, assign) BOOL isRead;

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
    
    if (!_localBookId) {
        _localBookId = [NSKeyedUnarchiver unarchiveObjectWithFile:BookIdPath];
        if (!_localBookId) {
            self.localBookId = [NSMutableArray array];
        }
    }
    
    //通过书籍ID获取书籍详细信息
    [self getBookDetailByBookId];
    
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
    
    //隐藏scrollView的滚动条
    self.bookDetailScrollView.showsHorizontalScrollIndicator = NO;
}
- (void) getBookDetailByBookId{
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    __weak ZHBookDetailViewController *weakSelf = self;
    
    [manager GET:[Service stringByAppendingString:[NSString stringWithFormat:@"book-info/%@",_bookId]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取书籍详细信息成功：%@",responseObject);
        //保存书籍详细信息
        weakSelf.dicBookDeatail = responseObject;
        [self updateView];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书籍详细信息失败：%@",error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

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
    
    // 3.GCD
    dispatch_async(dispatch_get_main_queue(), ^{
        // UI更新代码
        //设置书籍标签
        int tags;
        NSArray *array = _dicBookDeatail[@"tags"];
        if (array.count >= 4) {
            tags = 4;
        }else{
            tags = (int)array.count ;
        }
        for (int i = 0; i < tags; i++) {
            //TODO:创建标签视图添加到视图中
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 15, 50, 30)];
            view.backgroundColor = [UIColor orangeColor];
            [self.labelView addSubview:view];
        }
    });
    
    
    
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
