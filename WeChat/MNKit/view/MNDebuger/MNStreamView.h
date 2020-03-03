//
//  MNStreamView.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/22.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  网络用量显示

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNStreamViewState) {
    MNStreamViewStateNormal = 0,
    MNStreamViewStateDraging,
    MNStreamViewStateAnimating
};

UIKIT_EXTERN const CGFloat MNStreamViewAnimationDuration;

@interface MNStreamView : UIView

@property (nonatomic, readonly) MNStreamViewState state;

- (void)show;

- (void)dismiss;

@end

