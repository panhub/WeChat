//
//  WXLivePhotoController.h
//  MNChat
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//  LivePhoto预览

#import "MNExtendViewController.h"
#if __has_include(<PhotosUI/PHLivePhotoView.h>)
@class MNLivePhoto;

@interface WXLivePhotoController : MNExtendViewController

- (instancetype)initWithLivePhoto:(MNLivePhoto *)livePhoto;

@end
#endif
