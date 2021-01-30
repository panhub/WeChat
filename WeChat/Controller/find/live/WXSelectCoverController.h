//
//  WXSelectCoverController.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//  选择封面

#import "MNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXSelectCoverController : MNBaseViewController

/**指定视频路径*/
@property (nonatomic, copy) NSString *videoPath;

/**截图*/
@property (nonatomic, copy) UIImage *thumbnail;

/**指定视频时长*/
@property (nonatomic) NSTimeInterval duration;

/**指定视频尺寸*/
@property (nonatomic) CGSize naturalSize;

/**指定视频裁剪后保存位置*/
@property (nonatomic, copy, nullable) NSString *outputPath;


- (instancetype)initWithVideoPath:(NSString *)videoPath;

@end

NS_ASSUME_NONNULL_END
