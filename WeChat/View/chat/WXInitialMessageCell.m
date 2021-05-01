//
//  WXInitialMessageCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/24.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXInitialMessageCell.h"

@implementation WXInitialMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.hidden = YES;
        self.headButton.hidden = YES;
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    
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
