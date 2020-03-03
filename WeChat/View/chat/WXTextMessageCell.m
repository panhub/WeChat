//
//  WXTextMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTextMessageCell.h"

@interface WXTextMessageCell ()

@end

@implementation WXTextMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        self.imgView.contentMode = UIViewContentModeScaleToFill;
        self.imgView.userInteractionEnabled = YES;
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
