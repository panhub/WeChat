//
//  WXMomentContentCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentContentCell.h"
#import "WXMomentItemViewModel.h"

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
    UIImageView *separator = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    [self.contentView addSubview:separator];
    separator.sd_layout
    .leftEqualToView(self.contentView)
    .rightEqualToView(self.contentView)
    .bottomEqualToView(self.contentView)
    .heightIs(WXMomentSeparatorHeight);
    self.separator = separator;
}

- (void)setViewModel:(WXMomentItemViewModel *)viewModel {
    _viewModel = viewModel;
    self.titleLabel.frame = viewModel.contentFrame;
    self.titleLabel.attributedText = viewModel.content;
    self.separator.hidden = viewModel.isHiddenDivider;
    self.selectionStyle = viewModel.type == WXMomentItemTypeLiked ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x = WXMomentContentLeftOrRightMargin+WXMomentAvatarWH+WXMomentTextLeftMargin;
    frame.size.width = WXMomentContentWidth();
    [super setFrame:frame];
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
