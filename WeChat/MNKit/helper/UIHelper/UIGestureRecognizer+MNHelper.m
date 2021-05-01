//
//  UIGestureRecognizer+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/11/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIGestureRecognizer+MNHelper.h"

@implementation UIGestureRecognizer (MNHelper)

inline UITapGestureRecognizer *UITapGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate)
{
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] init];
    recognizer.numberOfTapsRequired = 1;
    if (target && action) [recognizer addTarget:target action:action];
    if (delegate) recognizer.delegate = delegate;
    return recognizer;
}

inline UIPanGestureRecognizer *UIPanGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate)
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]init];
    recognizer.maximumNumberOfTouches = 1;
    if (target && action) [recognizer addTarget:target action:action];
    if (delegate) recognizer.delegate = delegate;
    return recognizer;
}

inline UIPinchGestureRecognizer *UIPinchGestureRecognizerCreate (id target, SEL action, id<UIGestureRecognizerDelegate> delegate)
{
    UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc]init];
    recognizer.scale = [[UIScreen mainScreen] scale];
    if (target && action) [recognizer addTarget:target action:action];
    if (delegate) recognizer.delegate = delegate;
    return recognizer;
}

inline UILongPressGestureRecognizer *UILongPressGestureRecognizerCreate (id target, NSTimeInterval duration, SEL action, id<UIGestureRecognizerDelegate> delegate)
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] init];
    recognizer.minimumPressDuration = duration;
    if (target && action) [recognizer addTarget:target action:action];
    if (delegate) recognizer.delegate = delegate;
    return recognizer;
}

@end
