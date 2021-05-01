//
//  WXNotifyCell.m
//  WeChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXNotifyCell.h"
#import "WXNotifyViewModel.h"
#import "WXTimeline.h"
#import "WXMomentNotify.h"
#import "WXNotifyPicture.h"

@interface WXNotifyCell ()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView *likeView;
@property (nonatomic, strong) WXNotifyPicture *pictureView;
@end

@implementation WXNotifyCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.clipsToBounds = YES;
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.userInteractionEnabled = NO;
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.userInteractionEnabled = NO;
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.userInteractionEnabled = NO;
        
        UIImageView *likeView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"wx_moment_likedHL"]];
        likeView.contentMode = UIViewContentModeScaleAspectFill;
        likeView.clipsToBounds = YES;
        likeView.userInteractionEnabled = NO;
        [self.contentView addSubview:likeView];
        self.likeView = likeView;
        
        UILabel *dateLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        dateLabel.numberOfLines = 1;
        dateLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        UILabel *contentLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        contentLabel.numberOfLines = 0;
        contentLabel.userInteractionEnabled = NO;
        contentLabel.backgroundColor = VIEW_COLOR;
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        WXNotifyPicture *pictureView = [WXNotifyPicture new];
        pictureView.userInteractionEnabled = NO;
        [self.contentView addSubview:pictureView];
        self.pictureView = pictureView;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, WXNotifyLeftMargin, 0.f, 0.f);
    }
    return self;
}

- (void)setViewModel:(WXNotifyViewModel *)viewModel {
    _viewModel = viewModel;
    
    self.imgView.frame = viewModel.avatarViewModel.frame;
    self.imgView.image = viewModel.avatarViewModel.content;
    
    self.titleLabel.frame = viewModel.nickViewModel.frame;
    self.titleLabel.attributedText = viewModel.nickViewModel.content;
    
    self.detailLabel.frame = viewModel.commentViewModel.frame;
    self.detailLabel.attributedText = viewModel.commentViewModel.content;
    
    self.likeView.frame = viewModel.likeViewModel.frame;
    self.likeView.hidden = [viewModel.likeViewModel.content boolValue];
    
    self.contentLabel.frame = viewModel.contentViewModel.frame;
    self.contentLabel.attributedText = viewModel.contentViewModel.content;
    
    self.pictureView.viewModel = viewModel.pictureViewModel;
    
    self.dateLabel.frame = viewModel.dateViewModel.frame;
    self.dateLabel.attributedText = viewModel.dateViewModel.content;
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
