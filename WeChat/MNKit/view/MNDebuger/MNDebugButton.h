//
//  MNDebugButton.h
//  MNKit
//
//  Created by Vincent on 2019/9/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  调试按钮

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNDebugButtonType) {
    MNDebugButtonTypeMain = 0,
    MNDebugButtonTypeLog,
    MNDebugButtonTypeFPS,
    MNDebugButtonTypeStream
};

UIKIT_EXTERN const CGFloat MNDebugButtonWH;
UIKIT_EXTERN const CGFloat MNDebugAnimationDuration;

@interface MNDebugButton : UIControl

@property (nonatomic, readonly) MNDebugButtonType type;

+ (instancetype)buttonWithType:(MNDebugButtonType)type;

- (void)makeTitleHidden;

- (void)show;

@end
