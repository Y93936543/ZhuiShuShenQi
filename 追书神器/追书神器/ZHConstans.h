//
//  ZHConstans.h
//  追书神器
//
//  Created by 叶文吉 on 2018/8/8.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHBookSourceModel.h"
#import <UIKit/UIKit.h>

#define WidthScale ([UIScreen mainScreen].bounds.size.width/375)
#define HeightScale ([UIScreen mainScreen].bounds.size.height/667)
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

//搜索历史保存地址
#define KHistorySearchPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"PYSearchhistories.plist"]

//书籍id保存地址
#define BookIdPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"bookId.plist"]

typedef void(^AddBook) (void);
typedef void(^BookCommunity) (void);

@interface ZHConstans : NSObject

//服务器地址
extern NSString * const Service;
//书籍详情Url
extern NSString * const bookInfoUrl;
//小说静态资源域名
extern NSString * const staticUrl;

//书籍源
@property (nonatomic, strong) NSMutableArray<ZHBookSourceModel*> *bookSource;
//书籍章节
@property (nonatomic, strong) NSMutableArray<ZHBookSourceModel*> *bookChapter;

@property (nonatomic, copy) AddBook addBook;

@property (nonatomic, copy) BookCommunity bookCommunity;

/**
 *  工厂方法获得实列
 */
+ (instancetype)shareConstants;

/**
 *  获取保存在本地的书籍id
 */
- (NSArray*) getBookId;

/**
 *  获取保存在本地的当前章节
 */
- (NSInteger*) getCurChapterIndex;

/**
 *  保存获取到的书籍源
 */
-(void) setbookSource:(NSMutableArray*)bookSource;

/**
 *  获取保存到的书籍源
 */
- (NSArray*) getbookSource;

/**
 *  保存获取到的书籍章节
 */
- (void) setbookChapter:(NSMutableArray*)bookChapter;

/**
 *。 获取保存到的书籍章节
 */
- (NSMutableArray*) getbookChapter;

/**
 *   保存获取到的书籍名称、书籍作者、更新时间
 */
- (void) saveBookInfo:(NSString*)key withValue:(NSString*)value;

/**
 *  获取书籍信息
 */
- (NSString*) getBookInfo:(NSString*)key;

/**
 *  移除书籍信息
 */
- (void) removeBookInfo:(NSString*)key;

/**
 *  在指定界面展示提示信息
 *
 *  @param  sdkView     展示信息的界面
 *  @param  showText    展示信息
 */
- (void)showToast:(UIView *) sdkView showText:(NSString *)showText;

/**
 *  调整行间距
 *
 *  @param  string     文本
 *  @param  lineSpace  行间距
 */
- (NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace;

@end
