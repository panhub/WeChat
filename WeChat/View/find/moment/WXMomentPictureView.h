//
//  WXMomentPictureView.h
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈九宫格配图 

#import <UIKit/UIKit.h>
@class WXProfile;

@interface WXMomentPictureView : UIView

/**图片点击回调*/
@property (nonatomic, copy) void (^touchEventHandler) (NSArray <MNAsset *>*assets, NSInteger index);

/**设置数据*/
@property (nonatomic, copy) NSArray <WXProfile *>*pictures;

@end
