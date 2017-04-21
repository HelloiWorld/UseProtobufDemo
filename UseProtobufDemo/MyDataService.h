//
//  MyDataService.h
//  01 NavigationTask
//
//  Created by wei.chen on 14-9-5.
//  Copyright (c) 2014年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

static NSString *const HTTPMethodGet = @"GET";
static NSString *const HTTPMethodPost = @"POST";
#define DownloadSuccess @"success"

typedef NS_ENUM(NSInteger, ResponseCode) {
    ResponseCodeOK = 200,
    ResponseCodeError = 201,
    ResponseCodeError202 = 202  // 其他原因
};

@interface MyDataService : NSObject
@property(nonatomic, strong)AFHTTPSessionManager *manager;
#pragma mark- 3.0版本使用单例
//单例创建网络代理类
+ (MyDataService *)sharedService;

//上传文件时data不为空
- (void)requestAFNURL:(NSString *)urlstring
          httpMethod:(NSString *)method
              params:(NSMutableDictionary *)params
                data:(NSMutableDictionary *)datas
         complection:(void(^)(NSDictionary *result))block;


/**
 访问PB数据的方法

 @param commandId 地址
 @param params data流
 @param playerId 用户Id,未登录为0
 @param sessionId 会话Id,每次登录/注册会改变
 @param success 成功的回调
 @param failure 失败的回调
 */
- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
                        playerId:(uint64_t)playerId
                       sessionId:(uint64_t)sessionId
                    successBlock:(void(^)(NSData *result))success
                    failureBlock:(void(^)())failure;


- (void)downloadURLArr:(NSArray *)urlArr
                      saveFolder:(NSString *)folderName
               saveNameListArr:(NSMutableArray *)nameListArr
                   success:(void(^)(NSString *result))successBlock
                      fail:(void(^)(NSError *error))failBlock;


@end
