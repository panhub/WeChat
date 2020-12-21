//
//  WXVoiceMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVoiceMessageCell.h"
#import "WXVoiceMessageViewModel.h"

@interface WXVoiceMessageCell ()
@property (nonatomic, strong) UIImageView *voiceView;
@end

@implementation WXVoiceMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 1;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        self.imgView.contentMode = UIViewContentModeScaleToFill;
        
        UIImageView *voiceView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        [self.imgView addSubview:voiceView];
        self.voiceView = voiceView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    WXVoiceMessageViewModel *vm = (WXVoiceMessageViewModel *)viewModel;
    /// 气泡
    self.imgView.frame = vm.imageViewModel.frame;
    self.imgView.image = vm.borderModel.content;
    /// 图标
    [self.voiceView stopAnimating];
    self.voiceView.frame = vm.voiceViewModel.frame;
    self.voiceView.image = vm.voiceViewModel.content;
    if (vm.isPlaying) [self.voiceView startAnimationWithImages:vm.images duration:1.f repeat:0];
    /// 时长
    self.titleLabel.frame = vm.textLabelModel.frame;
    self.titleLabel.attributedText = vm.textLabelModel.content;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.voiceView.layer removeAllAnimations];
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
