//
//  WXMusicCell.m
//  MNChat
//
//  Created by Vincent on 2020/2/8.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXMusicCell.h"
#import "WXSong.h"

@interface WXMusicCell ()

//@property (nonatomic, strong)

@end

@implementation WXMusicCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        self.contentView.backgroundColor = VIEW_COLOR;
        self.contentView.layer.cornerRadius = 7.f;
        self.contentView.clipsToBounds = YES;
        
        self.imageView.size_mn = CGSizeMake(self.contentView.width_mn, self.contentView.width_mn);
        self.imageView.contentMode = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.titleLabel.font = UIFontLight(16.f);
        self.titleLabel.textColor = UIColorWithAlpha(UIColor.darkTextColor, .95f);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.detailLabel.font = UIFontLight(14.f);
        self.detailLabel.textColor = UIColorWithAlpha(UIColor.darkTextColor, .75f);
        self.detailLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

#pragma mark - Setter
- (void)setSong:(WXSong *)song {
    _song = song;
    self.imageView.image = song.artwork;
    self.titleLabel.text = song.title;
    self.detailLabel.text = song.artist;
    [self.titleLabel sizeToFit];
    [self.detailLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.titleLabel.width_mn, self.contentView.width_mn - 20.f);
    self.detailLabel.width_mn = MIN(self.detailLabel.width_mn, self.contentView.width_mn - 20.f);
    self.titleLabel.centerX_mn = self.detailLabel.centerX_mn = self.contentView.width_mn/2.f;
    CGFloat y = (self.contentView.height_mn - self.imageView.bottom_mn - self.titleLabel.height_mn - self.detailLabel.height_mn - 1.f)/2.f;
    self.titleLabel.top_mn = self.imageView.bottom_mn + y;
    self.detailLabel.top_mn = self.titleLabel.bottom_mn + 1.f;
}

@end
