//
//  WXChangeInfoToolBar.h
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  零钱 Info 底部

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXChangeInfoToolBar : UIView

@property (nonatomic, copy) void (^buttonClickedHandler) (NSInteger index);

@end

NS_ASSUME_NONNULL_END
