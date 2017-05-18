//
//  SocketManager.h
//  TestProtobufSocket
//
//  Created by pzk on 17/5/17.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocketManagerDelegate <NSObject>

- (void)receiveProtobufData:(NSData*)data;

@end

@interface SocketManager : NSObject

@property (nonatomic, weak) id<SocketManagerDelegate> delegate;

+ (instancetype)sharedInstance;

/**
 连接到Socket

 @return YES/NO
 */
- (BOOL)connect;

/**
 断开连接
 */
- (void)disConnect;

//- (void)sendMsg:(NSString *)msg;

/**
 发送数据流和协议号

 @param data 数据流
 @param commandId 协议号
 */
- (void)sendProbufData:(NSData *)data
             CommandId:(int)commandId;

@end
