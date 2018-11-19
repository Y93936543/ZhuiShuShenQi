//
//  TReaderMark.h
//  TBookReader
//
//  Created by tanyang on 16/1/22.
//  Copyright © 2016年 Tany. All rights reserved.
//

#import "EDbObject.h"

@interface TReaderMark : EDbObject

@property (nonatomic, strong) NSString *bookId;
@property (nonatomic, strong) NSString *chapterIndex; // 章节下标
@property (nonatomic, strong) NSString *content;      // 标签文本
@property (nonatomic, strong) NSString *time;         // 时间（未使用）
@property (nonatomic, assign) NSInteger offset;       // 章节位移

//- (BOOL)insertToDb;

+ (NSMutableArray *)dbObjectsWithBookId:(NSString*)bookId;

- (BOOL)existDbObjectsWhereRange:(NSRange)range;

- (BOOL)removeDbObjectsWhereRange:(NSRange)range;

- (BOOL)removeDbObjects;

@end
