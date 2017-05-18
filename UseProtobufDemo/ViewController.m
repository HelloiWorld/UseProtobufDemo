//
//  ViewController.m
//  UseProtobufDemo
//
//  Created by pzk on 17/4/21.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import "ViewController.h"
#import "MyDataService.h"
#import "SocketManager.h"
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

@interface ViewController () <SocketManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Http+Protobuf的使用方法
//    [self connectHttp];
    // Socket+Protobuf的调用方法
    [self connectSocket];
}

#pragma mark- Http
- (void)connectHttp {
    //FIXME: ?使用前请修改ProtobufIP
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

#pragma mark- Socket
- (void)connectSocket {
    [[SocketManager sharedInstance] connect];
    [SocketManager sharedInstance].delegate = self;
}

#pragma mark- SocketManager Delegate
- (void)receiveProtobufData:(NSData *)data {
    NSLog(@"receive protobuf data:%@",data);
    NSData *cmdIdData = [data subdataWithRange:NSMakeRange(8, 4)];
    int j;
    [cmdIdData getBytes: &j length: sizeof(j)];
    j = htonl(j);
    
    NSData *sizeData = [data subdataWithRange:NSMakeRange(4, 4)];
    int i;
    [sizeData getBytes: &i length: sizeof(i)];
    i = htonl(i);
    if (j == CommandEnum_CmdSystemLogout) {
        NSLog(@"系统退出,连接断开");
    } else if (j == CommandEnum_CmdHeartBeat){
        NSLog(@"代理前拦截，这里是收不到心跳包的");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
