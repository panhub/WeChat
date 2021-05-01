//
//  WXMomentPicture.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈单张配图

#import <UIKit/UIKit.h>
@class WXProfile;

@interface WXMomentPicture : UIImageView

/**数据源*/
@property (nonatomic, strong) WXProfile *picture;

/**播放按钮*/
@property (nonatomic, readonly) UIImageView *badgeView;

@end
