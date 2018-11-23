//
//  ZHBookTableViewCell.h
//  追书神器
//
//  Created by 叶文吉 on 2018/8/8.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZHBookTableViewCell : UITableViewCell
//书籍封面
@property (weak, nonatomic) IBOutlet UIImageView *bookCoverImageView;
//书籍名称
@property (weak, nonatomic) IBOutlet UILabel *bookTitleLabel;
//书籍作者
@property (weak, nonatomic) IBOutlet UILabel *autorLabel;
//书籍更新信息
@property (weak, nonatomic) IBOutlet UILabel *updateMsgLabel;
//是否有更新
@property (weak, nonatomic) IBOutlet UILabel *isUpdate;

@end
