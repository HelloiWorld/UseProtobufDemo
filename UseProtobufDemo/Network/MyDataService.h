//
//  MyDataService.h
//
//  Created by pzk on 17-4-21.
//  Copyright (c) 2014年 Aone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

static NSString *const HTTPMethodGet = @"GET";
static NSString *const HTTPMethodPost = @"POST";

#define baseProUrl [NSString stringWithFormat:@"%@",Protobuf_IP]
static NSString *const Protobuf_IP = @"http://10.0.1.1:8080";    // Ptotobuf

@interface MyDataService : NSObject
@property(nonatomic, strong)AFHTTPSessionManager *manager;

//单例创建网络代理类
+ (MyDataService *)sharedService;

/**
 访问PB数据的方法
 
 @param commandId 协议号
 @param params protobuf data流
 @param playerId 用户Id,未登录为0
 @param sessionId 会话Id,每次登录/注册会改变
 @param dataBlock 数据回调,为nil时为服务端错误
 @param errorBlock 错误回调,若有值需处理错误情况
 */
- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
               completionHandler:(void(^)(NSData *data))dataBlock
                    errorHandler:(void(^)(int32_t errorCode))errorBlock;

@end
