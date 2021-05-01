//
//  WXVideoFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXVideoFavoriteCell.h"
#import "WXFavorite.h"
#import "WXFavoriteViewModel.h"
#import "WXVideoFavoriteViewModel.h"

@interface WXVideoFavoriteCell ()
@property (nonatomic, strong) UIImageView *badgeView;
@end

@implementation WXVideoFavoriteCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.hidden = YES;
        
        self.detailLabel.hidden = YES;
        
        UIImageView *badgeView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"favorite_play"]];
        badgeView.clipsToBounds = YES;
        badgeView.userInteractionEnabled = NO;
        [self.imgView addSubview:badgeView];
        self.badgeView = badgeView;
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.imgView.frame = viewModel.imageViewModel.frame;
    self.imgView.image = viewModel.imageViewModel.content;
    viewModel.imageViewModel.containerView = self.imgView;
    
    self.badgeView.frame = ((WXVideoFavoriteViewModel *)viewModel).playViewModel.frame;
}

- (void)layoutSubviews {
    [super layoutSubviews];
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
