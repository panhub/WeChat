//
//  WXMomentContentCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentContentCell.h"
#import "WXMomentEventViewModel.h"
#import "WXTimeline.h"

@interface WXMomentContentCell ()
@property (nonatomic, strong) UIImageView *separator;
@end

@implementation WXMomentContentCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    return [self cellWithTableView:tableView style:UITableViewCellStyleDefault];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style {
    WXMomentContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.moment.cell.id"];
    if (!cell) {
        cell = [[WXMomentContentCell alloc] initWithStyle:style reuseIdentifier:@"com.wx.moment.cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = WXMomentCommentViewBackgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self createView];
    }
    return self;
}

- (void)createView {
    /// 点击选中的颜色
    UIView *selectedView = [[UIView alloc] init];
    selectedView.backgroundColor = WXMomentCommentViewSelectedBackgroundColor;
    self.selectedBackgroundView = selectedView;
    /// 内容
    self.titleLabel.numberOfLines = 0;
    /// 分割线
    UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
    separator.height_mn = WXMomentSeparatorHeight;
    [self.contentView addSubview:separator];
    self.separator = separator;
}

- (void)setViewModel:(WXMomentEventViewModel *)viewModel {
    _viewModel = viewModel;
    self.titleLabel.frame = viewModel.contentFrame;
    self.titleLabel.attributedText = viewModel.content;
    self.separator.hidden = viewModel.isHiddenDivider;
    self.selectionStyle = viewModel.type == WXMomentEventTypeLiked ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x = WXMomentContentLeftOrRightMargin+WXMomentAvatarWH+WXMomentContentLeftMargin;
    frame.size.width = WXMomentContentWidth;
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.separator.width_mn = self.contentView.width_mn;
    self.separator.bottom_mn = self.contentView.height_mn;
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
