//
//  MNAssetPickProtocol.h
//  MNChat
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MNAssetPicker, MNAsset;

@protocol MNAssetPickerDelegate<NSObject>
@optional
- (void)assetPickerDidCancel:(MNAssetPicker *)picker;
- (void)assetPicker:(MNAssetPicker *)picker didFinishPickingAssets:(NSArray <MNAsset *>*)assets;
@end

