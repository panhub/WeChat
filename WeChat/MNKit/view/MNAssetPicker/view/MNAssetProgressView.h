//
//  MNAssetProgressView.h
//  MNKit
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源下载进度视图

#import <UIKit/UIKit.h>

@interface MNAssetProgressView : UIView

@property (nonatomic) double progress;

- (void)setProgress:(double)progress animated:(BOOL)animated;

@end
