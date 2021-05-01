//
//  MNStreamView.h
//  MNKit
//
//  Created by Vincent on 2019/9/22.
//  Copyright © 2019 Vincent. All rights reserved.
//  网络用量显示

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNStreamViewState) {
    MNStreamViewStateNormal = 0,
    MNStreamViewStateDraging,
    MNStreamViewStateAnimating
};

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN const CGFloat MNStreamViewAnimationDuration;

@interface MNStreamView : UIView

@property (nonatomic, readonly) MNStreamViewState state;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
