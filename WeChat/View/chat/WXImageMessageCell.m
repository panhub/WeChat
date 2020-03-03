//
//  WXImageMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXImageMessageCell.h"

@implementation WXImageMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.clipsToBounds = YES;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    /// 图片
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
    viewModel.imageViewModel.obj = self.imgView;
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
