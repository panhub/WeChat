//
//  MNSearchBar.m
//  MNKit
//
//  Created by Vincent on 2019/3/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNSearchBar.h"
#import "MNTextField.h"

@interface MNSearchBar () <MNTextFieldHandler>
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) MNTextField *textField;
@end

@implementation MNSearchBar
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
    }
    return self;
}

- (void)initialized {
    _offset = 15.f;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (!self.superview || _textField.superview) return;
    [self createView];
}

- (void)createView {
    /// 编辑框
    self.textField.frame = self.bounds;
    if (self.textFieldConfigurationHandler) {
        self.textFieldConfigurationHandler(self, self.textField);
    }
    [self addSubview:self.textField];
    /// 取消按钮
    CGFloat width = [[self.button titleForState:UIControlStateNormal] sizeWithFont:self.button.titleLabel.font].width + _offset;
    self.button.frame = CGRectMake(self.textField.right_mn - width, self.textField.top_mn, width, self.textField.height_mn);
    [self insertSubview:self.button belowSubview:self.textField];
}

#pragma mark - Setter
- (void)setTitleFont:(UIFont *)titleFont {
    self.button.titleLabel.font = titleFont;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.button setTitle:title forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self.button setTitleColor:color forState:state];
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
    [self.textField setDelegate:delegate];
}

- (void)setTintColor:(UIColor *)tintColor {
    [self.textField setTintColor:tintColor];
}

- (void)setText:(NSString *)text {
    [self.textField setText:text];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self.textField setAttributedText:attributedText];
}

#pragma mark - Getter
- (NSString *)text {
    return _textField.text;
}

- (NSAttributedString *)attributedText {
    return _textField.attributedText;
}

- (NSString *)placeholder {
    return self.textField.placeholder;
}

- (UIFont *)titleFont {
    return _button.titleLabel.font;
}

- (MNTextField *)textField {
    if (!_textField) {
        UIImageView *leftView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 16.f, 16.f)
                                                          image:[MNBundle imageForResource:@"icon_bar_search"]];
        MNTextField *textField = [[MNTextField alloc] initWithFrame:CGRectZero];
        textField.leftView = leftView;
        textField.placeholder = @"搜索";
        textField.font = [UIFont systemFontOfSize:17.f];
        textField.placeholderFont = [UIFont systemFontOfSize:17.f];
        textField.backgroundColor = [UIColor whiteColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        UIViewSetBorderRadius(textField, 5.f, .1f, UIColorWithAlpha([UIColor grayColor], .2f));
        textField.leftInset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f);
        textField.placeholderColor = UIColorWithAlpha([UIColor darkTextColor], .45f);
        textField.handler = self;
        _textField = textField;
    }
    return _textField;
}

- (UIButton *)button {
    if (!_button) {
        UIButton *button = [UIButton buttonWithFrame:CGRectZero
                                               image:nil
                                               title:@"取消"
                                          titleColor:[UIColor darkTextColor]
                                                titleFont:UIFontRegular(17.f)];
        button.alpha = 0.f;
        button.touchInset = UIEdgeInsetsMake(-5.f, 0.f, -5.f, 0.f);
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        _button = button;
    }
    return _button;
}

#pragma mark - Cancel
- (void)cancel {
    [self buttonClicked];
}

- (void)buttonClicked {
    BOOL cancel = YES;
    if ([_handler respondsToSelector:@selector(searchBarShouldCancelSearching:)]) {
        cancel = [_handler searchBarShouldCancelSearching:self];
    }
    if (!cancel) return;
    _textField.text = @"";
    [_textField resignFirstResponder];
}

#pragma mark - FirstResponder
- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_textField isFirstResponder];
}

#pragma mark - MNTextFieldHandler
- (void)textFieldWillTransformBeginEditing:(BOOL)animated {
    [self transformBeginSearching:animated];
    if ([_handler respondsToSelector:@selector(searchBarWillBeginSearching:)]) {
        [_handler searchBarWillBeginSearching:self];
    }
}

- (void)textFieldDidTransformBeginEditing:(BOOL)animated {
    if ([_handler respondsToSelector:@selector(searchBarDidBeginSearching:)]) {
        [_handler searchBarDidBeginSearching:self];
    }
}

- (void)textFieldWillTransformEndEditing:(BOOL)animated {
    [self transformEndSearching:animated];
    if ([_handler respondsToSelector:@selector(searchBarWillEndSearching:)]) {
        [_handler searchBarWillEndSearching:self];
    }
}

- (void)textFieldDidTransformEndEditing:(BOOL)animated {
    if ([_handler respondsToSelector:@selector(searchBarDidEndSearching:)]) {
        [_handler searchBarDidEndSearching:self];
    }
}

- (void)textFieldTextDidChange:(MNTextField *)textField {
    if ([_handler respondsToSelector:@selector(searchBarTextDidChange:)]) {
        [_handler searchBarTextDidChange:textField.text];
    }
}

#pragma mark - Animation
- (void)transformBeginSearching:(BOOL)animated {
    if (_button.alpha) return;
    [UIView animateWithDuration:animated ? MNTextFieldAnimationDuration : 0.f delay:0.f options:MNTextFieldAnimationOption animations:^{
        _button.alpha = 1.f;
        _textField.width_mn = _button.left_mn - _textField.left_mn;
    } completion:nil];
}

- (void)transformEndSearching:(BOOL)animated {
    if (_button.alpha == 0.f) return;
    [UIView animateWithDuration:animated ? MNTextFieldAnimationDuration : 0.f delay:0.f options:MNTextFieldAnimationOption animations:^{
        _button.alpha = 0.f;
        _textField.width_mn = _button.right_mn - _textField.left_mn;
    } completion:nil];
}

@end
