//
//  ZHChapterModel.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/9.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHChapterModel : NSObject

//章节标题
@property (nonatomic , copy) NSString              * title;
//章节链接
@property (nonatomic , copy) NSString              * link;
//书籍源id
@property (nonatomic , copy) NSString              * _id;
//
@property (nonatomic , assign) NSInteger              time;
//
@property (nonatomic , copy) NSString              * chapterCover;
//总页数 一般为0
@property (nonatomic , assign) NSInteger              totalpage;
//
@property (nonatomic , assign) NSInteger              partsize;
//
@property (nonatomic , assign) NSInteger              order;
//
@property (nonatomic , assign) NSInteger              currency;
//
@property (nonatomic , assign) BOOL              unreadble;
//是否是VIP
@property (nonatomic , assign) BOOL              isVip;

+(instancetype)bookListWithDict:(NSDictionary *) dic;

@end

NS_ASSUME_NONNULL_END
