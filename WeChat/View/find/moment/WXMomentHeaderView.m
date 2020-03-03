//
//  WXMomentHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentHeaderView.h"
#import "WXMomentPictureView.h"
#import "WXMomentWebView.h"
#import "WXMomentViewModel.h"
#import "WXMomentMoreView.h"

@interface WXMomentHeaderView ()
/// 昵称
@property (nonatomic, strong) UILabel *nicknameLabel;
/// 正文
@property (nonatomic, strong) UILabel *contentLabel;
/// 时间
@property (nonatomic, strong) UILabel *timeLabel;
/// 位置
@property (nonatomic, strong) UILabel *locationLabel;
/// 来源
@property (nonatomic, strong) UILabel *sourceLabel;
/// 删除
@property (nonatomic, strong) UIButton *deleteButton;
/// 更多
@property (nonatomic, strong) UIButton *moreButton;
/// 全文/收起
@property (nonatomic, strong) UIButton *expandButton;
/// 向上箭头
@property (nonatomic, strong) UIImageView *arrowView;
/// 头像
@property (nonatomic, strong) UIImageView *avatarView;
/// 隐私
@property (nonatomic, strong) UIImageView *privacyView;
/// 配图
@property (nonatomic, strong) WXMomentPictureView *pictureView;
/// 分享
@property (nonatomic, strong) WXMomentWebView *webView;
/// 更多视图
@property (nonatomic, strong) WXMomentMoreView *moreView;
@end

@implementation WXMomentHeaderView
+ (instancetype)headerViewWithTableView:(UITableView *)tableView{
    WXMomentHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.moment.header.id"];
    if (!header) {
        header = [[WXMomentHeaderView alloc] initWithReuseIdentifier:@"com.wx.moment.header.id"];
    }
    return header;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = NO;
        self.contentView.clipsToBounds = NO;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self createView];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    /// 用户头像
    UIImageView *avatarView = [[UIImageView alloc] init];
    avatarView.userInteractionEnabled = YES;
    avatarView.userInteractionEnabled = YES;
    avatarView.layer.cornerRadius = 3.f;
    avatarView.clipsToBounds = YES;
    [self.contentView addSubview:avatarView];
    self.avatarView = avatarView;
    
    /// 昵称
    UILabel *nicknameLabel = [[UILabel alloc] init];
    nicknameLabel.userInteractionEnabled = YES;
    nicknameLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:nicknameLabel];
    self.nicknameLabel = nicknameLabel;
    
    /// 正文
    UILabel *contentLabel = [[UILabel alloc] init];
    //contentLabel.backgroundColor = [UIColor yellowColor];
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.numberOfLines = 0;
    contentLabel.font = WXMomentContentTextFont;
    contentLabel.textColor = WXMomentContentTextColor;
    [self.contentView addSubview:contentLabel];
    self.contentLabel = contentLabel;
    
    /// 全文/收起按钮
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //[expandButton setTitle:@"全文" forState:UIControlStateNormal];
    [expandButton setTitleColor:WXMomentNicknameTextColor forState:UIControlStateNormal];
    [expandButton.titleLabel setFont:WXMomentExpandButtonTitleFont];
    expandButton.clipsToBounds = YES;
    [self.contentView addSubview:expandButton];
    self.expandButton = expandButton;
    
    /// 配图
    WXMomentPictureView *pictureView = [[WXMomentPictureView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:pictureView];
    self.pictureView = pictureView;
    
    /// 分享
    WXMomentWebView *webView = [[WXMomentWebView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:webView];
    self.webView = webView;
    
    /// 位置
    UILabel *locationLabel = [[UILabel alloc] init];
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.font = WXMomentContentInnerFont;
    locationLabel.textColor = WXMomentLocationTextColor;
    [self.contentView addSubview:locationLabel];
    self.locationLabel = locationLabel;
    
    /// 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textAlignment = NSTextAlignmentLeft;
    timeLabel.font = WXMomentContentInnerFont;
    timeLabel.textColor = WXMomentCreatedTimeTextColor;
    [self.contentView addSubview:timeLabel];
    self.timeLabel = timeLabel;
    
    /// 来源
    UILabel *sourceLabel = [[UILabel alloc] init];
    sourceLabel.textAlignment = NSTextAlignmentLeft;
    sourceLabel.font = WXMomentContentInnerFont;
    sourceLabel.textColor = WXMomentSourceTextColor;
    [self.contentView addSubview:sourceLabel];
    self.sourceLabel = sourceLabel;
    
    /// 隐私
    UIImageView *privacyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wx_moment_privacy"]];
    privacyView.clipsToBounds = YES;
    [self.contentView addSubview:privacyView];
    self.privacyView = privacyView;
    
    /// 删除
    UIButton *deleteButton = [UIButton buttonWithFrame:CGRectZero
                                               image:nil
                                                 title:@"删除"
                                            titleColor:WXMomentDeleteTextColor
                                             titleFont:WXMomentContentInnerFont];
    [self.contentView addSubview:deleteButton];
    self.deleteButton = deleteButton;
    
    /// 更多
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.touchInset = UIEdgeInsetWith(-10.f);
    [moreButton setImage:UIImageNamed(@"wx_moment_more") forState:UIControlStateNormal];
    [moreButton setImage:UIImageNamed(@"wx_moment_more") forState:UIControlStateHighlighted];
    moreButton.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:moreButton];
    self.moreButton = moreButton;
    
    /// 更多操作
    WXMomentMoreView *moreView = [[WXMomentMoreView alloc] init];
    self.moreView = moreView;
    
    /// 向上的箭头
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_triangle")];
    arrowView.clipsToBounds = YES;
    [self.contentView addSubview:arrowView];
    self.arrowView = arrowView;
}

- (void)setViewModel:(WXMomentViewModel *)viewModel {
    _viewModel = viewModel;
    /// 头像
    self.avatarView.image = viewModel.avatarViewModel.content;
    self.avatarView.frame = viewModel.avatarViewModel.frame;
    /// 昵称
    self.nicknameLabel.attributedText = viewModel.nicknameViewModel.content;
    self.nicknameLabel.frame = viewModel.nicknameViewModel.frame;
    /// 正文
    self.contentLabel.attributedText = viewModel.contentViewModel.content;
    self.contentLabel.frame = viewModel.contentViewModel.frame;
    /// 全文/收起
    self.expandButton.frame = viewModel.expandViewModel.frame;
    [self.expandButton setAttributedTitle:viewModel.expandViewModel.content forState:UIControlStateNormal];
    /// 配图
    self.pictureView.frame = viewModel.pictureViewFrame;
    self.pictureView.pictures = viewModel.moment.pictures;
    /// 分享
    self.webView.frame = viewModel.webViewFrame;
    self.webView.webpage = viewModel.moment.webpage;
    /// 位置
    self.locationLabel.attributedText = viewModel.locationViewModel.content;
    self.locationLabel.frame = viewModel.locationViewModel.frame;
    /// 时间
    self.timeLabel.attributedText =  viewModel.timeViewModel.content;
    self.timeLabel.frame = viewModel.timeViewModel.frame;
    /// 来源
    self.sourceLabel.attributedText = viewModel.sourceViewModel.content;
    self.sourceLabel.frame = viewModel.sourceViewModel.frame;
    /// 隐私
    self.privacyView.frame = viewModel.privacyViewModel.frame;
    /// 删除
    self.deleteButton.frame = viewModel.deleteViewModel.frame;
    [self.deleteButton setAttributedTitle:viewModel.deleteViewModel.content forState:UIControlStateNormal];
    /// 更多按钮
    self.moreButton.frame = viewModel.moreButtonFrame;
    /// 箭头
    self.arrowView.frame = viewModel.arrowViewFrame;
}

#pragma mark - Events
- (void)handEvents {
    @weakify(self);
    /// 配图点击事件
    self.pictureView.pictureClickedHandler = ^(NSArray<MNAsset *> *assets, NSInteger index) {
        @strongify(self);
        if (self.viewModel.pictureViewEventHandler) {
            self.viewModel.pictureViewEventHandler(self.viewModel, assets, index);
        }
    };
    
    /// 更多事件
    [self.moreButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        if ([[MNConfiguration configuration] keyboardVisible]) {
            [UIWindow endEditing:YES];
        } else {
            [self.moreView showAtView:self.moreButton animated:YES];
        }
    }];
    
    /// 分享网页点按事件
    [self.webView handTapEventHandler:^(id sender) {
        @strongify(self);
        if ([[MNConfiguration configuration] keyboardVisible]) {
            [UIWindow endEditing:YES];
        } else if (self.viewModel.webViewEventHandler) {
            self.viewModel.webViewEventHandler(self.viewModel);
        }
    }];
    
    /// 点赞/评论事件
    self.moreView.eventHandler = ^(NSUInteger idx) {
        @strongify(self);
        if (self.viewModel.moreButtonEventHandler) {
            self.viewModel.moreButtonEventHandler(self.viewModel, idx);
        }
    };
    
    /// 删除事件
    [self.deleteButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.deleteButtonEventHandler) {
            self.viewModel.deleteButtonEventHandler(self.viewModel);
        }
    }];
    
    /// 全文/收起事件
    [self.expandButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        [self.viewModel expandContentIfNeeded];
    }];
    
    /// 头像点击事件
    [self.avatarView handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.avatarClickedEventHandler) {
            self.viewModel.avatarClickedEventHandler(self.viewModel);
        }
    }];
    
    /// 昵称点击事件
    [self.nicknameLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.avatarClickedEventHandler) {
            self.viewModel.avatarClickedEventHandler(self.viewModel);
        }
    }];
    
    /// 位置点击事件
    [self.locationLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.locationViewEventHandler) {
            self.viewModel.locationViewEventHandler(self.viewModel);
        }
    }];
    
    /// 长按事件
    [self handLongPressConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.deleteButtonEventHandler) {
            self.viewModel.deleteButtonEventHandler(self.viewModel);
        }
    }];
    
    /// 触摸事件
    [self handTapConfiguration:nil eventHandler:^(id sender) {
        [UIWindow endEditing:YES];
    }];
}

@end
