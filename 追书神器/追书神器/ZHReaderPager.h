//
//  ZHReaderPager.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHReaderPager : NSObject

// 本页属性文本
@property (nonatomic, strong) NSAttributedString *attString;
// 本页范围
@property (nonatomic, assign) NSRange pageRange;
// 本页下标
@property (nonatomic, assign) NSInteger pageIndex;

@end

NS_ASSUME_NONNULL_END
