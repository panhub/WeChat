//
//  WXTextFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXTextFavoriteCell.h"
#import "WXFavorite.h"
#import "WXFavoriteViewModel.h"

@implementation WXTextFavoriteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.hidden = YES;
        self.detailLabel.hidden = YES;
        
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.titleLabel.frame = viewModel.titleViewModel.frame;
    self.titleLabel.attributedText = viewModel.titleViewModel.content;
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
