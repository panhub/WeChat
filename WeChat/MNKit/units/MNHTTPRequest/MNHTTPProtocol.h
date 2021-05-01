//
//  MNHTTPProtocol.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNURLResponse, MNURLRequest, MNURLDownloadRequest, MNURLUploadRequest;

NS_ASSUME_NONNULL_BEGIN
#pragma mark - 请求体默认遵循此协议 实现定义方法
@protocol MNHTTPProtocol <NSObject>
@optional
/**
 加载结束, 回调结果
 @param responseObject 请求到的数据
 @param error 错误信息
 */
- (void)didFinishWithResponseObject:(id _Nullable)responseObject error:(NSError *_Nullable)error;
/**
 关于响应的重新定义
 @param response 响应者
 */
- (void)didFinishWithSupposedResponse:(MNURLResponse *)response;
/**
 解析数据
 @param responseObject 数据信息
 */
- (void)didSucceedWithResponseObject:(id)responseObject;
@end

#pragma mark - 请求事件代理
@protocol MNURLRequestDelegate <NSObject>
@optional
/**
 请求开始
 @param request 请求体
 */
- (void)didStartRequesting:(MNURLRequest *)request;
/**
 请求结束定制响应信息
 @param request 请求体
 @param response 响应体
 */
- (void)didFinishRequesting:(MNURLRequest *)request supposedResponse:(MNURLResponse *)response;
/**
 请求成功
 @param request 请求体
 @param responseObject 请求数据
 */
- (void)didSucceedRequesting:(MNURLRequest *)request responseObject:(id)responseObject;
/**
 请求结束
 @param request 请求体
 @param response 响应体
 */
- (void)didFinishRequesting:(MNURLRequest *)request response:(MNURLResponse *)response;
/**
 询问关于缓存操作的key
 @param request 请求体
 @return 缓存操作的key
 */
- (NSString *_Nullable)requestCacheForUrl:(MNURLRequest *)request;
@end

#pragma mark - 下载事件代理
@protocol MNURLDownloadDelegate <MNURLRequestDelegate>
/**
 询问文件保存路径
 @param request 请求体
 @param response 响应信息
 @param location 缓存位置
 @return 文件保存路径<NSString, NSURL>
 */
- (id)downloadRequest:(MNURLDownloadRequest *)request didStopWithResponse:(NSURLResponse *)response location:(NSURL *)location;
@optional
/**
 下载进度
 @param request 请求体
 @param progress 进度信息
 */
- (void)downloadRequest:(MNURLDownloadRequest *)request didDownloading:(NSProgress *)progress;
@end

#pragma mark - 上传事件代理
@protocol MNURLUploadDelegate <MNURLRequestDelegate>
@optional
/**
 询问上传内容
 @param request 请求体
 @return 上传内容<NSString, NSURL, NSData>
 */
- (id)uploadRequestBody:(MNURLUploadRequest *)request;
/**
 上传进度
 @param request 请求体
 @param progress 进度信息
 */
- (void)uploadRequest:(MNURLUploadRequest *)request didUploading:(NSProgress *)progress;
@end
NS_ASSUME_NONNULL_END
