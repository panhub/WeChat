//
//  WXBankCardFooterView.h
//  MNChat
//
//  Created by Vincent on 2019/6/5.
//  Copyright © 2019 Vincent. All rights reserved.
//  银行卡 - 添加银行卡

#import <UIKit/UIKit.h>

@interface WXBankCardFooterView : UIView

@property (nonatomic, copy) void (^didClickedHandler) (NSInteger type);

@end
