//
//  ZHBookSourceModel.h
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/9.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHBookSourceModel : NSObject

//书籍源id
@property (nonatomic , copy) NSString              * _id;
//资源
@property (nonatomic , copy) NSString              * source;
//书籍源名称
@property (nonatomic , copy) NSString              * name;
//最新章节地址
@property (nonatomic , copy) NSString              * link;
//最新章节名称
@property (nonatomic , copy) NSString              * lastChapter;
//
@property (nonatomic , assign) BOOL              isCharge;
//总章节数
@property (nonatomic , assign) NSInteger              chaptersCount;
//更新时间
@property (nonatomic , copy) NSString              * updated;
//
@property (nonatomic , assign) BOOL              starting;
//
@property (nonatomic , copy) NSString              * host;


//字典转模型
+(instancetype)bookListWithDict:(NSDictionary *) dic;

@end

NS_ASSUME_NONNULL_END
