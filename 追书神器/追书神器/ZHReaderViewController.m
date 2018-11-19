//
//  ZHReaderViewController.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHReaderViewController.h"
#import "ZHReaderTextViewController.h"
#import "TReaderMarkController.h"
#import "ZHReadBookModel.h"
#import "TReaderManager.h"
#import "TReaderMark.h"
#import "EReaderTopBar.h"
#import "EReaderToolBar.h"
#import "EReaderFontBar.h"
#import "EPageIndexView.h"
#import "UIView+NIB.h"

@interface ZHReaderViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource, EReaderToolBarDelegate,EReaderTopBarDelegate,EReaderFontBarDelegate,TReaderMarkDelegate>

@property (nonatomic, weak) UIPageViewController * pageViewController; //翻页效果
@property (nonatomic, weak) EReaderToolBar *toolBar; //工具bar
@property (nonatomic, weak) EReaderTopBar *topBar; //顶部bar
@property (nonatomic, weak) EReaderFontBar *fontBar; //字体bar
@property (nonatomic, weak) EPageIndexView *pageIndexView;

@property (nonatomic, strong) ZHReadBookModel *readerBook; //
@property (nonatomic, strong) ZHReaderChapter *chapter; //章节
@property (nonatomic, assign) CGSize renderSize;    // 渲染大小
@property (nonatomic, assign) NSInteger curPage;    // 当前页数
@property (nonatomic, assign) NSInteger readOffset; // 当前页在本章节位移
@end

@implementation ZHReaderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //UIPageViewController的自动滚动调整关闭。默认为YES
    self.automaticallyAdjustsScrollViewInsets = NO;
    //设置页面背景颜色
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加PageViewController
    [self addPageViewController];
    //增加事件响应者
    [self addSingleTapGesture];
    //打开章节第几页
    [self openBookWithChapterIndex:1];
    
    [self showReaderPage:0];
    
    //1.设置状态栏隐藏(YES)或显示(NO)
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//生命周期方法，每次控制器的视图出现时加载
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏NavigationBar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - add view

//添加UIPageViewController
- (void)addPageViewController
{
    //根据传递过来的主题参数生成不同主题的UIPageViewController
    //如果_style等于0 生成默认主题UIPageViewController
    //如果_style等于1 生成UIPageViewControllerTransitionStyleScroll（水平滑动）主题
    UIPageViewController *pageViewController = _style == ReaderTransitionStylePageCur ? [[UIPageViewController alloc] init] : [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    //设置UIPageViewController代理
    pageViewController.delegate = self;
    //设置UIPageViewController数据资源代理
    pageViewController.dataSource = self;
    //设置UIPageViewController的大小
    pageViewController.view.frame = self.view.bounds;
    
    //将生成的UIPageViewController的控制器给ZHReaderViewController控制器
    [self addChildViewController:pageViewController];
    //UIPageViewController的视图给ZHReaderViewController视图
    [self.view addSubview:pageViewController.view];
    //将生成的UIPageViewController全局化
    _pageViewController = pageViewController;
    
    //渲染大小等于UIPageViewController，放在文本显示控制器中为了方便不同的大小
    _renderSize = [ZHReaderTextViewController renderSizeWithFrame:pageViewController.view.frame];
}

//增加事件响应者
- (void)addSingleTapGesture
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    //增加事件响应者
    [self.view addGestureRecognizer:singleTap];
}


//显示第几页数据
- (void)showReaderPage:(NSUInteger)page
{
    _curPage = page;
    ZHReaderTextViewController *readerController = [self readerControllerWithPage:page chapter:_chapter];
    [_pageViewController setViewControllers:@[readerController]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

- (ZHReaderTextViewController *)readerControllerWithPage:(NSUInteger)page chapter:(ZHReaderChapter *)chapter
{
    ZHReaderTextViewController *readerViewController = [[ZHReaderTextViewController alloc]init];
    [self confogureReaderController:readerViewController page:page chapter:chapter];
    return readerViewController;
}

- (void)confogureReaderController:(ZHReaderTextViewController *)readerViewController page:(NSUInteger)page chapter:(ZHReaderChapter *)chapter
{
    if (_style == ReaderTransitionStylePageCur) {
        _curPage = page;
    }
    readerViewController.readerChapter = chapter;
    readerViewController.readerPager = [chapter chapterPagerWithIndex:page];
    if (readerViewController.readerPager) {
        NSRange range = readerViewController.readerPager.pageRange;
        _readOffset = range.location+range.length/3;
    }
}

#pragma mark - Reader Setting

/**
 打开书籍读取数据
 
 @param chapterIndex 第几页
 */
- (void)openBookWithChapterIndex:(NSInteger)chapterIndex
{
    if (!_readerBook) {
        _readerBook = [[ZHReadBookModel alloc]init];
        // test data
        _readerBook.bookId = @"123456";
        _readerBook.bookName = @"Chapter";
        _readerBook.totalChapter = 7;
    }
    _readerBook.totalChapter = _totleChapter;
    
    _chapter = [self getBookChapter:chapterIndex];
}

// 跳转到章节
- (void)turnToBookChapter:(NSInteger)chapterIndex
{
    [self openBookWithChapterIndex:chapterIndex];
    [self showReaderPage:0];
}

- (void)turnToBookChapter:(NSInteger)chapterIndex chapterOffset:(NSInteger)chapterOffset
{
    _chapter = [self getBookChapter:chapterIndex];
    NSInteger pageIndex = [_chapter pageIndexWithChapterOffset:chapterOffset];
    [self showReaderPage:pageIndex];
}

// 获取章节
- (ZHReaderChapter *)getBookChapter:(NSInteger)chapterIndex
{
    ZHReaderChapter *chapter = [_readerBook openBookWithChapter:chapterIndex];
    [chapter parseChapterWithRenderSize:_renderSize];
    return chapter;
}

- (ZHReaderChapter *)getBookPreChapter
{
    ZHReaderChapter *chapter = [_readerBook openBookPreChapter];
    [chapter parseChapterWithRenderSize:_renderSize];
    return chapter;
}

- (ZHReaderChapter *)getBookNextChapter
{
    ZHReaderChapter *chapter = [_readerBook openBookNextChapter];
    [chapter parseChapterWithRenderSize:_renderSize];
    return chapter;
}

// 字体
- (void)increaseChangeSizeAction
{
    [TReaderManager saveFontSize:[TReaderManager fontSize]+1];
    
    [_chapter parseChapter];
    
    NSInteger page = [_chapter pageIndexWithChapterOffset:_readOffset];
    
    if (page != NSNotFound) {
        [self showReaderPage:page];
    }else {
        NSLog(@"未找到page");
        [self showReaderPage:0];
    }
}

- (void)decreaseChangeSizeAction
{
    [TReaderManager saveFontSize:[TReaderManager fontSize]-1];
    
    [_chapter parseChapter];
    
    NSInteger page = [_chapter pageIndexWithChapterOffset:_readOffset];
    
    if (page != NSNotFound) {
        [self showReaderPage:page];
    }else {
        NSLog(@"未找到page");
        [self showReaderPage:0];
    }
    
}

// 书签
- (void)saveCurrentChapterPagerMark
{
    [TReaderManager saveBookMarkWithBookId:_readerBook.bookId Chapter:_chapter curPage:_curPage];
}

- (void)removeCurrentChapterPagerMark
{
    [TReaderManager removeBookMarkWithBookId:_readerBook.bookId Chapter:_chapter curPage:_curPage];
}


#pragma mark - UIPageViewControllerDataSource

/**
 向前翻页，从左向右 或者 点击左半屏幕
 
 @param pageViewController UIPageViewController
 @param viewController 文本展示视图
 @return 文本展示视图
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSLog(@"向前翻页，从左向右 或者 点击左半屏幕");
    ZHReaderTextViewController *curReaderVC = (ZHReaderTextViewController *)viewController;
    NSInteger currentPage = curReaderVC.readerPager.pageIndex;
    _curPage = currentPage;
    
    ZHReaderChapter *chapter = curReaderVC.readerChapter;
    
    if (_chapter != chapter) {
        _chapter = chapter;
        [_readerBook resetChapter:chapter];
    }
    
    ZHReaderTextViewController *readerVC = [[ZHReaderTextViewController alloc]init];
    if (currentPage > 0) {
        [self confogureReaderController:readerVC page:currentPage-1 chapter:chapter];
        NSLog(@"总页码%ld 当前页码%ld",chapter.totalPage,_curPage+1);
        return readerVC;
    }else {
        if ([_readerBook havePreChapter]) {
            NSLog(@"--获取上一章");
            ZHReaderChapter *preChapter = [self getBookPreChapter];
            [self confogureReaderController:readerVC page:preChapter.totalPage-1 chapter:preChapter];
            NSLog(@"总页码%ld 当前页码%ld",chapter.totalPage,_curPage+1);
            return readerVC;
        }else {
            NSLog(@"已经是第一页了");
            return nil;
        }
    }
    return readerVC;
}

/**
 向后翻页，从右往左 或者 点击右半屏幕
 
 @param pageViewController UIPageViewController
 @param viewController 文本展示视图
 @return 文本展示视图
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSLog(@"向后翻页，从右往左 或者 点击右半屏幕");
    ZHReaderTextViewController *curReaderVC = (ZHReaderTextViewController *)viewController;
    NSInteger currentPage = curReaderVC.readerPager.pageIndex;
    _curPage = currentPage;
    
    ZHReaderChapter *chapter = curReaderVC.readerChapter;
    
    if (_chapter != chapter) {
        _chapter = chapter;
        [_readerBook resetChapter:chapter];
    }
    
    ZHReaderTextViewController *readerVC = [[ZHReaderTextViewController alloc]init];
    if (currentPage < chapter.totalPage - 1) {
        [self confogureReaderController:readerVC page:currentPage+1 chapter:chapter];
        NSLog(@"总页码%ld 当前页码%ld",chapter.totalPage,_curPage+1);
        return readerVC;
    }else {
        if ([_readerBook haveNextChapter]) {
            NSLog(@"--获取下一章");
            ZHReaderChapter *nextChapter = [self getBookNextChapter];
            [self confogureReaderController:readerVC page:0 chapter:nextChapter];
            NSLog(@"总页码%ld 当前页码%ld",chapter.totalPage,_curPage + 1);
            return  readerVC;
        }else {
            NSLog(@"已经是最后一页了");
            return nil;
        }
    }
    return readerVC;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        if (_fontBar) {
            [self hideFontToolBar];
        }
        
        if (_toolBar && _topBar) {
            [self hideReaderSettingBar];
        }
        
        if (_pageIndexView) {
            [self hidePageIndexView];
        }
    }
}


#pragma mark - ToolBar Animation

// 显示设置
- (void)showReaderSettingBar
{
    EReaderTopBar *topBar = [EReaderTopBar createViewFromNib];
    topBar.delegate = self;
    BOOL haveMarkInCurPage = [TReaderManager existMarkWithBookId:_readerBook.bookId Chapter:_chapter curPage:_curPage];
    topBar.markBtn.selected = haveMarkInCurPage;
    topBar.frame = CGRectMake(0, -CGRectGetHeight(topBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(topBar.frame));
    [self.view addSubview:topBar];
    _topBar = topBar;
    
    EReaderToolBar *toolBar = [EReaderToolBar createViewFromNib];
    toolBar.curPage =  _curPage;
    toolBar.totalPage = _chapter.totalPage;
    toolBar.delegate = self;
    [toolBar showSliderPogress];
    toolBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(toolBar.frame));
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.topBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.topBar.frame));
        self.toolBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.toolBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.toolBar.frame));
    }];
}

- (void)hideReaderSettingBar
{
    [UIView animateWithDuration:0.2 animations:^{
        self.topBar.frame = CGRectMake(0, -CGRectGetHeight(self.topBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.topBar.frame));
        self.toolBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.toolBar.frame));
        
    } completion:^(BOOL finished) {
        [self.toolBar removeFromSuperview];
        [self.topBar removeFromSuperview];
    }];
}

- (void)showFontToolBar
{
    _fontBar = [EReaderFontBar createViewFromNib];
    _fontBar.delegate = self;
    [self.view addSubview:_fontBar];
    
    _fontBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(_fontBar.frame));
    
    [UIView animateWithDuration:0.2 animations:^{
        self.fontBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.fontBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.toolBar.frame));
    }];
}

- (void)hideFontToolBar
{
    [UIView animateWithDuration:0.2 animations:^{
        self.fontBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.fontBar.frame));
        
    } completion:^(BOOL finished) {
        [self.fontBar removeFromSuperview];
    }];
}

- (void)showPageIndexViewWithPage:(NSInteger)page totalPage:(NSInteger)totalPage
{
    if (_pageIndexView == nil) {
        EPageIndexView *pageIndexView = [[EPageIndexView alloc]init];
        pageIndexView.image = [UIImage imageNamed:@"ico_schedule"];
        CGSize imageSize = pageIndexView.image.size;
        pageIndexView.frame = CGRectMake((CGRectGetWidth(self.view.frame)-imageSize.width)/2,CGRectGetMinY(_toolBar.frame)-imageSize.height-8, imageSize.width, imageSize.height);
        [self.view addSubview:pageIndexView];
        _pageIndexView = pageIndexView;
    }
    
    _pageIndexView.label.text = [NSString stringWithFormat:@"%ld/%ld",page,totalPage];
}

- (void)hidePageIndexView
{
    if (_pageIndexView == nil) {
        return;
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        self.pageIndexView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.pageIndexView removeFromSuperview];
    }];
}




#pragma mark - Action
- (void)singleTapAction:(UIGestureRecognizer*)gesture
{
    NSLog(@"增加的事件响应者");
    if (_fontBar) {
        [self hideFontToolBar];
        return;
    }
    
    if (_topBar && _toolBar) {
        [self hideReaderSettingBar];
        [self hidePageIndexView];
        //1.设置状态栏隐藏(YES)或显示(NO)
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    }else {
        [self showReaderSettingBar];
        //1.设置状态栏隐藏(YES)或显示(NO)
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

#pragma mark - EReaderToolBarDelegate

- (void)readerToolBar:(EReaderToolBar *)readerToolBar didClickedAction:(EReaderToolBarAction)action
{
    if (action == EReaderToolBarActionMenu) {
        NSLog(@"点击目录");
        //        EBookCatalogController *VC = [[EBookCatalogController alloc]init];
        //        [self.navigationController pushViewController:VC animated:YES];
    }else if (action == EReaderToolBarActionMark) {
        TReaderMarkController *markVC = [[TReaderMarkController alloc]init];
        markVC.bookId = _readerBook.bookId;
        markVC.delegate = self;
        [self presentViewController:markVC animated:YES completion:nil];
    }else if (action == EReaderToolBarActionFont) {
        [self hideReaderSettingBar];
        [self hidePageIndexView];
        [self showFontToolBar];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
    }
}

- (void)readerToolBar:(EReaderToolBar *)readerToolBar didSliderToPage:(NSInteger)page
{
    [self showReaderPage:page];
}

- (void)readerToolBar:(EReaderToolBar *)readerToolBar didSliderToProgress:(CGFloat)progress
{
    NSInteger page = progress*_chapter.totalPage;
    [self showPageIndexViewWithPage:MIN(page+1, _chapter.totalPage) totalPage:_chapter.totalPage];
}

#pragma mark - EReaderTopBarDelegate

- (void)readerTopBar:(EReaderTopBar *)readerTopBar didClickedAction:(EReaderTopBarAction)action
{
    //返回按钮
    if (action == EReaderTopBarActionBack) {
        [self dismissViewControllerAnimated:YES completion:nil];
        //1.设置状态栏隐藏(YES)或显示(NO)
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else if (action == EReaderTopBarActionMark) {
        // 书签
        if (readerTopBar.markBtn.isSelected) {
            [self removeCurrentChapterPagerMark];
        }else {
            [self saveCurrentChapterPagerMark];
        }
    }
}

#pragma mark - EReaderFontBarDelegate

- (void)readerFontBar:(EReaderFontBar *)readerFontBar changeReaderTheme:(NSInteger)readerTheme
{
    [TReaderManager saveReaderTheme:readerTheme];
}

- (void)readerFontBar:(EReaderFontBar *)readerFontBar changeReaderFont:(BOOL)increaseSize
{
    if (increaseSize) {
        [self increaseChangeSizeAction];
    }else {
        [self decreaseChangeSizeAction];
    }
}

#pragma mrk - TReaderMarkDelegate

- (void)readerMarkController:(TReaderMarkController *)bookMarkController didSelectedMark:(TReaderMark *)mark
{
    [self turnToBookChapter:[mark.chapterIndex integerValue] chapterOffset:mark.offset];
    
    if (_toolBar && _topBar) {
        [self hideReaderSettingBar];
    }
    if (_pageIndexView) {
        [self hidePageIndexView];
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
