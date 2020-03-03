//
//  SESessionView.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//  分享会话视图

#import <UIKit/UIKit.h>
#import "SESession.h"

@protocol SESessionViewDelegate <NSObject>
@optional;
- (void)sessionViewDidSelectSession:(SESession *)session;
@end

@interface SESessionView : UIView

/**事件代理*/
@property (nonatomic, weak) id<SESessionViewDelegate> delegate;

@end
