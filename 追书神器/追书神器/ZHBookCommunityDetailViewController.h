//
//  ZHBookCommunityDetailViewController.h
//  追书神器
//
//  Created by 叶文吉 on 2018/11/24.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHBookCommunityDetailViewController : UIViewController

//数据源
@property (nonatomic, strong) NSDictionary *dicCommunityDetail;
//讨论YES 书评NO
@property (nonatomic, assign) BOOL isReview;

@end

NS_ASSUME_NONNULL_END
