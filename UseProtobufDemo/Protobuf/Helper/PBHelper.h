//
//  PBHelper.h
//  Football_talk_iphone
//
//  Created by pzk on 17/3/17.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import <Foundation/Foundation.h>
// category + extension
#import "NSObject+DataMerge.h"
#import "NSObject+ProtobufExtension.h"
#import "NSObject+LogAllProperties.h"

// pbobjc model
#import "AoneMessage.pbobjc.h"
#import "CommandMessage.pbobjc.h"
#import "EnumMessage.pbobjc.h"
#import "ModuleMessage.pbobjc.h"

@interface PBHelper : NSObject

/**
 错误码信息

 @return @{@"errorCode":@"desc"}
 */
+ (NSDictionary *)getErrorDic;

/**
 处理资源数据变化
 
 @param baseRsp
 */
+ (void)handleBaseResponseChange:(BaseRspMessage*)baseRsp ;

/**
  返回数据不只一段时，处理额外的事件

 @param data
 */
+ (void)handleResponseAdditional:(NSData *)additionalData;

@end
