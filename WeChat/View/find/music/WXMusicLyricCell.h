//
//  WXMusicLyricCell.h
//  MNChat
//
//  Created by Vincent on 2020/2/5.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXLyricViewModel;

@interface WXMusicLyricCell : MNTableViewCell

/**歌词视图模型*/
@property (nonatomic) WXLyricViewModel *viewModel;

@end
