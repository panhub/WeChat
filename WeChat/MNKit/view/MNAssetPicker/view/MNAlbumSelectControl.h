//
//  MNAlbumSelectControl.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册选择

#import <UIKit/UIKit.h>
@class MNAssetCollection;

@interface MNAlbumSelectControl : UIControl

/**当前标题*/
@property (nonatomic, copy) NSString *title;

/**是否允许选择*/
@property (nonatomic) BOOL selectEnabled;

@end
