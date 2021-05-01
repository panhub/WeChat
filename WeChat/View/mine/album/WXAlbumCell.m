//
//  WXAlbumCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumCell.h"
#import "WXAlbumPictureView.h"
#import "WXMonthViewModel.h"

@interface WXAlbumCell ()
@property (nonatomic, strong) WXAlbumPictureView *pictureView;
@end

@implementation WXAlbumCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.userInteractionEnabled = NO;
        
        WXAlbumPictureView *pictureView = [WXAlbumPictureView new];
        [self.contentView addSubview:pictureView];
        self.pictureView = pictureView;
        
        @weakify(self);
        pictureView.touchEventHandler = ^(WXProfile *picture) {
            if (weakself.viewModel.touchEventHandler) {
                weakself.viewModel.touchEventHandler(picture);
            }
        };
    }
    return self;
}

- (void)setViewModel:(WXMonthViewModel *)viewModel {
    _viewModel = viewModel;
    self.titleLabel.frame = viewModel.monthViewModel.frame;
    self.titleLabel.attributedText = viewModel.monthViewModel.content;
    self.pictureView.viewModel = viewModel;
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
