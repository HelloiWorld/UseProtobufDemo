//
//  PBHelper.m
//  Football_talk_iphone
//
//  Created by pzk on 17/3/17.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import "PBHelper.h"

@implementation PBHelper

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
                
            } else if (key == ResProtoType_ResGold) {
                
            } else if (key == ResProtoType_ResSilver) {
                
            } else if (key == ResProtoType_ResCopper) {
                
            } else if (key == ResProtoType_ResBlueGem) {
                
            } else if (key == ResProtoType_ResRedGem) {
                
            } else if (key == ResProtoType_ResYellowGem) {
                
            } else if (key == ResProtoType_ResJifen) {
                
            }
        }];
    }
}

#pragma mark- Additional
+ (void)handleResponseAdditional:(NSData *)additionalData {
    __block NSMutableData *mutableData = [NSMutableData dataWithData:additionalData];
    while (additionalData.length > 12) {
        NSData *sizeData = [mutableData subdataWithRange:NSMakeRange(4, 4)];
        int i;
        [sizeData getBytes: &i length: sizeof(i)];
        i = htonl(i);
        
        NSData *cmdIdData = [mutableData subdataWithRange:NSMakeRange(8, 4)];
        int j;
        [cmdIdData getBytes: &j length: sizeof(j)];
        j = htonl(j);
        
        // 附加事件
        if (j == CommandEnum_CmdDefault) {
            
        } else {
            
        }
        
        if ((int)mutableData.length-8-i > 0) {
            [mutableData setData:[mutableData subdataWithRange:NSMakeRange(8+i, mutableData.length-8-i)]];
        } else {
            break;
        }
    }
}

@end
