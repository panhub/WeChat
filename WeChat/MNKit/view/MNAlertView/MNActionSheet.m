//
//  CustomActionSheet.m
//  MNKit
//
//  Created by Vincent on 2017/4/28.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "MNActionSheet.h"
#import "UIButton+MNHelper.h"
#import "UIFont+MNHelper.h"
#import "UIColor+MNHelper.h"

const NSInteger MNActionSheetTag = 1312141;

/// 判断是否可以追加表单的环境变量
static BOOL MNActionSheetAllowsAppend = YES;
/// 获取表单的Key
static NSString * const MNActionSheetAssociatedKey = @"com.mn.action.sheet.associated.key";

@interface UIView (MNActionSheet)

@property (nonatomic, strong) NSMutableArray <MNActionSheet *>*actionSheets_;

- (void)addActionSheet_:(MNActionSheet *)actionSheet;
- (void)removeActionSheet_:(MNActionSheet *)actionSheet;

@end

@implementation UIView (MNActionSheet)

- (NSMutableArray <MNActionSheet *>*)actionSheets_ {
    NSMutableArray <MNActionSheet *>*container = objc_getAssociatedObject(self, &MNActionSheetAssociatedKey);
    if (!container) {
        container = [NSMutableArray arrayWithCapacity:0];
        self.actionSheets_ = container;
    }
    return container;
}

- (void)setActionSheets_:(NSMutableArray<MNActionSheet *> *)actionSheets_ {
    objc_setAssociatedObject(self, &MNActionSheetAssociatedKey, actionSheets_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addActionSheet_:(MNActionSheet *)actionSheet {
    if (!actionSheet || [self.actionSheets_ containsObject:actionSheet]) return;
    [self.actionSheets_ addObject:actionSheet];
}

- (void)removeActionSheet_:(MNActionSheet *)actionSheet {
    if (!actionSheet || ![self.actionSheets_ containsObject:actionSheet]) return;
    [self.actionSheets_ removeObject:actionSheet];
}

@end

@interface MNActionSheet ()
@property (nonatomic, copy) id title;
@property (nonatomic, copy) id cancelButtonTitle;
@property (nonatomic, copy) NSArray <id>*otherButtonTitles;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) id<MNActionSheetDelegate> delegate;
@property (nonatomic, copy) MNActionSheetHandler handler;
@end;

#define MNActionSheetButtonHeight         53.f
#define MNActionSheetButtonMargin        (UIScreen.mainScreen.scale < 3.f ? 1.f : .8f)
#define MNActionSheetButtonTitleColor    [UIColor.darkTextColor colorWithAlphaComponent:.8f]

@implementation MNActionSheet
#pragma mark - 实例化
+ (instancetype)actionSheetWithTitle:(id)title
                            delegate:(id<MNActionSheetDelegate>)delegate
                   cancelButtonTitle:(id)cancelButtonTitle
                   otherButtonTitles:(id)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray <id>*otherButtonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [otherButtonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [otherButtonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    return [[MNActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

+ (instancetype)actionSheetWithTitle:(id)title
                   cancelButtonTitle:(id)cancelButtonTitle
                             handler:(MNActionSheetHandler)handler
                   otherButtonTitles:(id)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray <NSString *>*otherButtonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [otherButtonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [otherButtonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    return [[MNActionSheet alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler];
}

- (instancetype)initWithTitle:(id)title
                     delegate:(id<MNActionSheetDelegate>)delegate
            cancelButtonTitle:(id)cancelButtonTitle
            otherButtonTitles:(NSArray <id>*)otherButtonTitles {
    if (otherButtonTitles.count <= 1 && (!cancelButtonTitle || [cancelButtonTitle length] <= 0)) return nil;
    MNActionSheet *actionSheet = [[MNActionSheet alloc] initWithTitle:title
                                                             cancelButtonTitle:cancelButtonTitle
                                                    otherButtonTitles:otherButtonTitles];
    actionSheet.delegate = delegate;
    return actionSheet;
}

- (instancetype)initWithTitle:(id)title
            cancelButtonTitle:(id)cancelButtonTitle
            otherButtonTitles:(NSArray <id>*)otherButtonTitles
            handler:(MNActionSheetHandler _Nullable)handler
{
    if (otherButtonTitles.count <= 1 && (!cancelButtonTitle || [cancelButtonTitle length] <= 0)) return nil;
    MNActionSheet *actionSheet = [[MNActionSheet alloc] initWithTitle:title
                                                             cancelButtonTitle:cancelButtonTitle
                                                    otherButtonTitles:otherButtonTitles];
    actionSheet.handler = handler;
    return actionSheet;
}

- (instancetype)initWithTitle:(id)title
                     cancelButtonTitle:(id)cancelButtonTitle
            otherButtonTitles:(NSArray <id>*)otherButtonTitles {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (!self) return nil;
    self.backgroundColor = UIColor.clearColor;
    if (title && [title length] > 0) self.title = title;
    if (cancelButtonTitle && [cancelButtonTitle length] > 0) self.cancelButtonTitle = cancelButtonTitle;
    self.otherButtonTitles = otherButtonTitles ? : @[];
    [self createView];
    return self;
}

#pragma mark - CreateView
- (void)createView {
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.height_mn, self.width_mn, 0.f)];
    contentView.backgroundColor = UIColorWithSingleRGB(247.f);
    [self addSubview:contentView];
    _contentView = contentView;
    
    __block CGFloat margin = 0.f;
    if (self.title) {
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, contentView.width_mn, MNActionSheetButtonHeight/3.f*2.f)
                                                 text:self.title
                                            alignment:NSTextAlignmentCenter
                                            textColor:UIColorWithAlpha([UIColor darkGrayColor], .65f)
                                                 font:UIFontWithNameSize(MNFontNameRegular, 13.f)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:titleLabel];
        margin = titleLabel.bottom_mn + MNActionSheetButtonMargin;
    }
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(id _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, margin, contentView.width_mn, MNActionSheetButtonHeight)
                                             image:nil
                                               title:title
                                          titleColor:MNActionSheetButtonTitleColor
                                           titleFont:UIFontWithNameSize(MNFontNameRegular, 17.f)];
        [button setTag:idx];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        margin = button.bottom_mn + MNActionSheetButtonMargin;
    }];
    
    if (self.cancelButtonTitle) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, margin + 7.f, contentView.width_mn, MNActionSheetButtonHeight)
                                             image:nil
                                               title:self.cancelButtonTitle
                                          titleColor:MNActionSheetButtonTitleColor
                                           titleFont:UIFontWithNameSize(MNFontNameRegular, 17.f)];
        [button setTag:self.otherButtonTitles.count];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        margin = button.bottom_mn;
    } else {
        margin -= MNActionSheetButtonMargin;
    }
    contentView.height_mn = margin + MN_TAB_SAFE_HEIGHT;
}

#pragma mark - MNAlertProtocol
- (void)show {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    if (!keyWindow) return;
    [self showInView:keyWindow];
}

- (void)showInView:(UIView *)superview {
    if (!superview) superview = [[[UIApplication sharedApplication] delegate] window];
    [superview addActionSheet_:self];
    if (superview.actionSheets_.count > 1) return;
    [superview endEditing:YES];
    [superview addSubview:self];
    self.center = CGPointMake(superview.bounds.size.width/2.f, superview.bounds.size.height/2.f);
    [UIView animateWithDuration:.33f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.35f];
        self.contentView.bottom_mn = self.height_mn;
    } completion:nil];
}

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(UIButton *)sender {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        if (sender) {
            if (self.handler) self.handler(self, sender.tag);
            if (sender.tag == self.otherButtonTitles.count && [self.delegate respondsToSelector:@selector(actionSheetCancelButtonClicked:)]) {
                [self.delegate actionSheetCancelButtonClicked:self];
            }
            if ([self.delegate respondsToSelector:@selector(actionSheet:buttonClickedAtIndex:)]) {
                [self.delegate actionSheet:self buttonClickedAtIndex:sender.tag];
            }
        }
        [self removeFromSuperview];
    }];
}

+ (void)close {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    NSArray <MNActionSheet *>*actionSheets = keyWindow.actionSheets_.copy;
    if (actionSheets.count <= 0) return;
    BOOL allowsAppend = MNActionSheetAllowsAppend;
    MNActionSheetAllowsAppend = NO;
    [actionSheets enumerateObjectsUsingBlock:^(MNActionSheet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview) [obj removeFromSuperview];
    }];
    [keyWindow.actionSheets_ removeObjectsInArray:actionSheets];
    MNActionSheetAllowsAppend = allowsAppend;
}

+ (BOOL)isPresenting {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    return [keyWindow viewWithTag:MNActionSheetTag] != nil;
}

#pragma mark - Override Super
- (void)removeFromSuperview {
    UIView *superView = self.superview;
    [superView removeActionSheet_:self];
    [super removeFromSuperview];
    if (!MNActionSheetAllowsAppend || superView.actionSheets_.count <= 0 || !superView.window) return;
    MNActionSheet *actionSheet = superView.actionSheets_.firstObject;
    if (actionSheet) [actionSheet showInView:superView];
}

#pragma mark - Setter
- (void)setButtonTitleColor:(UIColor *)buttonTitleColor {
    if (!buttonTitleColor) return;
    _buttonTitleColor = buttonTitleColor;
    NSUInteger cancelButtonIndex = [self cancelButtonIndex];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag != cancelButtonIndex) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    _cancelButtonTitleColor = cancelButtonTitleColor;
    if (!self.cancelButtonTitle) return;
    NSUInteger cancelButtonIndex = [self cancelButtonIndex];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == cancelButtonIndex) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index {
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == index) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
        }
    }];
}

- (void)setTintColor:(UIColor *)tintColor {
    self.contentView.backgroundColor = tintColor;
}

#pragma mark - Getter
- (UIButton *)buttonOfIndex:(NSUInteger)buttonIndex {
    __block UIButton *button;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == buttonIndex) {
            button = obj;
            *stop = YES;
        }
    }];
    return button;
}

- (NSInteger)cancelButtonIndex {
    return self.cancelButtonTitle ? self.otherButtonTitles.count : NSIntegerMin;
}

- (NSString *)buttonTitleOfIndex:(NSInteger)index {
    if (index == [self cancelButtonIndex]) {
        return [self.cancelButtonTitle isKindOfClass:NSString.class] ? self.cancelButtonTitle : ((NSAttributedString *)(self.cancelButtonTitle)).string;
    } else if (index < self.otherButtonTitles.count) {
        id buttonTitle = [self.otherButtonTitles objectAtIndex:index];
        return [buttonTitle isKindOfClass:NSString.class] ? buttonTitle : ((NSAttributedString *)buttonTitle).string;
    }
    return nil;
}

- (UIColor *)tintColor {
    return self.contentView.backgroundColor;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss:nil];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
