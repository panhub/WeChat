//
//  WXMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMessageCell.h"

@interface WXMessageCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) UIImageView *maskImageView;
@end

@implementation WXMessageCell
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXMessageViewModel *)model {
    NSString *cls = [NSStringFromClass(model.class) stringByReplacingOccurrencesOfString:@"ViewModel" withString:@"Cell"];
    WXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cls];
    if (!cell) {
        cell = [[NSClassFromString(cls) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cls];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.imgView.userInteractionEnabled = YES;
        [self handEvents];
    }
    return self;
}

#pragma mark - 定制事件
- (void)handEvents {
    @weakify(self);
    /// 头像事件
    [self.headButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.headButtonClickedHandler) {
            self.viewModel.headButtonClickedHandler(self.viewModel);
        }
    }];
    /// 消息点击事件
    [self.imgView handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.viewModel.imageViewClickedHandler) {
            self.viewModel.imageViewClickedHandler(self.viewModel);
        }
    }];
}

#pragma mark - Setter
- (void)setViewModel:(WXMessageViewModel *)viewModel {
    _viewModel = viewModel;
    /// 时间
    self.timeLabel.frame = viewModel.timeLabelModel.frame;
    self.timeLabel.attributedText = viewModel.timeLabelModel.content;
    /// 头像
    self.headButton.frame = viewModel.headButtonModel.frame;
    [self.headButton setBackgroundImage:viewModel.headButtonModel.content forState:UIControlStateNormal];
    [self.headButton setBackgroundImage:viewModel.headButtonModel.content forState:UIControlStateHighlighted];
}

#pragma mark - 公共UI
- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        UIImageView *maskImageView = [[UIImageView alloc] init];
        _maskImageView = maskImageView;
    }
    return _maskImageView;
}

- (UIButton *)headButton {
    if (!_headButton) {
        UIButton *headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        headButton.backgroundColor = [UIColor whiteColor];
        headButton.layer.cornerRadius = 3.f;
        headButton.clipsToBounds = YES;
        [self.contentView addSubview:headButton];
        _headButton = headButton;
    }
    return _headButton;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.numberOfLines = 1;
        [self.contentView addSubview:timeLabel];
        _timeLabel = timeLabel;
    }
    return _timeLabel;
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
