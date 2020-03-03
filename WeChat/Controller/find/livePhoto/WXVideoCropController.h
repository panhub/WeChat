//
//  WXVideoCropController.h
//  ZiMuKing
//
//  Created by Vincent on 2019/12/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频裁剪控制器

#import "MNExtendViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXVideoCropController : MNExtendViewController
/**
 实例化视频裁剪控制器
 @param filePath 视频路径
 @return 视频裁剪实例
 */
- (instancetype)initWithContentsOfFile:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
