//
//  MNURLResponse.h
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求结果

#import <Foundation/Foundation.h>
@class MNURLRequest;

typedef NS_ENUM(NSInteger, MNURLResponseCode) {
    MNURLResponseCodeUnknown = -1,
    MNURLResponseCodeFailed = 0,
    MNURLResponseCodeSucceed = 1,
    MNURLResponseCodeDataEmpty = 2,
    MNURLResponseCodeTimeout = -1001,
    MNURLResponseCodeUnsupportedURL = -1002,
    MNURLResponseCodeCannotFindHost = -1003,
    MNURLResponseCodeCannotConnectHost = -1004,
    MNURLResponseCodeNotConnectToInternet = -1009,
    MNURLResponseCodeNotFound = 20901 
};

@interface MNURLResponse : NSObject<NSCopying>
/**数据*/
@property (nonatomic, strong) id data;
/**记录此次请求体*/
@property (nonatomic, readonly, weak) __kindof MNURLRequest *request;
/**响应码*/
@property (nonatomic, assign) MNURLResponseCode code;
/**信息*/
@property (nonatomic, copy) NSString *message;
/**原错误信息*/
@property (nonatomic, strong) NSError *error;

/**
 响应体快速实例化
 @param code 响应码
 @param data 请求数据
 @param message 响应信息
 @param error 请求错误
 @return 响应实例
 */
+ (MNURLResponse *)responseWithCode:(MNURLResponseCode)code
                               data:(id)data
                            message:(NSString *)message
                              error:(NSError *)error;

/**
 失败响应体
 @param error 错误
 @return 响应实例
 */
+ (MNURLResponse *)responseWithError:(NSError *)error;

/**
 成功响应体
 @param data 数据
 @return 响应实例
 */
+ (MNURLResponse *)succeedResponseWithData:(id)data;

@end

