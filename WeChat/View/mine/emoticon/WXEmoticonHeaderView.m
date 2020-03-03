//
//  WXEmoticonHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEmoticonHeaderView.h"
#import "MNEmojiPacket.h"

@interface WXEmoticonHeaderView ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation WXEmoticonHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIImage *image = [UIImage imageNamed:@"emoticon_header"];
        CGSize size = CGSizeMultiplyToWidth(image.size, self.width_mn);
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:image];
        [self addSubview:imageView];
        
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(self.width_mn - 90.f, imageView.bottom_mn + 15.f, 75.f, 30.f)
                                               image:nil
                                               title:@"添加"
                                          titleColor:[UIColor whiteColor]
                                           titleFont:[UIFont systemFontOfSize:14.f]];
        button.backgroundColor = THEME_COLOR;
        UIViewSetCornerRadius(button, 4.f);
        [button setTitle:@"移除" forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.button = button;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(15.f, 0.f, button.left_mn - 25.f, 19.f) text:nil textColor:[UIColor darkTextColor] font:UIFontMedium(19.f)];
        titleLabel.centerY_mn = button.centerY_mn;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *detailLabel = [UILabel labelWithFrame:CGRectMake(titleLabel.left_mn, button.bottom_mn + 7.f, self.width_mn - titleLabel.left_mn*2.f, 14.f) text:nil textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:[UIFont systemFontOfSize:14.f]];
        [self addSubview:detailLabel];
        self.detailLabel = detailLabel;
        
        self.height_mn = detailLabel.bottom_mn + 15.f;
        
    }
    return self;
}

- (void)setPacket:(MNEmojiPacket *)packet {
    _packet = packet;
    self.titleLabel.text = packet.name;
    self.detailLabel.text = packet.desc;
    self.button.selected = packet.state == MNEmojiPacketStateValid;
    self.button.hidden = packet.type == MNEmojiTypeText;
}

- (void)buttonClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    self.packet.state = MNEmojiPacketStateInvalid - self.packet.state;
    @PostNotify(WXEmoticonStateDidChangeNotificationName, nil);
    dispatch_async_default(^{
        [MNEmojiManager.defaultManager updatePacket:self.packet];
    });
}

@end
