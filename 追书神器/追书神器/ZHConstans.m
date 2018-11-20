//
//  ZHConstans.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/8.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHConstans.h"
#import "MBProgressHUD.h"

@implementation ZHConstans
{
    MBProgressHUD *_hud;
}

NSString * const Service = @"http://novel.juhe.im/";

NSString * const bookInfoUrl = @"http://novel.juhe.im/book-info/";

NSString * const staticUrl = @"http://statics.zhuishushenqi.com";

static id _constants; //第一步，先定义一个全局静态id变量

- (void)removeBookInfo:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

/**
 *  获取保存的书籍id
 */
- (NSArray *)getBookId{
    return [[NSUserDefaults standardUserDefaults] arrayForKey:@"bookId"];
}

/**
 *  获取保存的当前章节
 */
- (NSInteger *)getCurChapterIndex{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"curChapterIndex"];
}

/**
 *  获取保存的书籍章节
 */
- (NSMutableArray *)getbookChapter{
    return self.bookChapter;
}

/**
 *  保存书籍源
 */
- (void)setbookSource:(NSMutableArray*) bookSource{
    self.bookSource = bookSource;
}

/**
 *  获取书籍源
 */
- (NSMutableArray *)getbookSource{
    return self.bookSource;
}

/**
 *  保存书籍章节
 */
- (void)setbookChapter:(NSMutableArray *)bookChapter{
    self.bookChapter = bookChapter;
}

- (void)saveBookInfo:(NSString *)key withValue:(NSString *)value{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

- (NSString *)getBookInfo:(NSString *)key{
    return [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

/**
 *  在指定界面展示提示信息
 *
 *  @param  sdkView     展示信息的界面
 *  @param  showText    展示信息
 */
- (void)showToast:(UIView *) sdkView showText:(NSString *)showText
{
    _hud = [[MBProgressHUD alloc] initWithView:[sdkView superview]];
    [[sdkView superview] addSubview:_hud];
    _hud.labelText = showText;
    _hud.mode = MBProgressHUDModeText;
    [_hud showAnimated:YES whileExecutingBlock:^(){
        sleep(2);
    } completionBlock:^(){
        [_hud removeFromSuperview];
        _hud = nil;
    }];
}


/**
 *  工厂方法获得实列
 */
+ (instancetype)shareConstants
{
    if (_constants == nil) { // 防止频繁加锁
        @synchronized(self) {
            if (_constants == nil) { // 防止创建多次
                _constants = [[self alloc] init];
                
            }
        }
    }
    return _constants;
}
@end
