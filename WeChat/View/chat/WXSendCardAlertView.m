//
//  WXSendCardAlertView.m
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXSendCardAlertView.h"
#import "WXUser.h"

#define WXSendCardMargin    15.f

@interface WXSendCardAlertView ()<UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *sendAvatarView;
@property (nonatomic, strong) UILabel *sendNameLabel;
@property (nonatomic, strong) UILabel *cardTextLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, copy) void(^completionHandler)(WXSendCardAlertView *alertView);
@end

@implementation WXSendCardAlertView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    self.backgroundColor = UIColor.clearColor;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn/4.f*3.f, 0.f)];
    contentView.backgroundColor = UIColor.whiteColor;
    contentView.layer.cornerRadius = 5.f;
    contentView.clipsToBounds = YES;
    contentView.alpha = 0.f;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UILabel *sendLabel = [UILabel labelWithFrame:CGRectMake(WXSendCardMargin, WXSendCardMargin + 5.f, contentView.width_mn - WXSendCardMargin*2.f, 17.f)
                                            text:@"发送给:"
                                       textColor:UIColor.darkTextColor
                                            font:UIFontMedium(17.f)];
    [contentView addSubview:sendLabel];
    
    UIImageView *sendAvatarView = [UIImageView imageViewWithFrame:CGRectMake(sendLabel.left_mn, sendLabel.bottom_mn + WXSendCardMargin, 45.f, 45.f) image:nil];
    sendAvatarView.layer.cornerRadius = 4.f;
    sendAvatarView.clipsToBounds = YES;
    [contentView addSubview:sendAvatarView];
    self.sendAvatarView = sendAvatarView;
    
    UILabel *sendNameLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColor.darkTextColor font:UIFontSystem(17.f)];
    sendNameLabel.left_mn = sendAvatarView.right_mn + 11.f;
    [contentView addSubview:sendNameLabel];
    self.sendNameLabel = sendNameLabel;
    
    UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectZero image:UIImageNamed(@"wx_common_list_arrow")];
    arrowView.size_mn = CGSizeMultiplyToHeight(arrowView.image.size, 23.f);
    arrowView.centerY_mn = sendAvatarView.centerY_mn;
    arrowView.right_mn = contentView.width_mn - sendAvatarView.left_mn;
    [contentView addSubview:arrowView];
    
    UIControl *control = [[UIControl alloc] initWithFrame:sendAvatarView.frame];
    control.width_mn = arrowView.right_mn - sendAvatarView.left_mn;
    control.backgroundColor = UIColor.clearColor;
    [control addTarget:self action:@selector(userControlClicked) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:control];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(sendLabel.left_mn, sendAvatarView.bottom_mn + WXSendCardMargin, arrowView.right_mn - sendLabel.left_mn, .5f)];
    separator.backgroundColor = SEPARATOR_COLOR;
    [contentView addSubview:separator];
    
    UILabel *cardTextLabel = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorWithAlpha(UIColor.grayColor, .6f) font:UIFontSystem(16.f)];
    cardTextLabel.left_mn = sendLabel.left_mn;
    cardTextLabel.top_mn = separator.bottom_mn + WXSendCardMargin;
    cardTextLabel.height_mn = cardTextLabel.font.pointSize;
    [contentView addSubview:cardTextLabel];
    self.cardTextLabel = cardTextLabel;
    
    UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(sendLabel.left_mn, cardTextLabel.bottom_mn + 16.f, separator.width_mn, 40.f) font:UIFontSystem(16.f) placeholder:@"给朋友留言" delegate:self];
    textField.font = UIFontSystem(15.f);
    textField.tintColor = THEME_COLOR;
    textField.textColor = UIColor.darkTextColor;
    textField.placeholderFont = textField.font;
    textField.placeholderColor = cardTextLabel.textColor;
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 6.f, textField.height_mn)];
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 6.f, textField.height_mn)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.rightViewMode = UITextFieldViewModeAlways;
    textField.borderStyle = UITextBorderStyleNone;
    UIViewSetBorderRadius(textField, 4.f, .8f, SEPARATOR_COLOR);
    [contentView addSubview:textField];
    self.textField = textField;
    
    separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, textField.bottom_mn + 16.f, contentView.width_mn, .5f)];
    separator.backgroundColor = SEPARATOR_COLOR;
    [contentView addSubview:separator];
    
    NSArray <NSString *>*titles = @[@"取消", @"确定"];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(contentView.width_mn/2.f*idx, separator.bottom_mn, contentView.width_mn/2.f, 53.f)
                                               image:nil
                                               title:obj
                                          titleColor:(idx == 0 ? sendLabel.textColor : TEXT_COLOR)
                                           titleFont:sendLabel.font];
        button.tag = idx;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        contentView.height_mn = button.bottom_mn;
    }];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.f, separator.bottom_mn, .5f, 0.f)];
    line.height_mn = contentView.height_mn - separator.bottom_mn;
    line.centerX_mn = contentView.width_mn/2.f;
    line.backgroundColor = SEPARATOR_COLOR;
    [contentView addSubview:line];
    
    contentView.center_mn = self.bounds_center;
    contentView.transform = CGAffineTransformMakeScale(.95f, .95f);
}

- (void)handEvents {
    @weakify(self);
    // 键盘通知
    [self handNotification:UIKeyboardWillChangeFrameNotification eventHandler:^(NSNotification *notify) {
        UIKeyboardWillChangeFrameConvert(notify, ^(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options) {
            @strongify(self);
            CGFloat bottom = MIN(self.bounds_center.y + self.contentView.height_mn/2.f, to.origin.y);
            [UIView animateWithDuration:duration delay:0.f options:options animations:^{
                self.contentView.bottom_mn = bottom;
            } completion:nil];
        });
    }];
    // 背景点按通知
    [self handTapConfiguration:^(UITapGestureRecognizer *recognizer) {
        @strongify(self);
        recognizer.delegate = self;
    } eventHandler:^(id sender) {
        @strongify(self);
        if (self.textField.isFirstResponder) {
            [self.textField resignFirstResponder];
            return;
        }
        self.completionHandler = nil;
        [self dismiss];
    }];
    // 联系人更新通知
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![notify.object isKindOfClass:WXUser.class]) return;
        if (notify.object == self.toUser) self.toUser = self.toUser;
    }];
    // 联系人删除通知
    [self handNotification:WXUserDeleteNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![notify.object isKindOfClass:WXUser.class]) return;
        if (notify.object == self.toUser) {
            self.userClickHandler = nil;
            self.completionHandler = nil;
            [self removeFromSuperview];
        }
    }];
}

- (void)buttonClicked:(UIButton *)sender {
    if (sender.tag == 0) self.completionHandler = nil;
    [self dismiss];
}

- (void)userControlClicked {
    if (self.userClickHandler) self.userClickHandler(self);
}

#pragma mark - show & dismiss
- (void)showWithCompletionHandler:(void(^)(WXSendCardAlertView *alertView))completionHandler {
    [self showInView:[[UIApplication sharedApplication] keyWindow] completionHandler:completionHandler];
}

- (void)showInView:(UIView *)superview completionHandler:(void(^)(WXSendCardAlertView *alertView))completionHandler {
    if (!superview || self.superview) return;
    [superview addSubview:self];
    self.completionHandler = completionHandler;
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.alpha = 1.f;
        self.contentView.transform = CGAffineTransformIdentity;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.35f];
    } completion:nil];
}

- (void)dismiss {
    if (!self.superview) return;
    @weakify(self);
    [self endEditing:YES];
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        @strongify(self);
        self.contentView.alpha = 0.f;
        self.backgroundColor = UIColor.clearColor;
        self.contentView.transform = CGAffineTransformMakeScale(.95f, .95f);
    } completion:^(BOOL finished) {
        @strongify(self);
        [self removeFromSuperview];
        if (self.completionHandler) self.completionHandler(self);
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return range.location + string.length <= 20;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self;
}

#pragma mark - Setter
- (void)setUser:(WXUser *)user {
    _user = user;
    CGFloat centerY = self.cardTextLabel.centerY_mn;
    self.cardTextLabel.text = [NSString stringWithFormat:@"[个人名片]%@", user.nickname];
    [self.cardTextLabel sizeToFit];
    self.cardTextLabel.centerY_mn = centerY;
}

- (void)setToUser:(WXUser *)toUser {
    _toUser = toUser;
    self.sendAvatarView.image = toUser.avatar;
    self.sendNameLabel.text = toUser.name;
    [self.sendNameLabel sizeToFit];
    self.sendNameLabel.centerY_mn = self.sendAvatarView.centerY_mn;
}

#pragma mark - Getter
- (NSString *)text {
    return self.textField.text;
}

#pragma mark - Overwrite
- (void)setFrame:(CGRect)frame {
    frame = UIScreen.mainScreen.bounds;
    [super setFrame:frame];
}

@end
