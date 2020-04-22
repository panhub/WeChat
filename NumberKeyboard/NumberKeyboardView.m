//
//  NumberKeyboardView.m
//  NumberKeyboard
//
//  Created by Vicent on 2020/4/21.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "NumberKeyboardView.h"
#import "UIView+MNLayout.h"
#import "UIImage+NKHelper.h"
#import "UIView+MNLayout.h"
#import "MNLayoutConstraint.h"
#import "UIColor+MNHelper.h"

#define NKNextButtonTag     100
#define NKDeleteButtonTag   200
#define NKHorSeparatorTag   300
#define NKVerSeparatorTag   400

@implementation NumberKeyboardView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColorWithSingleRGB(240.f);
        
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
                [keyButton setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateNormal];
            }
            [keyButton setBackgroundImage:[UIImage imageWithColor:self.backgroundColor] forState:UIControlStateHighlighted];
            keyButton.translatesAutoresizingMaskIntoConstraints = NO;
            [keyButton addTarget:self action:@selector(keyButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            if (keyButton.tag == NKNextButtonTag) {
                [keyButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateNormal];
                [keyButton setImage:[UIImage imageNamed:@"keyboard_switch"] forState:UIControlStateHighlighted];
            } else if (keyButton.tag == NKDeleteButtonTag) {
                [keyButton setImage:[UIImage imageNamed:@"keyboard_delete"] forState:UIControlStateNormal];
                [keyButton setImage:[UIImage imageNamed:@"keyboard_delete_highlight"] forState:UIControlStateHighlighted];
            }
            [self addSubview:keyButton];
        }];
        
        for (NSInteger idx = 0; idx < 4; idx++) {
            UIView *horLine = [[UIView alloc] init];
            horLine.tag = NKHorSeparatorTag + idx;
            horLine.backgroundColor = self.backgroundColor;
            horLine.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:horLine];
            if (idx%2 != 0) continue;
            UIView *verLine = [[UIView alloc] init];
            verLine.tag = NKVerSeparatorTag + idx;
            verLine.backgroundColor = self.backgroundColor;
            verLine.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:verLine];
        }
    }
    return self;
}

- (void)updateKeyButtons {
    
    NSInteger rows = 3;
    NSInteger lines = 4;
    CGFloat keyWidth = self.width_mn/rows;
    CGFloat keyHeight = self.height_mn/lines;
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat w = keyWidth;
    CGFloat h = keyHeight;
    CGFloat xm = 0.f;
    CGFloat ym = 0.f;
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:UIButton.class]) return;
        NSInteger index = obj.tag;
        if (index == 0) index = 11;
        if (index == NKNextButtonTag) index = 10;
        if (index == NKDeleteButtonTag) index = 12;
        index --;
        CGFloat left = x + (w + xm)*(index%rows);
        CGFloat top = y + (h + ym)*(index/rows);
        obj.layout.leftOffsetToView(self, left).topOffsetToView(self, top).widthEqual(w).heightEqual(h);
        if (obj.tag == NKNextButtonTag) {
            UIButton *keyButton = (UIButton *)obj;
            [keyButton setImageEdgeInsets:UIEdgeInsetsMake((keyHeight - 23.f)/2.f, (keyWidth - 23.f)/2.f, (keyHeight - 23.f)/2.f, (keyWidth - 23.f)/2.f)];
        } else if (obj.tag == NKDeleteButtonTag) {
            UIButton *keyButton = (UIButton *)obj;
            [keyButton setImageEdgeInsets:UIEdgeInsetsMake((keyHeight - 37.f)/2.f, (keyWidth - 52.f)/2.f, (keyHeight - 37.f)/2.f, (keyWidth - 52.f)/2.f)];
        }
    }];
    
    for (NSInteger idx = 0; idx < lines; idx++) {
        UIView *horLine = [self viewWithTag:NKHorSeparatorTag + idx];
        horLine.layout.leftOffsetToView(self, 0.f).topOffsetToView(self, keyHeight*idx).widthEqual(self.width_mn).heightEqual(.5f);
        if (idx%2 != 0) continue;
        UIView *verLine = [self viewWithTag:NKVerSeparatorTag + idx];
        verLine.layout.leftOffsetToView(self, keyWidth*((idx/2) + 1)).topOffsetToView(self, 0.f).widthEqual(.5f).heightEqual(self.height_mn);
    }
}

- (void)keyButtonTouchUpInside:(UIButton *)keyButton {
    
}

@end
