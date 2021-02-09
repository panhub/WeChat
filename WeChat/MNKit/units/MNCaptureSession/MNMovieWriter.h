//
//  MNMovieWriter.h
//  WeChat
//
//  Created by Vicent on 2021/2/9.
//  Copyright © 2021 Vincent. All rights reserved.
//  视频文件写入

#import <Foundation/Foundation.h>
@class MNMovieWriter;

NS_ASSUME_NONNULL_BEGIN

@protocol MNMovieWriteDelegate <NSObject>
@required
/**开始写入视频*/
- (void)movieWriterDidStartWriting:(MNMovieWriter *)movieWriter;
/**视频写入结束*/
- (void)movieWriterDidFinishWriting:(MNMovieWriter *)movieWriter;
/**视频写入出错*/
- (void)movieWriter:(MNMovieWriter *)movieWriter didFailWithError:(NSError *)error;
@end

@interface MNMovieWriter : NSObject

/**本地文件路径*/
@property (nonatomic, copy) NSURL *URL;

/**事件代理*/
@property (nonatomic, weak, nullable) id<MNMovieWriteDelegate> delegate;

/**
 视频写入者
 @param URL 视频路径
 @param delegate 事件代理
 @return 视频写入实例
 */
- (instancetype)initWithURL:(NSURL *)URL delegate:(id<MNMovieWriteDelegate>)delegate;

/**即将开始写入视频*/
- (void)prepareToWriting;

@end

NS_ASSUME_NONNULL_END
