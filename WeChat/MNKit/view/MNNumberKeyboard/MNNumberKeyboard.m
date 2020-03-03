//
//  MNNumberKeyboard.m
//  MNKit
//
//  Created by Vincent on 2019/4/13.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNNumberKeyboard.h"

@interface MNNumberKeyboard ()<UIInputViewAudioFeedback>
@property (nonatomic, copy) NSString *text;
@end

#define MNNumberKeyButtonHeight     55.f

@implementation MNNumberKeyboard
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    self.text = @"";
    self.precision = 0;
    self.inputDecimalEnabled = NO;
    self.backgroundColor = UIColorWithSingleRGB(240.f);
}

- (void)createView {
    CGFloat interval = self.width_mn/3.f;
    __block CGFloat height = 0.f;
    NSArray <NSString *>*titles = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", (self.inputDecimalEnabled ? @"." : @""), @"0", @""];
    [self gridLayoutWithInitial:CGRectMake(0.f, 0.f, interval, MNNumberKeyButtonHeight) offset:UIOffsetZero count:titles.count handler:^(CGRect rect, NSUInteger idx, BOOL *stop) {
        NSString *title = titles[idx];
        UIButton *button = [UIButton buttonWithFrame:rect
                                               image:[UIImage imageWithColor:[UIColor whiteColor]]
                                               title:nil
                                          titleColor:UIColorWithAlpha([UIColor darkTextColor], .8f)
                                                titleFont:UIFontWithNameSize(MNFontNameMedium, 22.f)];
        button.tag = idx;
        [button setTitle:title forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:UIColorWithSingleRGB(240.f)] forState:UIControlStateHighlighted];
        if (title.length <= 0) {
            [button setBackgroundImage:[UIImage imageWithColor:UIColorWithSingleRGB(240.f)] forState:UIControlStateNormal];
        }
        if (idx == 11) {
            UIImage *image = [MNBundle imageForResource:@"keyboard_delete"];
            CGSize size = CGSizeMultiplyToWidth(image.size, 40.f);
            [button setImage:[MNBundle imageForResource:@"keyboard_delete_highlight"] forState:UIControlStateNormal];
            [button setImage:image forState:UIControlStateHighlighted];
            button.imageEdgeInsets = UIEdgeInsetsMake(MEAN(button.height_mn - size.height), MEAN(button.width_mn - size.width), MEAN(button.height_mn - size.height), MEAN(button.width_mn - size.width));
        }
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        height = button.bottom_mn;
    }];
    self.height_mn = height + UITabSafeHeight();
    
    CGFloat margin = height/4.f;
    for (NSInteger idx = 0; idx < 4; idx++) {
        UIView *horLine = [[UIView alloc] initWithFrame:CGRectMake(0.f, margin*idx, self.width_mn, .5f)];
        horLine.backgroundColor = UIColorWithSingleRGB(240.f);
        [self addSubview:horLine];
        if (idx%2 != 0) continue;
        UIView *verLine = [[UIView alloc] initWithFrame:CGRectMake(interval*((idx/2) + 1), 0.f, .5f, height)];
        verLine.backgroundColor = UIColorWithSingleRGB(240.f);
        [self addSubview:verLine];
    }
}

#pragma mark - Event
- (void)buttonClicked:(UIButton *)button {
    if (button.tag == 9 && !self.inputDecimalEnabled) return;
    [[UIDevice currentDevice] playInputClick];
    if (button.tag == 11) {
        if (self.text.length > 0) {
            NSMutableString *string = [[NSMutableString alloc] initWithString:self.text];
            [string replaceCharactersInRange:NSMakeRange(self.text.length - 1, 1) withString:@""];
            self.text = string;
            if ([self.delegate respondsToSelector:@selector(numberKeyboardTextDidChange:)]) {
                [self.delegate numberKeyboardTextDidChange:self];
            }
        }
        if ([self.delegate respondsToSelector:@selector(numberKeyboardDidClickDeleteButton:)]) {
            [self.delegate numberKeyboardDidClickDeleteButton:self];
        }
    } else {
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title.length <= 0) return;
        if ([self.delegate respondsToSelector:@selector(numberKeyboardDidSelectNumber:)]) {
            [self.delegate numberKeyboardDidSelectNumber:title];
        }
        /// 不可直接输入小数点或重复输入小数点
        if ([title isEqualToString:@"."] && (self.text.length <= 0 || [self.text containsString:title])) return;
        /// 小数模式下, 第一个数字已经是0, 接下来必须是小数点
        if (self.inputDecimalEnabled && self.text.length == 1 && [[self.text substringToIndex:1] isEqualToString:@"0"] && ![title isEqualToString:@"."]) return;
        /// 确保精度
        if (self.precision > 0 && [self.text rangeOfString:@"."].location == (self.text.length - (self.precision + 1))) return;
        NSMutableString *string = [[NSMutableString alloc] initWithString:self.text];
        [string appendString:title];
        self.text = string;
        if ([self.delegate respondsToSelector:@selector(numberKeyboardTextDidChange:)]) {
            [self.delegate numberKeyboardTextDidChange:self];
        }
    }
}

#pragma mark - 是否允许输入小数
- (void)setInputDecimalEnabled:(BOOL)inputDecimalEnabled {
    if (inputDecimalEnabled == _inputDecimalEnabled) return;
    _inputDecimalEnabled = inputDecimalEnabled;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == 9 && [obj isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)obj;
            [button setTitle:(self.inputDecimalEnabled ? @"." : @"") forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:(self.inputDecimalEnabled ? [UIColor whiteColor  ] : UIColorWithSingleRGB(240.f))] forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - 重置键盘状态
- (void)updateIfNeeded {
    self.text = @"";
    if ([self.delegate respondsToSelector:@selector(numberKeyboardTextDidChange:)]) {
        [self.delegate numberKeyboardTextDidChange:self];
    }
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    [super setFrame:frame];
}

#pragma mark - UIInputViewAudioFeedback<键盘音支持>
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
