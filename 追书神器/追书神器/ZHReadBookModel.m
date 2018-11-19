//
//  ZHReadBookModel.m
//  追书神器
//
//  Created by 黄宏盛 on 2018/11/7.
//  Copyright © 2018年 ywj. All rights reserved.
//

#import "ZHReadBookModel.h"
#import "AFNetworking.h"
#import "ZHConstans.h"
#import "ZHChapterContent.h"
#import "ZHChapterModel.h"

@implementation ZHReadBookModel

//是否有下一章节
- (BOOL)haveNextChapter
{
    return _totalChapter > _curChapterIndex;
}

//是否有上一章节
- (BOOL)havePreChapter
{
    return _curChapterIndex > 1;
}

//重置所有章节
- (void)resetChapter:(ZHReaderChapter *)chapter
{
    _curChapterIndex = chapter.chapterIndex;
}

- (ZHReaderChapter *)openBookWithChapter:(NSInteger)chapter
{
    ZHReaderChapter *readerChapter = [[ZHReaderChapter alloc] init];
    readerChapter.chapterIndex = chapter;
    _curChapterIndex = chapter;
   
    //创建网络请求管理器
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求类型
    manager.requestSerializer = AFJSONRequestSerializer.serializer;

    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    __block NSString *content;
    __block NSString *title;
//    __block id  _Nullable res;

//    [manager GET:[[Service stringByAppendingString:@"chapters/"] stringByAppendingString:@"http%3A%2F%2Fvip.zhuishushenqi.com%2Fchapter%2F567b60bbea95f6ea479a1782%3Fcv%3D1529047222004"] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"获取文章成功：%@",responseObject);
//        if (responseObject[@"ok"]) {
//            NSDictionary *dic = responseObject[@"chapter"];
//            //将字典转换为model,获取书本总章节
//            ZHChapterContent *model = [ZHChapterContent bookListWithDict:dic];
//            content = model.cpContent;
//            title = model.title;
//            dispatch_semaphore_signal(semaphore);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"获取文章失败：%@",error);
//        dispatch_semaphore_signal(semaphore);
//    }];
    
    //获取书籍章节详细内容
    ZHChapterModel *bookChapter = [[[ZHConstans shareConstants] getbookChapter] objectAtIndex:self.curChapterIndex - 1];
    NSString *chapterLink = bookChapter.link;


    [manager GET:[[Service stringByAppendingString:@"chapters/"] stringByAppendingString: (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)chapterLink, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8))] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"获取书籍章节详细内容成功：%@",responseObject);
        content = responseObject[@"chapter"][@"cpContent"];
        title = responseObject[@"chapter"][@"title"];
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"获取书籍章节详细内容失败：%@",error);
        dispatch_semaphore_signal(semaphore);
    }];
    //等待上面任务全部完成才会执行下面代码
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    //设置展示的章节内容
    readerChapter.chapterContent = [NSString stringWithFormat:@"    %@",[content stringByReplacingOccurrencesOfString:@"\n\n\n\n" withString:@"\n    "]];
    //设置展示的章节标题
    readerChapter.chapterTitle = title;
    
    return readerChapter;
}

//打开下一章节
- (ZHReaderChapter *)openBookNextChapter
{
    return [self openBookWithChapter:_curChapterIndex + 1];
}

//打开上一章节
- (ZHReaderChapter *)openBookPreChapter
{
    return [self openBookWithChapter:_curChapterIndex - 1];
}

@end
