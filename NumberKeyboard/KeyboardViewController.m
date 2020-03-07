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

@interface KeyboardViewController ()
@property (nonatomic, strong) UIButton *nextKeyboardButton;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat keyHeight = 55.f;
    CGFloat keyWidth = self.view.width_mn/3.f;
    CGFloat keyboardHeight = keyHeight*4.f;
    self.view.layout.heightEqual(keyboardHeight);
    
    CGFloat x = 0.f;
    CGFloat y = 0.f;
    CGFloat w = keyWidth;
    CGFloat h = keyHeight;
    CGFloat xm = 0.f;
    CGFloat ym = 0.f;
    NSInteger rows = 3;
    NSArray <NSString *>*keys = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", (self.textDocumentProxy.keyboardType == UIKeyboardTypeDecimalPad ? @"." : @""), @"0", @""];
    for (NSUInteger i = 0; i < keys.count; i++) {
        CGFloat _x = x + (w + xm)*(i%rows);
        CGFloat _y = y + (h + ym)*(i/rows);
        CGRect rect = CGRectMake(_x, _y, w, h);
    }
    
    // Perform custom UI setup here
    self.nextKeyboardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [self.nextKeyboardButton setTitle:NSLocalizedString(@"Next Keyboard", @"Title for 'Next Keyboard' button") forState:UIControlStateNormal];
    [self.nextKeyboardButton sizeToFit];
    self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.nextKeyboardButton addTarget:self action:@selector(handleInputModeListFromView:withEvent:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.view addSubview:self.nextKeyboardButton];
    
    [self.nextKeyboardButton.leftAnchor constraintEqualToAnchor:self.view.leftAnchor].active = YES;
    [self.nextKeyboardButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
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

@end
