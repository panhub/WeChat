//
//  MNEmojiPacketCell.m
//  MNKit
//
//  Created by Vincent on 2019/2/5.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiPacketCell.h"
#import "MNEmojiButton.h"
#import "MNEmojiKeyboardConfiguration.h"

@interface MNEmojiPacketCell ()
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) MNEmojiButton *packetView;
@end

@implementation MNEmojiPacketCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        CGFloat hor = (self.contentView.width_mn - 23.f)/2.f;
        CGFloat ver = (self.contentView.height_mn - 23.f)/2.f;
        MNEmojiButton *packetView = [[MNEmojiButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)];
        packetView.frame = self.contentView.bounds;
        packetView.userInteractionEnabled = NO;
        packetView.backgroundColor = UIColor.clearColor;
        packetView.imageInset = UIEdgeInsetsMake(ver, hor, ver, hor);
        [packetView fixedImageSize];
        packetView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:packetView];
        self.packetView = packetView;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, .5f, self.contentView.height_mn - 10.f)];
        separator.right_mn = self.contentView.width_mn;
        separator.centerY_mn = self.contentView.height_mn/2.f;
        separator.backgroundColor = [UIColor.darkGrayColor colorWithAlphaComponent:.15f];
        separator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        separator.userInteractionEnabled = NO;
        [self.contentView addSubview:separator];
        self.separator = separator;
        
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.contentView.clipsToBounds = YES;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)setImage:(UIImage *)image selected:(BOOL)selected configuration:(MNEmojiKeyboardConfiguration *)configuration {
    self.packetView.image = image;
    CGFloat hor = (self.packetView.width_mn - 23.f)/2.f;
    CGFloat ver = (self.packetView.height_mn - 23.f)/2.f;
    self.packetView.imageInset = UIEdgeInsetsMake(ver, hor, ver, hor);
    if (configuration.style == MNEmojiKeyboardStyleLight) {
        self.separator.hidden = YES;
        self.packetView.layer.cornerRadius = 6.f;
        self.packetView.clipsToBounds = YES;
    } else {
        self.separator.hidden = NO;
        self.separator.backgroundColor = configuration.separatorColor;
    }
    self.packetView.backgroundColor = selected ? configuration.selectedColor : UIColor.clearColor;
}

@end
