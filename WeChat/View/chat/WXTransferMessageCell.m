//
//  WXTransferMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferMessageCell.h"
#import "WXTransferMessageViewModel.h"

@interface WXTransferMessageCell ()
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UIImageView *iconView;
@end

@implementation WXTransferMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.userInteractionEnabled = NO;
        [self.detailLabel removeFromSuperview];
        [self.imgView addSubview:self.detailLabel];
        
        UIImageView *iconView = [UIImageView new];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imgView addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *stateLabel = [UILabel new];
        stateLabel.numberOfLines = 1;
        [self.imgView addSubview:stateLabel];
        self.stateLabel = stateLabel;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    WXTransferMessageViewModel *vm = (WXTransferMessageViewModel *)viewModel;
    
    self.imgView.frame = vm.imageViewModel.frame;
    self.imgView.image = vm.imageViewModel.content;
    
    self.iconView.frame = vm.iconViewModel.frame;
    self.iconView.image = vm.iconViewModel.content;
    
    self.titleLabel.frame = vm.textLabelModel.frame;
    self.titleLabel.attributedText = vm.textLabelModel.content;
    
    self.stateLabel.frame = vm.stateLabelModel.frame;
    self.stateLabel.attributedText = vm.stateLabelModel.content;
    
    self.detailLabel.frame = vm.detailLabelModel.frame;
    self.detailLabel.attributedText = vm.detailLabelModel.content;
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
