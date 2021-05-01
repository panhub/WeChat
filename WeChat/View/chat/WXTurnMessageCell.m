//
//  WXTurnMessageCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/21.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXTurnMessageCell.h"
#import "MNIndicatorView.h"
#import "WXTurnMessageViewModel.h"

@interface WXTurnMessageCell ()
@property (nonatomic, strong) MNIndicatorView *indicatorView;
@end

@implementation WXTurnMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        
        self.imgView.contentMode = UIViewContentModeScaleToFill;
        self.imgView.userInteractionEnabled = YES;
        
        self.headButton.hidden = YES;
        self.timeLabel.hidden = YES;
        
        MNIndicatorView *indicatorView = [[MNIndicatorView alloc] initWithFrame:CGRectMake(0.f, 0.f, WXTurnMessageIndicatorWH, WXTurnMessageIndicatorWH)];
        indicatorView.hidesWhenStopped = YES;
        indicatorView.hidesUseAnimation = YES;
        indicatorView.lineWidth = 1.5f;
        indicatorView.progress = .75f;
        indicatorView.color = UIColor.clearColor;
        indicatorView.lineColor = [[UIColor grayColor] colorWithAlphaComponent:.65f];
        indicatorView.userInteractionEnabled = NO;
        [self.imgView addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    /// 气泡
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.borderModel.content;
    /// 文本消息内容
    self.titleLabel.frame = viewModel.textLabelModel.frame;
    self.titleLabel.attributedText = viewModel.textLabelModel.content;
    /// 指示图
    self.indicatorView.left_mn = self.titleLabel.left_mn;
    self.indicatorView.centerY_mn = self.titleLabel.centerY_mn;
    if ([viewModel.textLabelModel.extend boolValue]) {
        [self.indicatorView startAnimating];
    } else {
        [self.indicatorView stopAnimating];
    }
    /// 记录视图
    viewModel.textLabelModel.containerView = self.titleLabel;
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
