//
//  WXWebFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXWebFavoriteCell.h"
#import "WXFavoriteViewModel.h"

@implementation WXWebFavoriteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.detailLabel.hidden = YES;
        
        self.imgView.userInteractionEnabled = NO;
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.titleLabel.frame = viewModel.titleViewModel.frame;
    self.titleLabel.attributedText = viewModel.titleViewModel.content;
    
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
    viewModel.imageViewModel.containerView = self.imgView;
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
