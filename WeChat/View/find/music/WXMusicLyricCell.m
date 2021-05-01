//
//  WXMusicLyricCell.m
//  WeChat
//
//  Created by Vincent on 2020/2/5.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicLyricCell.h"
#import "WXMusicLyricLabel.h"

@interface WXMusicLyricCell ()

/**歌词渲染进度*/
@property (nonatomic, strong) WXMusicLyricLabel *lyricLabel;

@end

@implementation WXMusicLyricCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = self.contentView.backgroundColor = UIColor.clearColor;
        WXMusicLyricLabel *lyricLabel = [WXMusicLyricLabel new];
        [self.contentView addSubview:lyricLabel];
        self.lyricLabel = lyricLabel;
    }
    return self;
}

- (void)setViewModel:(WXLyricViewModel *)viewModel {
    self.lyricLabel.viewModel = viewModel;
}

- (WXLyricViewModel *)viewModel {
    return self.lyricLabel.viewModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
