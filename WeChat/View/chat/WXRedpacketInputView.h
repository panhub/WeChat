//
//  WXRedpacketInputView.h
//  WeChat
//
//  Created by Vincent on 2019/5/22.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包金额输入区

#import <UIKit/UIKit.h>
@class WXRedpacketInputView;

@protocol WXRedpacketInputViewDelegate <NSObject>

- (void)inputView:(WXRedpacketInputView *)inputView didChangeText:(NSString *)text;

@end

@interface WXRedpacketInputView : UIView

@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, weak) id<WXRedpacketInputViewDelegate> delegate;

@end
