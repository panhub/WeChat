//
//  WXVideoPlayController.h
//  WeChat
//
//  Created by Vincent on 2019/6/17.
//  Copyright © 2019 Vincent. All rights reserved.
//  视频播放控制器

#import "MNBaseViewController.h"

@interface WXVideoPlayController : MNBaseViewController

- (instancetype)initWithURL:(NSURL *)URL;

- (instancetype)initWithItems:(NSArray <NSURL *>*)items;

@end

