//
//  ResponseModel.h
//  UseProtobufDemo
//
//  Created by PengZK on 2018/5/9.
//  Copyright © 2018年 Aone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseModel : NSObject

@property (nonatomic, assign) int sizeLength;

@property (nonatomic, assign) int cmdId;

@property (nonatomic, strong) NSData *data;

@end
