//
//  WXMusicLyricLabel.h
//  WeChat
//
//  Created by Vincent on 2020/2/10.
//  Copyright © 2020 Vincent. All rights reserved.
//  歌词显示

#import <UIKit/UIKit.h>
@class WXLyricViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXMusicLyricLabel : UILabel

/**歌词视图模型*/
@property (nonatomic, strong) WXLyricViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
