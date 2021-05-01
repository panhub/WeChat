//
//  MNRotationGestureRecognizer.h
//  MNKit
//
//  Created by Vincent on 2019/7/2.
//  Copyright © 2019 AiZhe. All rights reserved.
//  单指旋转手势

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNRotationGestureRecognizer : UIGestureRecognizer

@property (nonatomic)  CGFloat rotation;

@end

NS_ASSUME_NONNULL_END
