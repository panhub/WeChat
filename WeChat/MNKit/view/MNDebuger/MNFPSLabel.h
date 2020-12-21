//
//  MNFPSLabel.h
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  屏幕刷新率调试

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNFPSLabelState) {
    MNFPSLabelStateNormal = 0,
    MNFPSLabelStateDraging,
    MNFPSLabelStateAnimating
};

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const CGFloat MNFPSLabelAnimationDuration;

@interface MNFPSLabel : UILabel

@property (nonatomic, readonly) int fps;

@property (nonatomic, readonly) MNFPSLabelState state;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
