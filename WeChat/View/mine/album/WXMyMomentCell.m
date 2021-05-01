//
//  WXMyMomentCell.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentCell.h"
#import "WXExtendViewModel.h"
#import "WXMyMomentViewModel.h"
#import "WXMomentWebView.h"
#import "WXMyMomentPicture.h"
#import "WXMyMoment.h"

@interface WXMyMomentCell ()
@property (nonatomic, strong) UIView *touchView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIView *textBackgroundView;
@property (nonatomic, strong) WXMomentWebView *webView;
@property (nonatomic, strong) WXMyMomentPicture *pictureView;
@end

@implementation WXMyMomentCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UILabel *dateLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        dateLabel.numberOfLines = 1;
        dateLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        UILabel *locationLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        locationLabel.numberOfLines = 2;
        locationLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:locationLabel];
        self.locationLabel = locationLabel;
        
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        
        UIView *textBackgroundView = [[UIView alloc] init];
        textBackgroundView.userInteractionEnabled = NO;
        [textBackgroundView addSubview:self.titleLabel];
        [self.contentView addSubview:textBackgroundView];
        self.textBackgroundView = textBackgroundView;
        
        WXMyMomentPicture *pictureView = WXMyMomentPicture.new;
        pictureView.userInteractionEnabled = NO;
        [self.contentView addSubview:pictureView];
        self.pictureView = pictureView;
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.userInteractionEnabled = NO;
        
        WXMomentWebView *webView = [[WXMomentWebView alloc] init];
        webView.titleLabel.numberOfLines = 1;
        webView.userInteractionEnabled = NO;
        webView.titleLabel.font = WXMyMomentWebFont;
        webView.titleLabel.textColor = WXMyMomentWebTextColor;
        [self.contentView addSubview:webView];
        self.webView = webView;
        
        UIControl *touchView = [[UIControl alloc] initWithFrame:self.contentView.bounds];
        touchView.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:touchView];
        self.touchView = touchView;
        
        @weakify(self);
        [touchView handTapEventHandler:^(id _Nonnull sender) {
            if (weakself.viewModel.touchEventHandler) {
                weakself.viewModel.touchEventHandler(weakself.viewModel.moment);
            }
        }];
    }
    return self;
}

- (void)setViewModel:(WXMyMomentViewModel *)viewModel {
    
    _viewModel = viewModel;
    
    self.dateLabel.frame = viewModel.dateViewModel.frame;
    self.dateLabel.attributedText = viewModel.dateViewModel.content;
    
    self.locationLabel.frame = viewModel.locationViewModel.frame;
    self.locationLabel.attributedText = viewModel.locationViewModel.content;
    
    self.textBackgroundView.frame = viewModel.backgroundViewModel.frame;
    self.textBackgroundView.backgroundColor = viewModel.backgroundViewModel.content;
    
    self.titleLabel.frame = viewModel.contentViewModel.frame;
    self.titleLabel.attributedText = viewModel.contentViewModel.content;
    
    self.pictureView.viewModel = viewModel.pictureViewModel;
    
    self.detailLabel.frame = viewModel.numberViewModel.frame;
    self.detailLabel.attributedText = viewModel.numberViewModel.content;
    
    self.webView.frame = viewModel.webViewModel.frame;
    self.webView.webpage = viewModel.webViewModel.content;
    self.webView.hidden = viewModel.webViewModel.content == nil;
    
    self.touchView.frame = CGRectMake(self.pictureView.left_mn, 0.f, self.contentView.width_mn - self.pictureView.left_mn - WXMyMomentRightMargin, MAX(MAX(self.pictureView.bottom_mn, self.textBackgroundView.bottom_mn), self.webView.bottom_mn));
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
