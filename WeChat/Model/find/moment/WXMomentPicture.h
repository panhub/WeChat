//
//  WXMomentPicture.h
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈配图

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXMomentPicture : NSObject <NSCopying, NSSecureCoding>
/**
 标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 图片
 */
@property (nonatomic, strong) NSData *data;
/**
 图片
 */
@property (nonatomic, readonly, strong) UIImage *image;

- (instancetype)initWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
