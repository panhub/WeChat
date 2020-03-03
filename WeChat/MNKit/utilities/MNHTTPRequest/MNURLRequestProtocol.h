//
//  MNURLRequestProtocol.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNURLResponse;

@protocol MNURLRequestProtocol <NSObject>
/**
 加载结束, 回调结果
 @param responseObject 请求到的数据
 @param error 错误信息
 */
- (void)didLoadFinishWithResponseObject:(id)responseObject error:(NSError *)error;

/**
 关于响应的重新定义
 @param response 响应者
 */
- (void)didLoadFinishWithResponse:(MNURLResponse *)response;

/**
 解析数据
 @param responseObject 数据信息
 */
- (void)didLoadSucceedWithResponseObject:(id)responseObject;

@end

