//
//  MNEmojiCell.m
//  MNChat
//
//  Created by Vincent on 2020/2/16.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNEmojiCell.h"
#import "MNEmoji.h"

@interface MNEmojiCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MNEmojiCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = self.contentView.backgroundColor = UIColor.clearColor;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

#pragma mark - Setter
- (void)setEmoji:(MNEmoji *)emoji {
    _emoji = emoji;
    if (emoji.image.images.count) {
        self.imageView.image = emoji.image.images.firstObject;
    } else {
        self.imageView.image = emoji.image;
    }
}

@end
