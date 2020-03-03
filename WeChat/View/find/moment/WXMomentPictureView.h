//
//  WXMomentPictureView.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈九宫格配图 

#import <UIKit/UIKit.h>
@class WXMomentPicture;

@interface WXMomentPictureView : UIView

@property (nonatomic, copy) void (^pictureClickedHandler) (NSArray <MNAsset *>*assets, NSInteger index);

@property (nonatomic, copy) NSArray <WXMomentPicture *>*pictures;

@end
