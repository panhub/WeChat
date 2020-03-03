//
//  WXChatMoreInputView.h
//  MNChat
//
//  Created by Vincent on 2019/3/31.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天更多输入视图

#import <UIKit/UIKit.h>
@class WXChatMoreInputView;

typedef NS_ENUM(NSInteger, WXChatInputMoreType) {
    WXChatInputMorePhoto = 0,
    WXChatInputMoreCapture,
    WXChatInputMoreCall,
    WXChatInputMoreLocation,
    WXChatInputMoreRedpacket,
    WXChatInputMoreTransfer,
    WXChatInputMoreCard,
    WXChatInputMoreFavorites
};

@protocol WXChatMoreInputDelegate <NSObject>
@required
- (void)moreInputView:(WXChatMoreInputView *)inputView didSelectButtonAtIndex:(NSInteger)index;
@end

@interface WXChatMoreInputView : UIView

@property (nonatomic, weak) id<WXChatMoreInputDelegate> delegate;

@end
