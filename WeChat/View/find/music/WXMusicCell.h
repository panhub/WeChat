//
//  WXMusicCell.h
//  MNChat
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//  歌曲Cell

#import "MNCollectionViewCell.h"
@class WXSong;

NS_ASSUME_NONNULL_BEGIN

@interface WXMusicCell : MNCollectionViewCell

/**歌曲模型*/
@property (nonatomic, strong) WXSong *song;

@end

NS_ASSUME_NONNULL_END
