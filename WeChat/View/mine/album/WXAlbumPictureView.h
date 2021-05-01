//
//  WXAlbumPictureView.h
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册图片集合视图

#import <UIKit/UIKit.h>
@class WXMonthViewModel, WXProfile;

@interface WXAlbumPictureView : UIView

/**视图模型*/
@property (nonatomic, strong) WXMonthViewModel *viewModel;

/**图片点击回调*/
@property (nonatomic, copy) void (^touchEventHandler) (WXProfile *);

@end
