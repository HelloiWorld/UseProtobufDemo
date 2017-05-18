//
//  SocketManager.m
//  TestProtobufSocket
//
//  Created by pzk on 17/5/17.
//  Copyright © 2017年 Aone. All rights reserved.
//

#import "SocketManager.h"
#import "GCDAsyncSocket.h" // for TCP
#import "PBHelper.h"

static NSString *kHost = @"10.0.1.144";
static const uint16_t kPort = 10002;

@interface SocketManager () <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *gcdSocket;
}

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation SocketManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SocketManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        [instance initSocket];
    });
    return instance;
}

- (void)initSocket {
    gcdSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - 对外的一些接口
//建立连接
- (BOOL)connect {
    return [gcdSocket connectToHost:kHost onPort:kPort error:nil];
}

//断开连接
- (void)disConnect {
    [self systemLogout];
    [gcdSocket disconnect];
    [_timer invalidate];
}

//系统退出
- (void)systemLogout {
    Empty_Req *req = [Empty_Req new];
    [self sendProbufData:[req data] CommandId:CommandEnum_CmdSystemLogout];
}

//发送消息
//- (void)sendMsg:(NSString *)msg {
//    NSData *data  = [msg dataUsingEncoding:NSUTF8StringEncoding];
//    //第二个参数，请求超时时间
//    [gcdSocket writeData:data withTimeout:-1 tag:110];
//}

//监听最新的消息
- (void)pullTheMsg {
    //监听读数据的代理  -1永远监听，不超时，但是只收一次消息，
    //所以每次接受到消息还得调用一次
    [gcdSocket readDataWithTimeout:-1 tag:110];
}

//发送数据流和协议号
- (void)sendProbufData:(NSData *)data
             CommandId:(int)commandId {
    NSMutableData *protobufData = [[NSMutableData alloc] init];
    // 0XFF
    int str = 0xff;
    str = htonl(str);
    [protobufData appendBytes:&str length:sizeof(str)];
    // size
    u_long size = data.length+4;
    size = htonl(size);
    [protobufData appendBytes:&size length:4];
    // commandId
    commandId = htonl(commandId);
    NSData *commandIdData = [NSData dataWithBytes: &commandId length: sizeof(commandId)];
    [protobufData appendData:commandIdData];
    // data
    [protobufData appendData:data];
    
    Byte *byte = (Byte *)[protobufData bytes];
    NSString *byteString = @"";
    for (int i=0 ; i<[protobufData length]; i++) {
        byteString = [byteString stringByAppendingString:[NSString stringWithFormat:@"%d ",byte[i]]];
    }
    NSLog(@"byteString: %@",byteString);
    
    [gcdSocket writeData:protobufData withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
//连接成功调用
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"连接成功,host:%@,port:%d",host,port);
    
    [self pullTheMsg];
    
    //心跳写在这...
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:90 target:self selector:@selector(heartBeat) userInfo:nil repeats:YES];
    }
}

- (void)heartBeat {
    Empty_Req *req = [Empty_Req new];
    [self sendProbufData:[req data] CommandId:CommandEnum_CmdHeartBeat];
}

//断开连接的时候调用
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"断开连接,host:%@,port:%d",sock.localHost,sock.localPort);
    
    //断线重连写在这...
    //再次可以重连
    if (err) {
        [self connect];
    }else{
        //正常断开
    }
}

//写成功的回调
- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag {
//    NSLog(@"写的回调,tag:%ld",tag);
}

//收到消息的回调
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"收到消息：%@",data);
    if (data.length > 12) {
        NSData *cmdIdData = [data subdataWithRange:NSMakeRange(8, 4)];
        int j;
        [cmdIdData getBytes: &j length: sizeof(j)];
        j = htonl(j);
        
        NSData *sizeData = [data subdataWithRange:NSMakeRange(4, 4)];
        int i;
        [sizeData getBytes: &i length: sizeof(i)];
        i = htonl(i);
        if (j == CommandEnum_CmdHeartBeat) {
            // 心跳包不做处理
            NSLog(@"收到了心跳包!");
        } else {
            if ([self.delegate respondsToSelector:@selector(receiveProtobufData:)]) {
                [self.delegate receiveProtobufData:data];
            }
        }
    }
    
    [self pullTheMsg];
}

//分段去获取消息的回调
//- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag {
//    NSLog(@"读的回调,length:%ld,tag:%ld",partialLength,tag);
//}
//
//为上一次设置的读取数据代理续时 (如果设置超时为-1，则永远不会调用到)
//-(NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
//    NSLog(@"来延时，tag:%ld,elapsed:%f,length:%ld",tag,elapsed,length);
//    return 10;
//}

@end
