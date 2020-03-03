//
//  WXMapHeaderView.h
//  MNChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WXMapHeaderView;

@protocol WXMapHeaderViewDelegate <NSObject>
@required
- (void)headerViewClickedEvent:(WXMapHeaderView *)headerView;
- (void)headerView:(WXMapHeaderView *)headerView buttonClickedEvent:(UIButton *)sender;
@end

@interface WXMapHeaderView : UIView

@property (nonatomic, weak) id<WXMapHeaderViewDelegate> delegate;

@property (nonatomic, copy) NSString *text;

@end
