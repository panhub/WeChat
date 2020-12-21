//
//  WXMomentRemindCell.m
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXMomentRemindCell.h"
#import "WXMomentRemindViewModel.h"

@interface WXMomentRemindCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *briefLabel;
@property (nonatomic, strong) UIImageView *briefView;
@end

@implementation WXMomentRemindCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        UIViewSetCornerRadius(self.imgView, 3.f);
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *briefLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        briefLabel.numberOfLines = 0;
        [self.contentView addSubview:briefLabel];
        self.briefLabel = briefLabel;
        
        UIImageView *briefView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        briefView.contentMode = UIViewContentModeScaleAspectFill;
        briefView.clipsToBounds = YES;
        [self.contentView addSubview:briefView];
        self.briefView = briefView;
        
        UIImageView *separator = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        [self.contentView addSubview:separator];
        separator.sd_layout
        .leftEqualToView(self.imgView)
        .rightEqualToView(self.contentView)
        .bottomEqualToView(self.contentView)
        .heightIs(WXMomentSeparatorHeight);
    }
    return self;
}

- (void)setViewModel:(WXMomentRemindViewModel *)viewModel {
    _viewModel = viewModel;
    self.imgView.frame = viewModel.headViewModel.frame;
    self.imgView.image = viewModel.headViewModel.content;
    
    self.titleLabel.frame = viewModel.nameLabelModel.frame;
    self.titleLabel.attributedText = viewModel.nameLabelModel.content;
    
    self.detailLabel.frame = viewModel.textLabelModel.frame;
    self.detailLabel.attributedText = viewModel.textLabelModel.content;
    
    self.timeLabel.frame = viewModel.timeLabelModel.frame;
    self.timeLabel.attributedText = viewModel.timeLabelModel.content;
    
    if ([viewModel.briefViewModel.content isKindOfClass:UIImage.class]) {
        self.briefLabel.frame = CGRectZero;
        self.briefView.frame = viewModel.briefViewModel.frame;
        self.briefView.image = viewModel.briefViewModel.content;
    } else if ([viewModel.briefViewModel.content isKindOfClass:NSAttributedString.class]) {
        self.briefView.frame = CGRectZero;
        self.briefLabel.frame = viewModel.briefViewModel.frame;
        self.briefLabel.attributedText = viewModel.briefViewModel.content;
    } else {
        self.briefLabel.frame = self.briefView.frame = CGRectZero;
    }
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
