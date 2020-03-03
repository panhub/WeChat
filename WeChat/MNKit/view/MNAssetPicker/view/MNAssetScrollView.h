//
//  MNAssetScrollView.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/10.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  资源浏览器内容视图

#import <UIKit/UIKit.h>

@interface MNAssetScrollView : UIScrollView

@property (nonatomic, readonly, strong) UIView *contentView;

- (void)reset;

@end
