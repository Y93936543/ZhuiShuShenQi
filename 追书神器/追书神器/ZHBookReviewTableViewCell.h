//
//  ZHBookReviewTableViewCell.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/22.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHBookReviewTableViewCell : UITableViewCell

//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *userHead;
//用户昵称
@property (weak, nonatomic) IBOutlet UILabel *userName;
//评论标题
@property (weak, nonatomic) IBOutlet UILabel *reviewTitle;
//评论时间
@property (weak, nonatomic) IBOutlet UILabel *reviewTime;
//点赞数量
@property (weak, nonatomic) IBOutlet UILabel *likeNumber;

@end

NS_ASSUME_NONNULL_END
