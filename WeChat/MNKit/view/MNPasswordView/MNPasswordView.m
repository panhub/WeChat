//
//  MNPasswordView.m
//  MNKit
//
//  Created by Vincent on 2018/10/24.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNPasswordView.h"
#import "UITextField+MNHelper.h"

@interface MNPasswordView ()<UITextFieldDelegate>
@property (nonatomic) CGSize retainSize;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, strong) NSMutableArray <MNPasswordItem *>*items;
@end
#define MNPasswordMaskFont          10.f
@implementation MNPasswordView
- (NSMutableArray <MNPasswordItem *>*)items {
    if (!_items) {
        _items = [NSMutableArray arrayWithCapacity:6];
    }
    return _items;
}

- (void)initialized {
    _password = @"";
    _capacity = 0;
    _animated = YES;
    _secureTextEntry = YES;
    _normalColor = [UIColor darkTextColor];
    _highlightColor = [UIColor redColor];
    _textColor = [UIColor darkTextColor];
    _font = [UIFont systemFontOfSize:27.f];
    _type = MNPasswordViewTypeGrid;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSAssert(frame.size.height > MNPasswordMaskFont, @"height must > 10.f");
        [self initialized];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame capacity:(NSUInteger)capacity {
    if (self = [self initWithFrame:frame]) {
        NSAssert(capacity > 1, @"item count must > 10.f");
        _capacity = capacity;
        [self createView];
    }
    return self;
}

- (void)createView {
    /**输入区*/
    UITextField *textField = [[UITextField alloc]initWithFrame:self.bounds];
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = [UIColor clearColor];
    textField.tintColor = [UIColor clearColor];
    textField.borderStyle = UITextBorderStyleNone;
    textField.clearButtonMode = UITextFieldViewModeNever;
    textField.clearsOnBeginEditing = NO;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    textField.performActions = MNTextFieldActionNone;
    [self addSubview:textField];
    _textField = textField;
    /**计算间隔*/
    CGFloat margin = (textField.width_mn - textField.height_mn*_capacity)/(_capacity - 1);
    margin = MAX(margin, 0.f);
    /**美化视图*/
    for (NSInteger idx = 0; idx < _capacity; idx++) {
        /**明文*/
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((textField.height_mn + margin)*idx, 0.f, textField.height_mn, textField.height_mn)];
        label.font = _font;
        label.textColor = _textColor;
        label.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(becomeFirstResponder)];
        [recognizer setNumberOfTapsRequired:1];
        [label addGestureRecognizer:recognizer];
        [textField addSubview:label];
        /**插入物,拒绝交互*/
        UIControl *insets = [[UIControl alloc] initWithFrame:CGRectMake(MaxX(label), MinY(label), margin, Height(label))];
        [textField addSubview:insets];
        /**密文*/
        CALayer *mask = [CALayer layer];
        mask.frame = CGRectMake(MEAN(label.width_mn - MNPasswordMaskFont), MEAN(label.height_mn - MNPasswordMaskFont), MNPasswordMaskFont, MNPasswordMaskFont);
        mask.cornerRadius = MEAN(mask.height_mn);
        mask.masksToBounds = YES;
        mask.contentsScale = [UIScreen mainScreen].scale;
        mask.backgroundColor = [_textColor CGColor];
        [label.layer addSublayer:mask];
        /**底部横线*/
        CALayer *shadow = [CALayer layer];
        shadow.frame = CGRectMake(0.f, label.height_mn - _borderWidth, label.width_mn, _borderWidth);
        shadow.contentsScale = [UIScreen mainScreen].scale;
        shadow.backgroundColor = [[UIColor darkTextColor] CGColor];
        [label.layer addSublayer:shadow];
        /**保存模型*/
        MNPasswordItem *item = [MNPasswordItem new];
        item.index = idx;
        item.label = label;
        item.shadow = shadow;
        item.mask = mask;
        [self.items addObject:item];
    }
    /**记录此时的Size*/
    _retainSize = self.size_mn;
    /**每次重塑UI时保证密码位数不可越界*/
    if (_password.length > _capacity) {
        _password = [_password substringToIndex:_capacity];
    }
    /**根据密码美化视图*/
    [self updatePassword];
}

#pragma mark - 清空子视图
- (void)removeSubviews {
    [_items removeAllObjects];
    [_textField removeFromSuperview];
}

#pragma mark - UI
- (void)setCapacity:(NSUInteger)capacity {
    if (capacity <= 1 || capacity == _capacity) return;
    _capacity = capacity;
    [self removeSubviews];
    [self createView];
}

- (void)setReturnKeyType:(UIReturnKeyType)returnKeyType {
    _textField.returnKeyType = returnKeyType;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
    _textField.keyboardType = keyboardType;
}

- (void)setTextColor:(UIColor *)textColor {
    if (!textColor) return;
    _textColor = textColor;
    [_items enumerateObjectsUsingBlock:^(MNPasswordItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.label.textColor = textColor;
        obj.mask.backgroundColor = textColor.CGColor;
    }];
}

- (void)setFont:(UIFont *)font {
    if (!font) return;
    _font = font;
    [_items enumerateObjectsUsingBlock:^(MNPasswordItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.label.font = font;
    }];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (borderWidth == _borderWidth) return;
    _borderWidth = borderWidth;
    [_items enumerateObjectsUsingBlock:^(MNPasswordItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.type == MNPasswordViewTypeGrid) {
            if (obj.border) [obj.border removeFromSuperlayer];
            UIRectEdge edges = UIRectEdgeAll;
            if ([self.delegate respondsToSelector:@selector(passwordView:itemBorderEdgeOfIndex:)]) {
                edges = [self.delegate passwordView:self itemBorderEdgeOfIndex:obj.index];
            }
            CAShapeLayer *border = [obj.label.layer borderLayerWithLineWidth:borderWidth byEdges:edges];
            [obj.label.layer addSublayer:border];
            obj.border = border;
        }
        obj.shadow.top_mn = obj.label.height_mn - borderWidth;
        obj.shadow.height_mn = borderWidth;
    }];
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
    if (secureTextEntry == _secureTextEntry) return;
    _secureTextEntry = secureTextEntry;
    [self updatePassword];
}

- (void)setAnimated:(BOOL)animated {
    if (animated == _animated) return;
    _animated = animated;
    [self updatePassword];
}

- (void)setStyle:(MNPasswordViewType)style {
    if (style == _type) return;
    _type = style;
    [self updatePassword];
}

- (void)setNormalColor:(UIColor *)normalColor {
    _normalColor = normalColor;
    [self updatePassword];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self updatePassword];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(passwordViewShouldBeginEditing:)]) {
        return [_delegate passwordViewShouldBeginEditing:self];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(passwordViewDidEndEditing:)]) {
        [_delegate passwordViewDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(passwordViewShouldReturn:)]) {
        return [_delegate passwordViewShouldReturn:self];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length > 1 || _items.count <= 0) return NO;
    BOOL change = range.location + string.length <= _capacity;
    if (change) {
        NSMutableString *password = [NSMutableString stringWithCapacity:(range.location + string.length)];
        [password setString:textField.text];
        [password replaceCharactersInRange:range withString:string];
        _password = [password copy];
        [self updatePassword];
        /**不在display方法里回调是因为初始化时会触发*/
        if ([_delegate respondsToSelector:@selector(passwordView:didChangePassword:)]) {
            [_delegate passwordView:self didChangePassword:_password];
        }
    }
    return change;
}

#pragma mark - 密码处理
- (void)updatePassword {
    NSUInteger length = _password.length;
    [_items enumerateObjectsUsingBlock:^(MNPasswordItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < length) {
            /**密码部分*/
            /// 密码
            if (_secureTextEntry) {
                [item.mask setHidden:NO];
                item.label.text = @"";
            } else {
                NSString *password = [_password substringWithRange:NSMakeRange(idx, 1)];
                [item.mask setHidden:YES];
                item.label.text = password;
            }
            /// 边框
            if (_type == MNPasswordViewTypeGrid) {
                item.shadow.hidden = YES;
                item.border.strokeColor = _highlightColor.CGColor;
            } else {
                item.shadow.hidden = NO;
                item.shadow.backgroundColor = _highlightColor.CGColor;
                item.border.strokeColor = [UIColor clearColor].CGColor;
            }
        } else {
            /**空白部分*/
            /// 密码
            item.label.text = @"";
            [item.mask setHidden:YES];
            /// 边框
            if (_type == MNPasswordViewTypeGrid) {
                item.shadow.hidden = YES;
                item.border.strokeColor = _animated ? _normalColor.CGColor : [UIColor clearColor].CGColor;
            } else {
                item.border.strokeColor = [UIColor clearColor].CGColor;
                item.shadow.backgroundColor = _normalColor.CGColor;
                item.shadow.hidden = !_animated;
            }
        }
    }];
}

- (BOOL)shouldInputPasswordCharacter:(NSString *)character {
    if (!character) return NO;
    BOOL should = [self textField:_textField shouldChangeCharactersInRange:_textField.selectedRange replacementString:character];
    if (should) _textField.text = _password;
    return should;
}

- (void)deleteBackward {
    if (_textField.text.length <= 0 || _password.length <= 0) return;
    NSRange selectedRange = _textField.selectedRange;
    if (selectedRange.location == NSNotFound || selectedRange.location == 0) return;
    if ([self textField:_textField shouldChangeCharactersInRange:NSMakeRange(selectedRange.location-1, 1) replacementString:@""]) {
        _textField.text = _password;
    }
}

- (void)deleteAllPassword {
    _password = @"";
    _textField.text = @"";
    [self updatePassword];
}

#pragma mark - Rewrite
- (void)layoutSubviews {
    if (!CGSizeEqualToSize(self.size_mn, _retainSize) && _capacity > 1) {
        BOOL flag = [_textField isFirstResponder];
        [self removeSubviews];
        [self createView];
        [self updatePassword];
        if (flag) {
            [_textField becomeFirstResponder];
        }
    }
}

- (void)setInputView:(__kindof UIView *)inputView {
    _textField.inputView = inputView;
}

- (void)reloadInputViews {
    [_textField reloadInputViews];
}

- (BOOL)isFirstResponder {
    return [_textField isFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_textField resignFirstResponder];
}

@end

@implementation MNPasswordItem
@end
