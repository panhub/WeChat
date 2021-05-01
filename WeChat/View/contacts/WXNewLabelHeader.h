//
//  WXNewLabelHeader.h
//  WeChat
//
//  Created by Vicent on 2021/3/30.
//  Copyright © 2021 Vincent. All rights reserved.
//  新建标签

#import "MNAdsorbView.h"
@class WXNewLabelHeader;

NS_ASSUME_NONNULL_BEGIN

@protocol WXNewLabelHeaderDelegate <NSObject>
/**设置名字*/
- (void)newLabelHeaderNameButtonTouchUpInside:(WXNewLabelHeader *)newLabelHeader;
/**选择用户*/
- (void)newLabelHeaderAddUserButtonTouchUpInside:(WXNewLabelHeader *)newLabelHeader;
@end

@interface WXNewLabelHeader : MNAdsorbView

/**标签名*/
@property (nonatomic, copy) NSString *name;

/**成员数量*/
@property (nonatomic) NSInteger number;

/**事件代理*/
@property (nonatomic, weak) id<WXNewLabelHeaderDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
