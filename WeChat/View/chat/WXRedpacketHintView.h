//
//  WXRedpacketHintView.h
//  WeChat
//
//  Created by Vincent on 2019/6/17.
//  Copyright © 2019 Vincent. All rights reserved.
//  红包超额提示视图

#import <UIKit/UIKit.h>

@interface WXRedpacketHintView : UILabel

@property (nonatomic) BOOL visible;

- (void)setVisible:(BOOL)visible animated:(BOOL)animated;

@end
