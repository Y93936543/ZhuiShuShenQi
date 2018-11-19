//
//  TReaderManager.h
//  TBookReader
//
//  Created by tanyang on 16/1/22.
//  Copyright © 2016年 tanyang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TReaderTheme) {
    TReaderThemeNormal,
    TReaderThemeEyeshield,
    TReaderThemeNight,
};

static NSString *const TReaderThemeChangeNofication = @"TReaderThemeChangeNofication";

@class ZHReaderChapter;
@class TReaderMark;
@interface TReaderManager : NSObject

// theme

+ (TReaderTheme)readerTheme;

+ (void)saveReaderTheme:(TReaderTheme)readerTheme;

// font

+ (NSUInteger)fontSize;

+ (void)saveFontSize:(NSUInteger)fontSize;

+ (BOOL)canIncreaseFontSize;

+ (BOOL)canDecreaseFontSize;

// mark

+ (BOOL)existMarkWithBookId:(NSString*)bookId Chapter:(ZHReaderChapter *)chapter curPage:(NSInteger)curPage;

+ (BOOL)removeBookMarkWithBookId:(NSString*)bookId Chapter:(ZHReaderChapter *)chapter curPage:(NSInteger)curPage;

+ (void)saveBookMarkWithBookId:(NSString*)bookId Chapter:(ZHReaderChapter *)chapter curPage:(NSInteger)curPage;

+ (void)saveBookMark:(TReaderMark *)readerMark;

@end
