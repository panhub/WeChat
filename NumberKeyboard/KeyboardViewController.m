//
//  KeyboardViewController.m
//  NumberKeyboard
//
//  Created by Vicent on 2020/3/7.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "KeyboardViewController.h"
#import "MNLayoutConstraint.h"
#import "UIView+MNLayout.h"
#import "UIColor+MNHelper.h"
#import "UIImage+NKHelper.h"

#define NKNextButtonTag     100
#define NKDeleteButtonTag   200
#define NKHorSeparatorTag   300
#define NKVerSeparatorTag   400

@interface KeyboardViewController ()
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@property (nonatomic, strong) UIButton *deleteKeyboardButton;
@end

@implementation KeyboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorWithSingleRGB(240.f);
    
    NSArray <NSString *>*keys = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @(NKNextButtonTag).stringValue, @"0", @(NKDeleteButtonTag).stringValue];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *keyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        keyButton.tag = obj.integerValue;
        keyButton.enabled = YES;
        keyButton.userInteractionEnabled = NO;
        [keyButton setTitleColor:UIColor.darkTextColor forState:UIControlStateNormal];
        keyButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:22.f];
        if (keyButton.tag != NKNextButtonTag && keyButton.tag != NKDeleteButtonTag) {
            [keyButton setTitle:obj forState:UIControlStateNormal];
        }
        if ([keyButton titleForState:UIControlStateNormal].length) {
            [keyButton setBackgroundImage:[UIImage imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
        } else {
            [keyButton setBackgroundImage:[UIImage imageWithColor:self.view.backgroundColor] forState:UIControlStateNormal];
        }
        [keyButton setBackgroundImage:[UIImage imageWithColor:self.view.backgroundColor] forState:UIControlStateHighlighted];
        keyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [keyButton addTarget:self action:@selector(keyboardButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        if (keyButton.tag == NKNextButtonTag) {
            //[keyButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
            [keyButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateNormal];
            [keyButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateHighlighted];
            self.nextKeyboardButton = keyButton;
        } else if (keyButton.tag == NKDeleteButtonTag) {
            [keyButton setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
            [keyButton setImage:[UIImage imageNamed:@"keyboard_delete_highlight"] forState:UIControlStateHighlighted];
            self.deleteKeyboardButton = keyButton;
        }
        [self.view addSubview:keyButton];
    }];
    
    for (NSInteger idx = 0; idx < 4; idx++) {
        UIView *horLine = [[UIView alloc] init];
        horLine.tag = NKHorSeparatorTag + idx;
        horLine.backgroundColor = self.view.backgroundColor;
        horLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:horLine];
        if (idx%2 != 0) continue;
        UIView *verLine = [[UIView alloc] init];
        verLine.tag = NKVerSeparatorTag + idx;
        verLine.backgroundColor = self.view.backgroundColor;
        verLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:verLine];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateButtonConstraints];
}

- (void)updateButtonConstraints {
    
    if (self.view.constraints.count) return;
    
    NSInteger rows = 3;
    NSInteger lines = 4;
    CGFloat keyHeight = 55.f;
    CGFloat keyWidth = self.view.width_mn/rows*1.f;
    CGFloat keyboardHeight = keyHeight*lines*1.f;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat w = keyWidth;
    CGFloat h = keyHeight;
    CGFloat xm = 0.f;
    CGFloat ym = 0.f;
    
    self.view.layout.heightEqual(keyboardHeight);
    
    [self.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:UIButton.class]) return;
        NSInteger index = obj.tag;
        if (index == 0) index = 11;
        if (index == NKNextButtonTag) index = 10;
        if (index == NKDeleteButtonTag) index = 12;
        index --;
        CGFloat left = x + (w + xm)*(index%rows);
        CGFloat top = y + (h + ym)*(index/rows);
        obj.layout.leftOffsetToView(self.view, left).topOffsetToView(self.view, top).widthEqual(w).heightEqual(h);
        if (obj.tag == NKNextButtonTag) {
            UIButton *keyButton = (UIButton *)obj;
            [keyButton setImageEdgeInsets:UIEdgeInsetsMake((keyHeight - 23.f)/2.f, (keyWidth - 23.f)/2.f, (keyHeight - 23.f)/2.f, (keyWidth - 23.f)/2.f)];
        } else if (obj.tag == NKDeleteButtonTag) {
            UIButton *keyButton = (UIButton *)obj;
            [keyButton setImageEdgeInsets:UIEdgeInsetsMake((keyHeight - 37.f)/2.f, (keyWidth - 52.f)/2.f, (keyHeight - 37.f)/2.f, (keyWidth - 52.f)/2.f)];
        }
    }];
    
    for (NSInteger idx = 0; idx < lines; idx++) {
        UIView *horLine = [self.view viewWithTag:NKHorSeparatorTag + idx];
        horLine.layout.leftOffsetToView(self.view, 0.f).topOffsetToView(self.view, keyHeight*idx).widthEqual(self.view.width_mn).heightEqual(.5f);
        if (idx%2 != 0) continue;
        UIView *verLine = [self.view viewWithTag:NKVerSeparatorTag + idx];
        verLine.layout.leftOffsetToView(self.view, keyWidth*((idx/2) + 1)).topOffsetToView(self.view, 0.f).widthEqual(.5f).heightEqual(self.view.height_mn);
    }
}

- (void)viewWillLayoutSubviews
{
    self.nextKeyboardButton.hidden = !self.needsInputModeSwitchKey;
    [super viewWillLayoutSubviews];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

#pragma mark - 键盘按钮点击
- (void)keyboardButtonTouchUpInside:(UIButton *)keyButton {
    NSLog(@"");
}

@end
