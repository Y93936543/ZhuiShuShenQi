//
//  ZHBookDetail.m
//  追书神器
//
//  Created by 叶文吉 on 2018/8/8.
//  Copyright © 2018年 叶文吉. All rights reserved.
//

#import "ZHBookDetail.h"

@implementation ZHBookDetail

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
