//
//  WXPayHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//  支付头部视图<收付款, 钱包>

#import <UIKit/UIKit.h>
@class WXPayHeaderView;

@protocol WXPayHeaderViewDelegate <NSObject>

- (void)headerView:(WXPayHeaderView *)headerView didSelectButtonAtIndex:(NSInteger)index;

@end

@interface WXPayHeaderView : UIView

@property (nonatomic, weak) id<WXPayHeaderViewDelegate> delegate;

@end
