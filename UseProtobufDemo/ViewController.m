//
//  ViewController.m
//  UseProtobufDemo
//
//  Created by pzk on 17/4/21.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import "ViewController.h"
#import "MyDataService.h"
#import "PBHelper.h"

@interface Model : NSObject

@property (nonatomic, copy) NSString *resultStr;
@property (nonatomic, assign) int64_t resultNum;

@end

@implementation Model

#pragma mark- Map
+ (NSDictionary *)replacedPropertyKeypathsForProtobuf {
    return @{@"resultStr" : @"result1",
             @"resultNum" : @"result2"};
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 使用前请修改ProtobufIP
    Test_Req *req = [Test_Req new];
    req.param1 = @"0";
    req.param2 = 1;
    [[MyDataService sharedService] requestProtobufCommandId:CommandEnum_CmdTest                            params:[req data] playerId:0 sessionId:0 completionHandler:^(NSData *data) {
        if (data) {
            Test_Rsp *rsp = [Test_Rsp parseFromData:data error:nil];
            NSLog(@"rsp: %@\n result1: %@\n result2: %lld", rsp, rsp.result1, rsp.result2);
            
            Model *model = [[Model alloc] init];
            [model setupWithObject:rsp];
            NSLog(@"model: %@",model);
            
            Model *model2 = [Model instanceWithProtoObject:rsp];
            [model2 log];
        }
    } errorHandler:^(int32_t errorCode) {
        NSLog(@"errorCode: %d",errorCode);
    }];
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
    uint64_t playerId = 0;
    playerId = htonll(playerId);
    NSData *playerIdData = [NSData dataWithBytes: &playerId length: sizeof(playerId)];
    [protobufData appendData:playerIdData];
    // sessionId
    uint64_t sessionId = 0;
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
    
    Byte *byte = (Byte *)[protobufData bytes];
    NSString *byteString = @"";
    for (int i=0 ; i<[protobufData length]; i++) {
        [byteString stringByAppendingString:[NSString stringWithFormat:@"%c ",byte[i]]];
    }
    NSLog(@"byte: %@",byteString);
    
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:@"1.1.1.1:8080"];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:protobufData];
    //第三步，连接服务器
    AFHTTPSessionManager *_manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask *task = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error){
            NSLog(@"error = %@",error);
            dataBlock(nil);
        }else{
            NSLog(@"protobuf data = %@", responseObject);
            
            NSData *data = responseObject;
            if (data.length > 12) {
                // normal data
                dataBlock([data subdataWithRange:NSMakeRange(12, data.length-12)]);
            } else {
                dataBlock(nil);
            }
        }
    }];
    [task resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
