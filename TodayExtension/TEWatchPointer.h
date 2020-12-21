//
//  WXWatchPointer.h
//  MNChat
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  钟表指针

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TEWatchPointerType) {
    TEWatchPointerHour = 0,
    TEWatchPointerMinute
};

@interface TEWatchPointer : UIView

@property (nonatomic) TEWatchPointerType type;

@end
