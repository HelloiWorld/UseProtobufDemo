//
//  MyDataService.m
//  01 NavigationTask
//
//  Created by pzk on 17-4-21.
//  Copyright (c) 2014年 Aone. All rights reserved.
//

#import "MyDataService.h"

@implementation MyDataService

+ (MyDataService *)sharedService {
    static MyDataService *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[MyDataService alloc] init];
    });
    return shareInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
                        playerId:(uint64_t)pId
                       sessionId:(uint64_t)sId
               completionHandler:(void(^)(NSData *data))dataBlock
                    errorHandler:(void(^)(int32_t errorCode))errorBlock{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //  苹果 整数字节使用小端序传输，而其他都是网络端序大端序传输
    //  HTONS 转换端序，从小端序转为大端序，HTONL 转化4字节端序，HTONLL转化8字节端序。
    //  int  htonl ->short 类型的主机存储－>网络的网络存储，并写入内存块
    //  char,string 类型不需要转换
    
    NSMutableData *protobufData = [[NSMutableData alloc] init];
    // 0XFF
    int str = 0xff;
    str = htonl(str);
    [protobufData appendBytes:&str length:sizeof(str)];
    // playerId
    uint64_t playerId = pId;
    playerId = htonll(playerId);
    NSData *playerIdData = [NSData dataWithBytes: &playerId length: sizeof(playerId)];
    [protobufData appendData:playerIdData];
    // sessionId
    uint64_t sessionId = sId;
    sessionId = htonll(sessionId);
    NSData *sessionIdData = [NSData dataWithBytes: &sessionId length: sizeof(sessionId)];
    [protobufData appendData:sessionIdData];
    // size
    u_long size = params.length+4;
    size = htonl(size);
    [protobufData appendBytes:&size length:4];
    // commandId
    commandId = htonl(commandId);
    NSData *commandIdData = [NSData dataWithBytes: &commandId length: sizeof(commandId)];
    [protobufData appendData:commandIdData];
    // data
    [protobufData appendData:params];
    
//    Byte *byte = (Byte *)[protobufData bytes];
//    NSString *byteString = @"";
//    for (int i=0 ; i<[protobufData length]; i++) {
//        [byteString stringByAppendingString:[NSString stringWithFormat:@"%c ",byte[i]]];
//    }
//    NSLog(@"byte: %@",byteString);
    
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:baseProUrl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:HTTPMethodPost];
    [request setHTTPBody:protobufData];
    //第三步，连接服务器
    NSURLSessionDataTask *task = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error){
            NSLog(@"error = %@",error);
            dataBlock(nil);
        }else{
            //            NSLog(@"protobuf data = %@", responseObject);
            
            NSData *data = responseObject;
            // 如果不需要考虑 错误 以及 有拼接 的情况，这里直接返回去除不需要信息的data就行
            // 正常数据
//            dataBlock([data subdataWithRange:NSMakeRange(12, data.length-12)]);
            
            if (data.length > 12) {
                NSData *cmdIdData = [data subdataWithRange:NSMakeRange(8, 4)];
                int j;
                [cmdIdData getBytes: &j length: sizeof(j)];
                j = htonl(j);
                
                NSData *sizeData = [data subdataWithRange:NSMakeRange(4, 4)];
                int i;
                [sizeData getBytes: &i length: sizeof(i)];
                i = htonl(i);
                if (j == CommandEnum_CmdError) {
                    // 提示错误信息
                    NSData *errorData = [data subdataWithRange:NSMakeRange(12, 8+i-12)];
                    Error_Rsp *rsp = [Error_Rsp parseFromData:errorData error:nil];
                    if (rsp.errorCode == 101 || rsp.errorCode == 102) {
                        errorBlock(rsp.errorCode);
                    } else {
                        NSDictionary *dic = [PBHelper getErrorDic];
                        NSString *desc = [dic objectForKey:[NSString stringWithFormat:@"%d",rsp.errorCode]];
                        // 需要重新登录
                        if (rsp.errorCode == 105) {
                        }
                    }
                } else {
                    // 正常数据
                    dataBlock([data subdataWithRange:NSMakeRange(12, data.length-12)]);
                }
                if ((int)data.length-8-i > 0) {
                    // 附加信息
                    [PBHelper handleResponseAdditional:[data subdataWithRange:NSMakeRange(8+i, data.length-8-i)]];
                }
            } else {
                dataBlock(nil);
            }
        }
    }];
    [task resume];
}

@end
