//
//  WXMineEmoticonCell.m
//  WeChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineEmoticonCell.h"
#import "WXDataValueModel.h"

@interface WXMineEmoticonCell ()
@property (nonatomic, strong) UIButton *removeButton;
@end

@implementation WXMineEmoticonCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(15.f, 15.f, self.contentView.height_mn - 30.f, self.contentView.height_mn - 30.f);
        
        UIButton *removeButton = [UIButton buttonWithFrame:CGRectMake(self.contentView.width_mn - 80.f, 0.f, 65.f, 28.f) image:nil title:@"移除" titleColor:THEME_COLOR titleFont:[UIFont systemFontOfSize:14.f]];
        removeButton.centerY_mn = self.contentView.height_mn/2.f;
        [removeButton setTitle:@"添加" forState:UIControlStateSelected];
        UIViewSetBorderRadius(removeButton, 3.f, .8f, THEME_COLOR);
        [removeButton addTarget:self action:@selector(buttonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:removeButton];
        self.removeButton = removeButton;
        
        CGFloat y = (self.contentView.height_mn - 17.f - 14.f - 10.f)/2.f;
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, y, removeButton.left_mn - self.imgView.right_mn - 20.f, 17.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.9f];
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.left_mn, self.titleLabel.bottom_mn + 10.f, self.titleLabel.width_mn, 14.f);
        self.detailLabel.font = [UIFont systemFontOfSize:14.f];
        self.detailLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.45f];
        self.detailLabel.text = @"正在使用";
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.imgView.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setPacket:(MNEmojiPacket *)packet {
    _packet = packet;
    self.imgView.image = packet.image;
    self.titleLabel.text = packet.name;
    self.detailLabel.text = packet.state == MNEmojiPacketStateInvalid ? @"不可用" : @"正在使用";
    self.removeButton.selected = packet.state == MNEmojiPacketStateInvalid;
    self.removeButton.hidden = packet.type == MNEmojiPacketTypeText;
}

- (void)buttonTouchUpInside {
    self.packet.state = MNEmojiPacketStateInvalid - self.packet.state;
    @PostNotify(WXEmoticonStateDidChangeNotificationName, self.index_path);
    dispatch_async_default(^{
        [MNEmojiManager.defaultManager updatePacket:self.packet];
    });
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
