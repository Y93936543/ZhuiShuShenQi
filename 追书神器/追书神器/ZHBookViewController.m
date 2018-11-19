//
//  ZHBookViewController.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/7.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHBookViewController.h"
#import "ZHBookTableViewCell.h"
#import "UIColor+Addition.h"
#import "AFNetworking.h"
#import "ZHBookDetail.h"
#import "ZHConstans.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MJRefreshNormalHeader.h"
#import "MJRefreshAutoNormalFooter.h"
#import "ZHReaderViewController.h"
#import "MBProgressHUD.h"
#import "ZHChapterModel.h"
#import "ZHBookDetailViewController.h"

@interface ZHBookViewController ()<UITableViewDataSource,UITableViewDelegate>

//没有书籍时显示的视图
@property (weak, nonatomic) IBOutlet UIView *isnilView;
//添加书籍视图
@property (weak, nonatomic) IBOutlet UIView *AddBookView;
//书籍列表
@property (weak, nonatomic) IBOutlet UITableView *BookListTablelView;
//书籍源
@property (nonatomic,copy) NSArray<ZHBookDetail *> *bookArray;
//书籍刷新源
@property (nonatomic,copy) NSArray<ZHBookDetail *> *bookList;
//保存在本地的书籍id
@property (nonatomic, strong) NSMutableArray *localBookId;

@property (nonatomic,assign) bool isFirst;

@end

@implementation ZHBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //控制进入软件时与刷新时获取数据
    self.isFirst = true;
    
//    NSArray *array = @[@"55eef8b27445ad27755670b9",@"567d2cb9ee0e56bc713cb2c0"];
//    [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"bookId"];
//    [[NSUserDefaults standardUserDefaults] setValue:@"修真聊天群" forKey:@"55eef8b27445ad27755670b9+title"];
//    [[NSUserDefaults standardUserDefaults] setValue:@"圣骑士的传说" forKey:@"55eef8b27445ad27755670b9+author"];
    if (!_localBookId) {
        _localBookId = [NSKeyedUnarchiver unarchiveObjectWithFile:BookIdPath];
        if (!_localBookId) {
            self.localBookId = [NSMutableArray array];
        }
    }
    
    //初始化页面
    [self initView];
    //加载数据
    [self loadData];
    
    [ZHConstans shareConstants].addBook = ^{
        [self loadData];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 初始化视图
 如果本地有保存书籍，那么显示书籍相关信息
 如果本地没有保存书籍 那么显示没有书籍视图
 */
- (void)initView{
    //判断是否有书籍
    if (_localBookId.count == 0) {
        //不隐藏为空视图
        self.isnilView.hidden = NO;
        self.BookListTablelView.hidden = YES;
        
        //创建一个点击事件手势
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBook)];
        //允许视图接受手势
        self.AddBookView.userInteractionEnabled = YES;
        //将点击时间手势给 添加书籍视图
        [self.AddBookView addGestureRecognizer:gesture];
    }else{
        //没有书籍视图隐藏
        self.isnilView.hidden = YES;
        self.BookListTablelView.hidden = NO;
        self.BookListTablelView.dataSource = self;
        self.BookListTablelView.delegate = self;
        self.BookListTablelView.separatorColor = [UIColor colorWithHex:0xEFEFF4];
        
        //TODO:读取缓存图片、书名、作者 通过书籍id+image、title、author方式获取
        for (NSString* _id in _localBookId) {
            ZHBookDetail *bookDetail = [[ZHBookDetail alloc] init];
            bookDetail._id = _id;
            bookDetail.cover = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+cover",_id]];
            bookDetail.title = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+title",_id]];
            bookDetail.author = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+author",_id]];
            bookDetail.author = [[ZHConstans shareConstants] getBookInfo:[NSString stringWithFormat:@"%@+lastChapter",_id]];
            [self.bookArray arrayByAddingObject:bookDetail];
        }
        
        [self.BookListTablelView reloadData];
        
    }
    //设置回调（一旦你进入刷新状态，然后调用target的动作，即调用[self loadNewData]）
    self.BookListTablelView.mj_header.automaticallyChangeAlpha = YES;
    self.BookListTablelView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
}


/**
 加载书籍，通过书籍Id获取书籍相关信息并保存到bookArray数组中，返回给UITableView进行展示出来
 */
- (void)loadData{
    
    NSMutableArray *arrayID = [NSKeyedUnarchiver unarchiveObjectWithFile:BookIdPath];
    if (!arrayID) {
        arrayID = [NSMutableArray array];
    }
    
    //创建队列组 可以使多喝网络请求异步执行，执行完成之后再进行操作
    dispatch_group_t group = dispatch_group_create();
    
    //创建ZHBookDetail数组对象
    __block NSMutableArray<ZHBookDetail *> *book = [NSMutableArray array];
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;
    
    //创建全局队列
    dispatch_group_t queue = dispatch_get_global_queue(0, 0);
    //
    dispatch_group_async(group, queue, ^{
        //循环遍历保存到书籍Id，通过书籍Id查询书籍相关信息并显示到UITableView
        for (int i = 0; i < arrayID.count; i++) {
            //创建 dispatch_semaphore_t 对象
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            //TODO:执行网络请求获取书籍详情 通过书籍id
            [manager GET:[bookInfoUrl stringByAppendingString:[arrayID objectAtIndex:i]] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //将请求成功返回的结果转换成字典
                NSDictionary *dic = responseObject;
                //将字典转换为model
                ZHBookDetail *model = [ZHBookDetail bookListWithDict:dic];
                //将model添加到book数组
                [book addObject:model];
                //保存书籍名称
                [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+title",model._id] withValue:model.title];
                [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+cover",model._id] withValue:model.cover];
                [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+author",model._id] withValue:model.author];
                [[ZHConstans shareConstants] saveBookInfo:[NSString stringWithFormat:@"%@+lastChapter",model._id] withValue:model.lastChapter];
                
                //请求成功发送请求成功信号量（+1）
                dispatch_semaphore_signal(semaphore);
                //请求失败
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"获取书籍信息失败：%@",error);
                //请求失败也发送请求成功信号量（+1）
                dispatch_semaphore_signal(semaphore);
            }];
            //信号量减1，如果>0 则向下执行，否则等待
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    });
    
    //当所有队列执行完成之后
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //返回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.isFirst) {
                self.bookArray = book;
                self.isFirst = false;
            }
            self.bookArray = book;
            [self.BookListTablelView.mj_header endRefreshing];
            [self.BookListTablelView reloadData];
        });
    });
}


/**
 添加书籍方法 点击添加书籍视图 跳转到发现界面
 */
- (void)addBook{
    self.tabBarController.selectedIndex = 2;
}

#pragma mark - TableView data source
//返回cell数量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookArray.count;
}

/**
 设置UITableView 中Cell的高度

 @param tableView UITableView对象
 @param indexPath 索引
 @return Cell的高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

//最后一根分割线画满
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == [_bookArray count]) {
        self.BookListTablelView.separatorInset = UIEdgeInsetsMake(0,0,0,0);
    }
}


//返回cell给tableView显示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //创建常量标识
    static NSString *identifier = @"ZHBookTableViewCell";
    //从重用队列查找可用的cell
    ZHBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断如果没有可以重用的cell就创建
    if (cell == nil) {
        NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = (ZHBookTableViewCell *) [nibArr firstObject];
        [cell setValue:identifier forKey:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //设置书籍名称
    cell.bookTitleLabel.text = [self.bookArray objectAtIndex:indexPath.row].title;
    //设置作者名称
    cell.autorLabel.text = [self.bookArray objectAtIndex:indexPath.row].author;
    //获取时间 多久前更新
    NSString *str = [self pleaseInsertStarTimeo:[self.bookArray objectAtIndex:indexPath.row].updated];
    //设置书籍封面
    [cell.bookCoverImageView sd_setImageWithURL:[NSURL URLWithString:[staticUrl stringByAppendingString:[self.bookArray objectAtIndex:indexPath.row].cover]]];
    //设置更新信息
    cell.updateMsgLabel.text = [str stringByAppendingString:[self.bookArray objectAtIndex:indexPath.row].lastChapter];

    return cell;
}


/**
 添加tableView的foot

 @param tableView 列表
 @param section ...
 @return foot视图
 */
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footView = footView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add.png"]];
    imageView.frame = CGRectMake(15, 15, 30, 30);
    [footView addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 250, 30)];
    label.text = @"添加你喜欢的小说";
    [footView addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addBook)];
    footView.userInteractionEnabled = YES;
    [footView addGestureRecognizer:tap];
    return footView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //弹出等待对话框，开始网络请求加载数据
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __block NSInteger totle = 0;
    __block NSString *_id = @"";
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;

//    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    //根据书籍id获取书籍源
    [manager GET:[[Service stringByAppendingString:@"book-sources?view=summary&book="] stringByAppendingString:[self.localBookId objectAtIndex:indexPath.row]] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        //            [[NSUserDefaults standardUserDefaults] setObject:bookSource forKey:@"bookSource"];
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
            //                [[NSUserDefaults standardUserDefaults] setObject:bookChapter forKey:@"bookChapter"];
            [[ZHConstans shareConstants] setbookChapter:bookChapter];
//            dispatch_semaphore_signal(semaphore);
            
            //执行完成之后
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            ZHReaderViewController *readVC = [[ZHReaderViewController alloc] init];
            readVC.style = 0;
            readVC.totleChapter = totle;
            [self presentViewController:readVC animated:YES completion:nil];
            //    [self.navigationController pushViewController:readVC animated:YES];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"获取书籍章节失败：%@",error);
//            dispatch_semaphore_signal(semaphore);
        }];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书籍源失败：%@",error);
//        dispatch_semaphore_signal(semaphore);
    }];

//    //等待上面任务全部完成才会执行下面代码
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    
}


/**
 根据更新时间与当前时间比较 计算出是多久之前更新的

 @param time 更新时间
 @return 多久前更新
 */
- (NSString *)pleaseInsertStarTimeo:(NSString *)time{
    // 1.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置格式化时间格式
    formatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss'Z'";
    //将字符串按照格式格式化为时间
    NSDate *date = [formatter dateFromString:time];
    
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date toDate:[NSDate date] options:0];
    // 4.输出结果
    NSString *str = @"";
    if (cmps.year > 0) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld年前更新：",cmps.year]];
    }else if (cmps.month > 0){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld月前更新：",cmps.month]];
    }else if (cmps.day > 0){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld天前更新：",cmps.day]];
    }else if (cmps.hour > 0){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld小时前更新：",cmps.hour]];
    }else if (cmps.minute > 0){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld分钟前更新：",cmps.minute]];
    }else if (cmps.second > 0){
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%ld秒钟前更新：",cmps.second]];
    }
    return str;
}


@end
