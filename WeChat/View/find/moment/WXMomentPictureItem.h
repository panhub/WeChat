//
//  WXMomentPictureItem.h
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  朋友圈单张配图

#import <UIKit/UIKit.h>
@class WXMomentPicture;

@interface WXMomentPictureItem : UIImageView

@property (nonatomic, unsafe_unretained) WXMomentPicture *picture;

@end
