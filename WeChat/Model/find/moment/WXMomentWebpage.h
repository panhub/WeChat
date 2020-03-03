//
//  WXMomentWebpage.h
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈分享模型 

#import <Foundation/Foundation.h>
#import "WXMomentPicture.h"

@interface WXMomentWebpage : NSObject<NSCopying>
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 标题
 */
@property (nonatomic, copy) NSString *title;
/**
 图片标识
 */
@property (nonatomic, copy) NSString *img;
/**
 链接
 */
@property (nonatomic, copy) NSString *url;
/**
 图片
 */
@property (nonatomic, readonly, strong) WXMomentPicture *picture;
/**
 是否是视频
 */
@property (nonatomic, getter=isVideo) BOOL video;

@end
