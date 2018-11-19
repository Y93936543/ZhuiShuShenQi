//
//  ZHSearchResultTableViewCell.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/15.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHSearchResultTableViewCell : UITableViewCell

//书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
//书籍名称
@property (weak, nonatomic) IBOutlet UILabel *bookName;
//书籍作者
@property (weak, nonatomic) IBOutlet UILabel *bookAuthor;
//书籍简介
@property (weak, nonatomic) IBOutlet UILabel *bookSynopsis;
//书籍人气
@property (weak, nonatomic) IBOutlet UILabel *bookPopularity;

@end

NS_ASSUME_NONNULL_END
