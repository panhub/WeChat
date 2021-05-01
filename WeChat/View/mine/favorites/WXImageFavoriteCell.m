//
//  WXImageFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXImageFavoriteCell.h"
#import "WXFavorite.h"
#import "WXFavoriteViewModel.h"

@implementation WXImageFavoriteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.hidden = YES;
        
        self.detailLabel.hidden = YES;
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
    viewModel.imageViewModel.containerView = self.imgView;
}

@end
