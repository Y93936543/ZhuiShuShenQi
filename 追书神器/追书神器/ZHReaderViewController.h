//
//  ZHReaderViewController.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//声明主题类型
typedef NS_ENUM(NSUInteger, ReaderTransitionStyle) {
    ReaderTransitionStylePageCur, //仿真翻页 0
    ReaderTransitionStyleScroll,  //平移滚动 1
};

@interface ZHReaderViewController : UIViewController

//翻页样式
@property (nonatomic,assign) ReaderTransitionStyle style;
//书籍id 非源id
@property (nonatomic,assign) NSInteger totleChapter;

@end

NS_ASSUME_NONNULL_END
