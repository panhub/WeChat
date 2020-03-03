//
//  MNAssetBrowseControl.h
//  MNFoundation
//
//  Created by Vincent on 2019/9/9.
//  Copyright © 2019 XiaoSi. All rights reserved.
//  资源浏览器选择按钮

#import <UIKit/UIKit.h>
@class MNAsset;

@interface MNAssetBrowseControl : UIControl

- (void)updateAsset:(MNAsset *)asset;

@end
