//
//  WXBankCardAlertView.m
//  MNChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardAlertView.h"
#import "WXBankCardAlertViewCell.h"

@interface WXBankCardAlertView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *shadow;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <WXBankCard *>*dataArray;
@end

@implementation WXBankCardAlertView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self loadData];
        [self createView];
    }
    return self;
}

- (void)loadData {
    NSArray <WXBankCard *>*array = [[NSArray alloc] initWithArray:[[MNChatHelper helper] cards]];
    NSMutableArray <WXBankCard *>*dataArray = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(WXBankCard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == WXBankCardTypeDeposit) {
            [dataArray addObject:obj];
        }
    }];
    self.dataArray = dataArray.copy;
}

- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.height_mn, self.width_mn, 0.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIButton *closeButton = [UIButton buttonWithFrame:CGRectMake(10.f, 10.f, 30.f, 30.f) image:[UIImage imageNamed:@"wx_common_close"] title:nil titleColor:nil titleFont:nil];
    closeButton.touchInset = UIEdgeInsetWith(-5.f);
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    self.closeButton = closeButton;
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(closeButton.right_mn + 10.f, 0.f, contentView.width_mn - (closeButton.right_mn + 10.f)*2.f, 18.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:UIFontRegular(18.f)];
    titleLabel.centerY_mn = closeButton.centerY_mn;
    [contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UILabel *detailLabel = [UILabel labelWithFrame:CGRectMake(titleLabel.left_mn, titleLabel.bottom_mn + 10.f, titleLabel.width_mn, 14.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .5f) font:UIFontRegular(14.f)];
    [contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    
    UIImageView *shadow = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    shadow.frame = CGRectMake(0.f, detailLabel.bottom_mn + titleLabel.top_mn, contentView.width_mn, .8f);
    shadow.hidden = YES;
    [contentView addSubview:shadow];
    self.shadow = shadow;
    
    UITableView *tableView = [UITableView tableWithFrame:CGRectMake(0.f, shadow.bottom_mn, contentView.width_mn, 1000.f) style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 70.f;
    tableView.separatorColor = SEPARATOR_COLOR;
    [contentView addSubview:tableView];
    self.tableView = tableView;
    
    UIButton *footerButton = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, tableView.width_mn, 60.f) image:nil title:@" 添加银行卡" titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f) titleFont:UIFontRegular(17.f)];
    footerButton.tag = self.dataArray.count;
    [footerButton setImage:[UIImage imageNamed:@"wx_pay_card"] forState:UIControlStateNormal];
    [footerButton setImage:[UIImage imageNamed:@"wx_pay_card"] forState:UIControlStateHighlighted];
    [footerButton addTarget:self action:@selector(footerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    tableView.tableFooterView = footerButton;
    
    UIImageView *line = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
    line.frame = CGRectMake(0.f, footerButton.height_mn - 1.f, footerButton.width_mn, .8f);
    [footerButton addSubview:line];
    
    [tableView reloadData];
    
    [self addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), self)];
}

- (void)layoutSubviews {
    if (self.tableView.contentSize.height > (self.tableView.rowHeight*3.f + self.tableView.tableFooterView.height_mn)) {
        self.tableView.height_mn = self.tableView.rowHeight*3.f + self.tableView.tableFooterView.height_mn;
    } else {
        self.tableView.height_mn = self.tableView.contentSize.height;
    }
    self.contentView.height_mn = self.tableView.bottom_mn;
    self.shadow.hidden = [self.tableView numberOfRowsInSection:0] > 0;
}

- (void)footerButtonClicked:(UIButton *)button {
    [self dismissWithSelectIndex:button.tag];
}

- (void)handTap:(UITapGestureRecognizer *)recognizer {
    [self dismiss];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXBankCardAlertViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.card.alert.id"];
    if (!cell) {
        cell = [[WXBankCardAlertViewCell alloc] initWithReuseIdentifier:@"com.wx.card.alert.id" size:tableView.rowSize];
    }
    cell.card = self.dataArray[indexPath.row];
    cell.withdraw = self.type == WXBankCardAlertViewWithdraw;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissWithSelectIndex:indexPath.row];
}

#pragma mark - Show && Dismiss
- (void)show {
    if (self.superview) return;
    [[UIWindow mainWindow] endEditing:YES];
    [[UIWindow mainWindow] addSubview:self];
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.55f];
        self.contentView.bottom_mn = self.height_mn;
    }];
}

- (void)dismiss {
    [self dismissWithSelectIndex:-1];
}

- (void)dismissWithSelectIndex:(NSInteger)index {
    if (!self.superview) return;
    [UIView animateWithDuration:.3f animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (index < 0) return;
        if (index == self.tableView.tableFooterView.tag) {
            if ([self.delegate respondsToSelector:@selector(alertViewNeedsAddNewCard:)]) {
                [self.delegate alertViewNeedsAddNewCard:self];
            }
        } else if ([self.delegate respondsToSelector:@selector(alertView:didSelectCard:)]) {
            if (index >= self.dataArray.count) return;
            [self.delegate alertView:self didSelectCard:self.dataArray[index]];
        }
    }];
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

- (void)setType:(WXBankCardAlertViewType)type {
    _type = type;
    if (type == WXBankCardAlertViewRecharge) {
        self.detailLabel.hidden = YES;
        self.titleLabel.text = @"选择充值银行卡";
        self.shadow.top_mn = self.titleLabel.bottom_mn + self.titleLabel.top_mn;
    } else {
        self.detailLabel.hidden = NO;
        self.detailLabel.text = @"请留意各银行到账时间";
        self.titleLabel.text = @"选择到账银行卡";
        self.shadow.top_mn = self.detailLabel.bottom_mn + self.titleLabel.top_mn;
    }
    self.tableView.top_mn = self.shadow.bottom_mn;
    [self.tableView reloadData];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
