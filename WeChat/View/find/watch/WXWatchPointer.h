//
//  WXWatchPointer.h
//  WeChat
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  钟表指针

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNWatchPointerType) {
    MNWatchPointerHour = 0,
    MNWatchPointerMinute
};

@interface WXWatchPointer : UIView

@property (nonatomic) MNWatchPointerType type;

@end
