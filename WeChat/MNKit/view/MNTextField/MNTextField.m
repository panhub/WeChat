//
//  MNTextField.m
//  MNKit
//
//  Created by Vincent on 2019/3/7.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTextField.h"

@interface MNTextField ()
@property (nonatomic, strong) UILabel *placeLabel;
@property (nonatomic, strong) UIView *contentView;
@end

const CGFloat MNTextFieldAnimationDuration = .3f;
const UIViewAnimationOptions MNTextFieldAnimationOption = UIViewAnimationOptionCurveEaseInOut;

@implementation MNTextField

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
    self.font = UIFontRegular(16.f);
    self.leftInset = UIEdgeInsetsMake(0.f, 5.f, 0.f, 3.f);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChangeNotification:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}

#pragma mark - DidMoveToSuperview
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self createView];
}

- (void)createView {
    if (_contentView || !self.superview || self.type != MNTextFieldTypeCustom || CGSizeEqualToSize(self.size_mn, CGSizeZero)) return;
    if (!self.leftView || self.placeholder.length <= 0) return;
    
    [self handEvents];
    
    UIView *leftView = self.leftView;
    leftView.left_mn = self.leftInset.left;
    leftView.centerY_mn = MEAN(self.height_mn);
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, leftView.right_mn + self.leftInset.right, self.height_mn)];
    
    self.leftView = [[UIView alloc] initWithFrame:contentView.bounds];
    self.leftViewMode = UITextFieldViewModeAlways;

    contentView.userInteractionEnabled = NO;
    [contentView addSubview:leftView];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    NSString *placeholder = self.placeholder ? : self.attributedPlaceholder.string;
    self.placeholder = @"";
    CGSize size = [NSString getStringSize:placeholder font:self.placeholderFont];
    UILabel *placeLabel = [UILabel labelWithFrame:CGRectMake(contentView.right_mn, 0.f, size.width, contentView.height_mn)
                                            text:placeholder
                                       textColor:self.placeholderColor
                                            font:self.placeholderFont];
    placeLabel.textAlignment = NSTextAlignmentCenter;
    placeLabel.userInteractionEnabled = NO;
    [contentView addSubview:placeLabel];
    self.placeLabel = placeLabel;
    
    contentView.width_mn = placeLabel.right_mn;
    
    CGFloat x = MEAN(self.width_mn - contentView.width_mn + self.leftInset.left);
    contentView.left_mn = x;
}

#pragma mark - Events
- (void)handEvents {
    [self addTarget:self action:@selector(didBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(didEndEditing) forControlEvents:UIControlEventEditingDidEnd];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didBeginEditing {
    if (self.text.length > 0) return;
    [self transformBeginEditing:YES];
}

- (void)didEndEditing {
    if (self.text.length > 0) return;
    [self transformEndEditing:YES];
}

- (void)textDidChangeNotification:(NSNotification *)notification {
    if (notification.object != self) return;
    [self displayPlaceholderIfNeeded];
    if ([_handler respondsToSelector:@selector(textFieldTextDidChange:)]) {
        [_handler textFieldTextDidChange:self];
    }
}

- (void)willHideKeyboardNotification:(NSNotification *)notification {
    if (!self.isFirstResponder || self.text.length > 0) return;
    [self transformEndEditing:YES];
}

#pragma mark - 显示/隐藏占位文字
- (void)displayPlaceholderIfNeeded {
    if (!_placeLabel) return;
    _placeLabel.hidden = self.text.length > 0;
}

#pragma mark - Animation
- (void)transformBeginEditing:(BOOL)animated {
    if (_contentView.left_mn == 0.f) return;
    if ([_handler respondsToSelector:@selector(textFieldWillTransformBeginEditing:)]) {
        [_handler textFieldWillTransformBeginEditing:animated];
    }
    UIColor *tintColor = self.tintColor ? : [UIColor colorWithRed:66.f/255.f green:106.f/255.f blue:242.f/255.f alpha:1.f];
    self.tintColor = [UIColor clearColor];
    [UIView animateWithDuration:animated ? MNTextFieldAnimationDuration : 0.f delay:0.f options:MNTextFieldAnimationOption animations:^{
        _contentView.left_mn = 0.f;
    } completion:^(BOOL finished) {
        self.tintColor = tintColor;
        if ([_handler respondsToSelector:@selector(textFieldDidTransformBeginEditing:)]) {
            [_handler textFieldDidTransformBeginEditing:animated];
        }
    }];
}

- (void)transformEndEditing:(BOOL)animated {
    if (_contentView.left_mn > 0.f) return;
    if ([_handler respondsToSelector:@selector(textFieldWillTransformEndEditing:)]) {
        [_handler textFieldWillTransformEndEditing:animated];
    }
    UIColor *tintColor = self.tintColor ? : [UIColor colorWithRed:66.f/255.f green:106.f/255.f blue:242.f/255.f alpha:1.f];
    self.tintColor = [UIColor clearColor];
    [UIView animateWithDuration:animated ? MNTextFieldAnimationDuration : 0.f delay:0.f options:MNTextFieldAnimationOption animations:^{
        _contentView.centerX_mn = self.width_mn/2.f;
    } completion:^(BOOL finished) {
        self.tintColor = tintColor;
        if ([_handler respondsToSelector:@selector(textFieldDidTransformEndEditing:)]) {
            [_handler textFieldDidTransformEndEditing:animated];
        }
    }];
}

- (void)transformEditingIfNeeded {
    if (!_contentView) return;
    if (self.text.length > 0) {
        [self transformBeginEditing:YES];
    } else {
        [self transformEndEditing:YES];
    }
}

#pragma mark - Setter
- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (attributedText.length > 0 && self.attributes.count > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        [attributedString addAttributes:self.attributes range:NSMakeRange(0, attributedString.length)];
        attributedText = [attributedString copy];
    }
    [super setAttributedText:attributedText];
    [self displayPlaceholderIfNeeded];
    [self transformEditingIfNeeded];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self displayPlaceholderIfNeeded];
    [self transformEditingIfNeeded];
}

#pragma mark - Getter
- (NSString *)placeholder {
    if (_placeLabel.text.length > 0) return _placeLabel.text;
    return [super placeholder];
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
