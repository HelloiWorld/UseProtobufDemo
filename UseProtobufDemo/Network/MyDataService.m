//
//  MyDataService.m
//
//  Created by pzk on 17-4-21.
//  Copyright (c) 2017年 Aone. All rights reserved.
//

#import "MyDataService.h"
#import <AFNetworking.h>
#import "PBHelper.h"
#import "ResponseModel.h"

static NSString *const Protobuf_IP = @"http://127.0.0.1:8080";    // Ptotobuf

@interface MyDataService ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation MyDataService

static MyDataService *shareInstance = nil;
+ (MyDataService *)sharedService {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[MyDataService alloc] init];
    });
    return shareInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [super allocWithZone:zone];
    });
    return shareInstance;
}

+ (id)copyWithZone:(struct _NSZone *)zone{
    return shareInstance;
}

#pragma mark - Constructors
- (instancetype)init{
    self = [super init];
    if (self) {
        _manager = [AFHTTPSessionManager manager];
//        NSURL *baseURL = [NSURL URLWithString: Protobuf_IP];
//        NSURLSessionConfiguration *sessionCfg = [NSURLSessionConfiguration defaultSessionConfiguration];
//        sessionCfg.timeoutIntervalForRequest = 8000;
//        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL: baseURL sessionConfiguration:sessionCfg];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
                        playerId:(uint64_t)playerID
                       sessionId:(uint64_t)sessionID
               completionHandler:(void(^)(NSData *data))dataBlock
                    errorHandler:(void(^)(int32_t errorCode))errorBlock {
    
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
    uint64_t playerId = playerID;
    playerId = htonll(playerId);
    NSData *playerIdData = [NSData dataWithBytes: &playerId length: sizeof(playerId)];
    [protobufData appendData:playerIdData];
    // sessionId
    uint64_t sessionId = sessionID;
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
//        byteString = [byteString stringByAppendingString:[NSString stringWithFormat:@"%d ",byte[i]]];
//    }
//    NSLog(@"byte: %@",byteString);

    //第一步，创建url
    NSURL *url = [NSURL URLWithString:Protobuf_IP];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:protobufData];
    //第三步，连接服务器
    NSURLSessionDataTask *task = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error){
            NSLog(@"error = %@",error);
            dataBlock(nil);
        }else{
//            NSLog(@"protobuf data = %@", responseObject);
            
            NSData *data = responseObject;
            /**
             *  这里数据有两种情况,可选附加信息一般为全局事件，如资源变更
             *  正常+(附加)
             *  错误+(附加)
             */
            
            // 如果不需要考虑 错误 以及 有拼接 的情况，这里直接返回正常信息的data就行
            ResponseModel *rspModel = [PBHelper parseResponseObject:data];
            if (rspModel.cmdId == CommandEnum_CmdError) {
                Error_Rsp *rsp = [Error_Rsp parseFromData:rspModel.data error:nil];
                errorBlock(rsp.errorCode);
                // 显示提示信息
                NSString *desc = [[PBHelper getErrorDic] objectForKey:[NSString stringWithFormat:@"%d",rsp.errorCode]];
                NSLog(@"%@",desc);
            } else {
                // 正常数据
                dataBlock(rspModel.data);
            }
            // Optional method，you may handle additional info sometimes
            if (data.length-8-rspModel.sizeLength > 0) {
                // 处理附加信息
                [PBHelper handleResponseAdditional:[data subdataWithRange:NSMakeRange(8+rspModel.sizeLength, data.length-8-rspModel.sizeLength)]];
            }
        }
    }];
    [task resume];
}

@end
