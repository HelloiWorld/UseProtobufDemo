//
//  PBHelper.m
//  Football_talk_iphone
//
//  Created by pzk on 17/3/17.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import "PBHelper.h"

@implementation PBHelper

#pragma mark - Factory methods
+ (ResponseModel *)parseResponseObject:(NSData *)data{
    if (data.length < 12) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"解析数据不全" userInfo:nil];
    }
    
    ResponseModel *rspModel = [[ResponseModel alloc] init];
    
    // 截取8-12位的协议id
    NSData *cmdIdData = [data subdataWithRange:NSMakeRange(8, 4)];
    int cmdId;
    [cmdIdData getBytes: &cmdId length: sizeof(cmdId)];
    cmdId = htonl(cmdId);
    rspModel.cmdId = cmdId;
    
    // 截取4-8位用于记录数据长度的size
    NSData *sizeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int sizeLength;
    [sizeData getBytes: &sizeLength length: sizeof(sizeLength)];
    sizeLength = htonl(sizeLength);
    rspModel.sizeLength = sizeLength;
    
    if (cmdId == CommandEnum_CmdError) {
        // 拆分错误信息
        NSData *errorData = [data subdataWithRange:NSMakeRange(12, 8+sizeLength-12)];
        rspModel.data = errorData;
    } else {
        // 正常数据
        rspModel.data = [data subdataWithRange:NSMakeRange(12, data.length-12)];
    }
    
    return rspModel;
}

#pragma mark - Error 
static NSDictionary<NSString*,NSString*> *errorDic = nil;
+ (NSDictionary *)getErrorDic {
    static dispatch_once_t oneToTakeError;
    dispatch_once(&oneToTakeError, ^{
        errorDic = @{
                      @"101": @"昵称已存在",  // ERROR_NICKNAME_ALREADY_EXISTS
                      @"102": @"昵称包含敏感词汇",  // ERROR_NICKNAME_IS_SENSITIVE
                      @"103": @"会员不存在",  // ERROR_PLAYER_NOT_EXISTS
                      @"104": @"密码错误",  // ERROR_PASSWORD_WRONG
                      @"105": @"需要重新登录",  // ERROR_NEED_RELOGIN
                    };
    });
    return errorDic;
}

#pragma mark- Base
+ (void)handleBaseResponseChange:(BaseRspMessage*)baseRsp {
    if (baseRsp.resMap_Count != 0) {
        [baseRsp.resMap enumerateKeysAndInt32sUsingBlock:^(int32_t key, int32_t value, BOOL * _Nonnull stop) {
            
            if (key == ResProtoType_ResExp) {
                //经验值变化
            } else if (key == ResProtoType_ResGold) {
                //金币变化
            } else if (key == ResProtoType_ResSilver) {
                //银币变化
            } else if (key == ResProtoType_ResCopper) {
                //铜币变化
            } else if (key == ResProtoType_ResBlueGem) {
                //蓝宝石变化
            } else if (key == ResProtoType_ResRedGem) {
                //红宝石变化
            } else if (key == ResProtoType_ResYellowGem) {
                //黄宝石变化
            } else if (key == ResProtoType_ResJifen) {
                //积分值变化
            }
        }];
    }
}

#pragma mark- Additional
+ (void)handleResponseAdditional:(NSData *)additionalData {
    __block NSMutableData *mutableData = [NSMutableData dataWithData:additionalData];
    // 直到附加信息处理完成才跳出循环，若不足12字节，说明服务端数据有问题
    while (additionalData.length > 12) {
        NSData *sizeData = [mutableData subdataWithRange:NSMakeRange(4, 4)];
        int sizeLength;
        [sizeData getBytes: &sizeLength length: sizeof(sizeLength)];
        sizeLength = htonl(sizeLength);
        
        NSData *cmdIdData = [mutableData subdataWithRange:NSMakeRange(8, 4)];
        int cmdId;
        [cmdIdData getBytes: &cmdId length: sizeof(cmdId)];
        cmdId = htonl(cmdId);
        
        // 附加事件，一般是全局事件，或是用户数据变化
        if (cmdId == CommandEnum_CmdDefault) {
            
        } else {
            
        }
        
        if ((int)mutableData.length-8-sizeLength > 0) {
            // 还有附加信息，剥离处理过得信息，进入下一次递归
            [mutableData setData:[mutableData subdataWithRange:NSMakeRange(8+sizeLength, mutableData.length-8-sizeLength)]];
        } else {
            break;
        }
    }
}

@end
