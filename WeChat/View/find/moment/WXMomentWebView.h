//
//  WXMomentWebView.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  网页视图

#import <UIKit/UIKit.h>
@class WXWebpage;

@interface WXMomentWebView : UIView

/**文字信息*/
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/**网页数据模型*/
@property (nonatomic, strong) WXWebpage *webpage;

@end
