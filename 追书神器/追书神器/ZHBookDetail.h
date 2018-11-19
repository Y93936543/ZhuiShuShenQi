//
//  ZHBookDetail.h
//  追书神器
//
//  Created by 叶文吉 on 2018/8/8.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZHBookDetail : NSObject
//字典转模型
+(instancetype)bookListWithDict:(NSDictionary *) dic;
//书籍id
@property (nonatomic,copy) NSString *_id;
//书籍名称
@property (nonatomic,copy) NSString *title;
//作者
@property (nonatomic,copy) NSString *author;
//长介绍
@property (nonatomic,copy) NSString *longIntro;
//封面地址
@property (nonatomic,copy) NSString *cover;
//创建者
@property (nonatomic,copy) NSString *creater;
//主分类
@property (nonatomic,copy) NSString *majorCate;
//子分类
@property (nonatomic,copy) NSString *minorCate;
//二级主分类
@property (nonatomic,copy) NSString *majorCateV2;
//二级子分类
@property (nonatomic,copy) NSString *minorCateV2;
//隐藏包
@property (nonatomic,copy) NSArray *hiddenPackage;
//
@property (nonatomic,copy) NSArray *apptype;

@property (nonatomic,copy) NSString *rating;

@property (nonatomic,assign) bool hasCopyright;

@property (nonatomic,assign) int buytype;

@property (nonatomic,assign) int sizetype;

@property (nonatomic,copy) NSString *superscript;

@property (nonatomic,assign) int currency;

@property (nonatomic,copy) NSString *contentType;

@property (nonatomic,assign) bool _le;

//是否允许包月
@property (nonatomic,assign) bool *allowMonthly;

@property (nonatomic,assign) bool allowVoucher;

@property (nonatomic,assign) bool allowBeanVoucher;

@property (nonatomic,assign) bool hasCp;

@property (nonatomic,assign) int postCount;
//追书人气
@property (nonatomic,assign) int *latelyFollower;

@property (nonatomic,assign) int followerCount;

@property (nonatomic,assign) int wordCount;

@property (nonatomic,assign) int serializeWordCount;
//读者留存率
@property (nonatomic,assign) float retentionRatio;

@property (nonatomic,copy) NSString *updated;
//是否是连载
@property (nonatomic,assign) bool isSerial;

@property (nonatomic,assign) int chapterCount;
//最后一章节
@property (nonatomic,copy) NSString *lastChapter;

@property (nonatomic,copy) NSArray *gender;

@property (nonatomic,copy) NSArray *tags;

@property (nonatomic,assign) bool advertRead;

@property (nonatomic,copy) NSString *cat;

@property (nonatomic,assign) bool donate;

@property (nonatomic,assign) bool _gg;

@property (nonatomic,assign) bool isForbidForFreeApp;

@property (nonatomic,copy) NSString *discount;

@property (nonatomic,assign) bool limit;

@end
