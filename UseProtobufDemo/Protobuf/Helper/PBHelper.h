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

#import "ResponseModel.h"
// pbobjc model
#import "AoneMessage.pbobjc.h"
#import "CommandMessage.pbobjc.h"
#import "EnumMessage.pbobjc.h"
#import "ModuleMessage.pbobjc.h"

@interface PBHelper : NSObject

+ (ResponseModel *)parseResponseObject:(NSData *)data;

/**
 错误码信息

 @return @{@"errorCode":@"desc"}
 */
+ (NSDictionary *)getErrorDic;

/**
 处理资源数据变化
 
 @param baseRsp 资源变化
 */
+ (void)handleBaseResponseChange:(BaseRspMessage*)baseRsp ;

/**
 返回数据不只一段(即有拼接)时，处理额外的事件

 @param additionalData 附加数据
 */
+ (void)handleResponseAdditional:(NSData *)additionalData;

@end
