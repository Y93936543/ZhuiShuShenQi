//
//  ZHChapterModel.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/9.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHChapterModel.h"

@implementation ZHChapterModel

+(instancetype)bookListWithDict:(NSDictionary *) dic{
    return [[self alloc] initWithDict:dic];
}

-(instancetype)initWithDict:(NSDictionary *) dic{
    self = [super init];
    if (self) {
        //KVC
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

//防止后台返回缺少一个字段或者多一个字段而崩溃的问题
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
    //如果后台返回的字段冲突可以使用这个进行转换
    if ([key isEqualToString:@"id"]) {
        self._id = value;
    }
}

@end
