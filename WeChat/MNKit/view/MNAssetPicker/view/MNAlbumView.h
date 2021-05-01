//
//  MNAlbumView.h
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNAssetCollection, MNAlbumView;

@protocol MNAlbumViewDelegate <NSObject>
@optional;
- (void)albumView:(MNAlbumView *)albumView didSelectAlbum:(MNAssetCollection *)album;
@end

@interface MNAlbumView : UIView

@property (nonatomic, weak) id<MNAlbumViewDelegate> delegate;

@property (nonatomic, weak) NSArray <MNAssetCollection *>*dataArray;

- (void)show;

- (void)dismiss;

- (void)reloadData;

@end
