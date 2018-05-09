//
//  MyDataService.h
//
//  Created by pzk on 17-4-21.
//  Copyright (c) 2017年 Aone. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求回调
 *
 *  @param data  服务端返回的protobuf data信息
 *  @param error  错误信息
 */
typedef void (^RequestCallBackBlock) (NSData *data, NSError *error);

@interface MyDataService : NSObject

//单例创建网络代理类
+ (MyDataService *)sharedService;

/**
 访问PB数据的方法
 
 @param commandId 协议号
 @param params protobuf data流
 @param playerID 用户Id,未登录为0
 @param sessionID 会话Id,每次登录/注册会改变
 @param dataBlock 数据回调,为nil时为服务端错误
 @param errorBlock 错误回调,若有值需处理错误情况
 */
- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
                        playerId:(uint64_t)playerID
                       sessionId:(uint64_t)sessionID
               completionHandler:(void(^)(NSData *data))dataBlock
                    errorHandler:(void(^)(int32_t errorCode))errorBlock;

@end
