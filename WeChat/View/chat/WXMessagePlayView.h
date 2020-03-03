//
//  WXMessagePlayView.h
//  MNChat
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天消息进度视图

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WXMessagePlayViewType) {
    WXMessagePlayViewNormal = 0,
    WXMessagePlayViewUpdating
};


@interface WXMessagePlayView : UIView

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, assign) WXMessagePlayViewType type;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
