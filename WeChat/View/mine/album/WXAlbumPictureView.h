//
//  WXAlbumPictureView.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册view

#import <UIKit/UIKit.h>
@class WXMomentPicture;

@interface WXAlbumPictureView : UIView

@property (nonatomic, copy) NSArray <WXMomentPicture *>*pictures;

@end
