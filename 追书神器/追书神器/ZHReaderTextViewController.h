//
//  ZHReaderTextViewController.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZHReaderPager;
@class ZHReaderChapter;

@interface ZHReaderTextViewController : UIViewController

//章节
@property (nonatomic, strong) ZHReaderChapter *readerChapter;
//页
@property (nonatomic, strong) ZHReaderPager *readerPager;
//总页数
@property (nonatomic, assign) NSUInteger totalPage;
//获取当前图文的大小
+ (CGSize)renderSizeWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
