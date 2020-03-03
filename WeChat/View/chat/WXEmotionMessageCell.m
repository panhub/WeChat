//
//  WXEmotionMessageCell.m
//  MNChat
//
//  Created by Vincent on 2020/2/17.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXEmotionMessageCell.h"

@interface WXEmotionMessageCell ()

@end

@implementation WXEmotionMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imgView.clipsToBounds = YES;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    self.imgView.image = nil;
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
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
