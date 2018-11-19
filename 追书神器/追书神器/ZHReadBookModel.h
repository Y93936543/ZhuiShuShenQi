//
//  ZHReadBookModel.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHReaderChapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHReadBookModel : NSObject

//书本id
@property (nonatomic, strong) NSString *bookId;
//书本名
@property (nonatomic, strong) NSString *bookName;
//书本总章节
@property (nonatomic, assign) NSInteger totalChapter;
//当前章节
@property (nonatomic, assign) NSInteger curChapterIndex;

//是否有下一章节
- (BOOL)haveNextChapter;
//是否有上一章节
- (BOOL)havePreChapter;
//重置章节
- (void)resetChapter:(ZHReaderChapter*)chapter;
//获取书记的章节
- (ZHReaderChapter*)openBookWithChapter:(NSInteger)chapter;
//打开下一章节
- (ZHReaderChapter*)openBookNextChapter;
//打开上一章节
- (ZHReaderChapter*)openBookPreChapter;

@end

NS_ASSUME_NONNULL_END
