//
//  WXLocationFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXLocationFavoriteCell.h"
#import "WXFavoriteViewModel.h"

@implementation WXLocationFavoriteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
    viewModel.imageViewModel.containerView = self.imgView;
    
    self.titleLabel.frame = viewModel.titleViewModel.frame;
    self.titleLabel.attributedText = viewModel.titleViewModel.content;
    
    self.detailLabel.frame = viewModel.subtitleViewModel.frame;
    self.detailLabel.attributedText = viewModel.subtitleViewModel.content;
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
