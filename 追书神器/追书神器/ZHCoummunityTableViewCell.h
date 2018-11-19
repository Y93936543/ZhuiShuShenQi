//
//  ZHCoummunityTableViewCell.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/13.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHCoummunityTableViewCell : UITableViewCell

//书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
//书籍名称
@property (weak, nonatomic) IBOutlet UILabel *bookName;

@end

NS_ASSUME_NONNULL_END
