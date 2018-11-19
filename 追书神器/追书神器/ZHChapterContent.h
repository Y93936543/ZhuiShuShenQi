//
//  ZHChapterContent.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/6.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHChapterContent : NSObject

//字典转模型
+(instancetype)bookListWithDict:(NSDictionary *) dic;
//书籍源id
@property (nonatomic,copy) NSString *_id;
//章节标题
@property (nonatomic,copy) NSString *title;
//提示吧
@property (nonatomic,copy) NSString *body;
//是否是VIP
@property (nonatomic,assign) bool isVip;
//章节内容
@property (nonatomic,copy) NSString *cpContent;
//未知 15
@property (nonatomic,copy) NSString *currency;

@end

NS_ASSUME_NONNULL_END
