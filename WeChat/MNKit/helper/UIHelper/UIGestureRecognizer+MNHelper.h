//
//  UIGestureRecognizer+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (MNHelper)

UITapGestureRecognizer *UITapGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate);

UIPanGestureRecognizer *UIPanGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate);

UIPinchGestureRecognizer *UIPinchGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate);

UILongPressGestureRecognizer *UILongPressGestureRecognizerCreate (id target, NSTimeInterval duration, SEL action, id<UIGestureRecognizerDelegate> delegate);

@end

