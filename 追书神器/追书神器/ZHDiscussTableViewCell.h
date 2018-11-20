//
//  ZHDiscussTableViewCell.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/20.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHDiscussTableViewCell : UITableViewCell

//用户头像
@property (weak, nonatomic) IBOutlet UIImageView *head;
//用户昵称+等级
@property (weak, nonatomic) IBOutlet UILabel *userNameClass;
//讨论内容
@property (weak, nonatomic) IBOutlet UILabel *content;
//评论数量
@property (weak, nonatomic) IBOutlet UILabel *discussNumber;
//点赞数量
@property (weak, nonatomic) IBOutlet UILabel *likeNumber;

@end

NS_ASSUME_NONNULL_END
