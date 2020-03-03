//
//  WXCallMessageCell.m
//  MNChat
//
//  Created by Vincent on 2020/2/14.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCallMessageCell.h"
#import "WXCallMessageViewModel.h"

@interface WXCallMessageCell ()
/**角标*/
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXCallMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.numberOfLines = 1;
        [self.titleLabel removeFromSuperview];
        self.titleLabel.userInteractionEnabled = NO;
        [self.imgView addSubview:self.titleLabel];
        self.imgView.contentMode = UIViewContentModeScaleToFill;
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        badgeView.contentMode = UIViewContentModeScaleAspectFill;
        badgeView.clipsToBounds = YES;
        badgeView.userInteractionEnabled = NO;
        [self.imgView addSubview:badgeView];
        self.badgeView = badgeView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    WXCallMessageViewModel *vm = (WXCallMessageViewModel *)viewModel;
    /// 气泡
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.borderModel.content;
    /// 文本消息内容
    self.titleLabel.frame = viewModel.textLabelModel.frame;
    self.titleLabel.attributedText = viewModel.textLabelModel.content;
    /// 角标
    self.badgeView.frame = vm.badgeViewModel.frame;
    self.badgeView.image = vm.badgeViewModel.content;
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
