//
//  WXAlbumViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册视图模型

#import <Foundation/Foundation.h>
#import "WXMomentPicture.h"

FOUNDATION_EXTERN CGFloat const WXAlbumItemInterval;
//FOUNDATION_EXTERN CGFloat const WXAlbumViewTopMargin;
FOUNDATION_EXTERN CGFloat const WXAlbumViewLeftMargin;
FOUNDATION_EXTERN CGFloat const WXAlbumViewRightMargin;

CGFloat WXAlbumViewWidth (void);
CGFloat WXAlbumItemWH (void);

@interface WXAlbumViewModel : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGRect frame;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *month;
@property (nonatomic, strong) NSArray <WXMomentPicture *>*pictures;

- (instancetype)initWithPictures:(NSArray <WXMomentPicture *>*)pictures;

@end

