//
//  ZHReaderChapter.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHReaderPager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHReaderChapter : NSObject

// 章节内容
@property (nonatomic, strong)  NSString *chapterContent;
// 章节标题
@property (nonatomic, strong)  NSString *chapterTitle;
// 章节下标
@property (nonatomic, assign)  NSInteger chapterIndex;
// 每页范围
@property (nonatomic, strong, readonly) NSArray *pageRangeArray;
// 总页数
@property (nonatomic, assign, readonly) NSInteger totalPage;
// 图文大小
@property (nonatomic, assign, readonly) CGSize renderSize;

// 解析章节文本
- (void)parseChapter;

// 解析章节内容
- (void)parseChapterWithRenderSize:(CGSize)renderSize;

// 获取章节页
- (ZHReaderPager *)chapterPagerWithIndex:(NSInteger)pageIndex;

// 根据offset获取页下标
- (NSInteger)pageIndexWithChapterOffset:(NSInteger)offset;

@end

NS_ASSUME_NONNULL_END
