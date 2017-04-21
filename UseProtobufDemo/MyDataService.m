//
//  MyDataService.m
//  01 NavigationTask
//
//  Created by wei.chen on 14-9-5.
//  Copyright (c) 2014年 www.iphonetrain.com 无限互联3G学院. All rights reserved.
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
        _manager.operationQueue.maxConcurrentOperationCount = 8;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        _manager.securityPolicy = [MyDataService customSecurityPolicy];
//        [self setHTTPHeaderField];
    }
    return self;
}

- (void)requestAFNURL:(NSString *)urlstring
          httpMethod:(NSString *)method
              params:(NSMutableDictionary *)params
                data:(NSMutableDictionary *)datas
         complection:(void(^)(NSDictionary *result))block {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if ([method isEqualToString:@"GET"]) {
        
        [_manager GET:urlstring parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"%lf",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            block(responseDic);
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            block(nil);
            NSLog(@"error : %@", error);
        }];
        
    }else if([method isEqualToString:@"POST"]) {
        //判断是否有文件需要上传
        if (datas != nil) {
            //上传文件的POST请求
            [_manager POST:urlstring parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                //将需要上传的文件数据添加到formData
                //循环遍历需要上的文件数据
                for (NSString *name in datas) {
                    NSData *data = datas[name];
                    [formData appendPartWithFileData:data name:name fileName:name mimeType:@"image/jpeg"];
                }
            } progress:^(NSProgress * _Nonnull uploadProgress) {
                
                NSLog(@"%lf",1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                
                block(responseDic);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                block(nil);
                NSLog(@"error : %@", error);
            }];
            
        }else{
            [_manager POST:urlstring parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
                block(responseDic);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                
                block(nil);
                NSLog(@"error : %@", error);
            }];
        }
    }
}

- (void)requestProtobufCommandId:(int)commandId
                          params:(NSData *)params
                        playerId:(uint64_t)playerId
                       sessionId:(uint64_t)sessionId
                    successBlock:(void(^)(NSData *result))success
                    failureBlock:(void(^)())failure{
    
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
    playerId = htonll(playerId);
    NSData *playerIdData = [NSData dataWithBytes: &playerId length: sizeof(playerId)];
    [protobufData appendData:playerIdData];
    // sessionId
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
//    for (int i=0 ; i<[protobufData length]; i++) {
//        NSLog(@"%d",byte[i]);
//    }
    
    //第一步，创建url
    NSURL *url = [NSURL URLWithString:baseProUrl];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:protobufData];
    //第三步，连接服务器
    NSURLSessionDataTask *task = [_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error){
            NSLog(@"error = %@",error);
            failure();
        }else{
            NSLog(@"protobuf data = %@", responseObject);
            
            NSData *data = (NSData*)responseObject;
            NSData *prodata = [data subdataWithRange:NSMakeRange(12, data.length-12)];
            success(prodata);
        }
    }];
    [task resume];
}

- (void)downloadURLArr:(NSArray *)urlArr
            saveFolder:(NSString *)folderName
       saveNameListArr:(NSMutableArray *)nameListArr
               success:(void (^)(NSString *result))successBlock
                  fail:(void (^)(NSError *))failBlock {

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    __block NSURLSessionDownloadTask *downloadTask;
    __block NSInteger successCount = 0;
    
    for (int i = 0; i < urlArr.count; i++) {

        NSURL *URL = [NSURL URLWithString:[urlArr objectAtIndex:i]];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            //        float nowDownload = 1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSURL *documentsDirectoryURL = [[[[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:@"NewImage"] URLByAppendingPathComponent:folderName];
            NSString *subStr = [NSString stringWithFormat:@"%@.%@", [nameListArr objectAtIndex:i], [[urlArr objectAtIndex:i] substringFromIndex:[[urlArr objectAtIndex:i] length]-3]];
            return [documentsDirectoryURL URLByAppendingPathComponent:subStr];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            /* 判断是否下载异常 */
            if (error != nil) {
                /* 停止下载,重新进入下载方法 */
                [downloadTask cancel];
                failBlock(error);
            } else {
                successCount++;
                /* 向键盘发送完成下载的通知 */
                if (successCount == urlArr.count) {
                    successBlock(@"success");
//                    NSLog(@"路径 %@", filePath);
                }
            }
        }];
        [downloadTask resume];
    }
}

/// 添加 请求头
-(void)setHTTPHeaderField{
    //    [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [_manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [_manager.requestSerializer setValue:@"com.chaojihudong" forHTTPHeaderField:@"bundleIdentifier"];
//    [_manager.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"os"];
//    [_manager.requestSerializer setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"osVersion"];
//    
//    [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@%@",@"v",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"version"];
//    [_manager.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forHTTPHeaderField:@"build"];
}

/// 支持https
+ (AFSecurityPolicy *)customSecurityPolicy
{
    /** 单向验证
     //在你封装的网络工具类请求前初始化时增加以下代码
     AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
     //设置证书模式，AFSSLPinningModeNone，代表前端包内不验证
     //在单向认证时，前端不放证书，服务器去验证
     AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
     // 如果是需要服务端验证证书，需要设置为YES
     securityPolicy.allowInvalidCertificates = YES;
     //validatesDomainName 是否需要验证域名，默认为YES；
     securityPolicy.validatesDomainName = NO;
     //设置验证模式
     manager.securityPolicy = securityPolicy;
     */
    
    // 双向验证
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"你的证书名字" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    
    return securityPolicy;
}
@end
