//
//  CustomActionSheet.m
//  MNKit
//
//  Created by Vincent on 2017/4/28.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "MNActionSheet.h"

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
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray <NSString *>*otherButtonTitles;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) id<MNActionSheetDelegate> delegate;
@property (nonatomic, copy) MNActionSheetHandler handler;
@end

#define MNActionSheetButtonMargin        .7f
#define MNActionSheetButtonHeight         53.f
#define MNActionSheetButtonTitleColor    UIColorWithAlpha([UIColor darkTextColor], .8f)

@implementation MNActionSheet
#pragma mark - 实例化
+ (instancetype)actionSheetWithTitle:(NSString *)title
                            delegate:(id<MNActionSheetDelegate>)delegate
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION {
    if (otherButtonTitle.length <= 0) return nil;
    NSMutableArray <NSString *>*otherButtonTitles = [NSMutableArray arrayWithCapacity:0];
    [otherButtonTitles addObject:otherButtonTitle];
    va_list args;
    va_start(args, otherButtonTitle);
    while ((otherButtonTitle = va_arg(args, NSString *))) {
        [otherButtonTitles addObject:otherButtonTitle];
    }
    va_end(args);
    return [[MNActionSheet alloc] initWithTitle:title
                                       delegate:delegate
                              cancelButtonTitle:cancelButtonTitle
                              otherButtonTitles:otherButtonTitles];
}

+ (instancetype)actionSheetWithTitle:(NSString *)title
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                             handler:(MNActionSheetHandler)handler
                   otherButtonTitles:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION
{
    if (otherButtonTitle.length <= 0) return nil;
    NSMutableArray <NSString *>*otherButtonTitles = [NSMutableArray arrayWithCapacity:0];
    [otherButtonTitles addObject:otherButtonTitle];
    va_list args;
    va_start(args, otherButtonTitle);
    while ((otherButtonTitle = va_arg(args, NSString *))) {
        [otherButtonTitles addObject:otherButtonTitle];
    }
    va_end(args);
    MNActionSheet *actionSheet = [[MNActionSheet alloc] initWithTitle:title
                                                             delegate:nil
                                                    cancelButtonTitle:cancelButtonTitle
                                                    otherButtonTitles:otherButtonTitles];
    actionSheet.handler = handler;
    return actionSheet;
}

- (instancetype)initWithTitle:(NSString *)title
                     delegate:(id<MNActionSheetDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonTitles {
    if (otherButtonTitles.count <= 0) return nil;
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (!self) return nil;
    self.backgroundColor = [UIColor clearColor];
    self.delegate = delegate;
    self.title = title;
    self.cancelButtonTitle = cancelButtonTitle;
    self.otherButtonTitles = otherButtonTitles;
    [self createView];
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
                      handler:(MNActionSheetHandler)handler
            otherButtonTitles:(NSArray *)otherButtonTitles
{
    MNActionSheet *actionSheet = [[MNActionSheet alloc] initWithTitle:title
                                                             delegate:nil
                                                    cancelButtonTitle:cancelButtonTitle
                                                    otherButtonTitles:otherButtonTitles];
    actionSheet.handler = handler;
    return actionSheet;
}

#pragma mark - CreateView
- (void)createView {
    
    CGFloat width = MIN(self.width_mn, 500.f);
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake((self.width_mn - width)/2.f, self.height_mn, self.width_mn, 0.f)];
    contentView.backgroundColor = UIColorWithSingleRGB(247.f);
    [self addSubview:contentView];
    _contentView = contentView;
    
    __block CGFloat margin = 0.f;
    if (_title.length > 0) {
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, contentView.width_mn, MNActionSheetButtonHeight/3.f*2.f)
                                                 text:_title
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:UIColorWithAlpha([UIColor darkGrayColor], .65f)
                                                 font:UIFontWithNameSize(MNFontNameRegular, 13.f)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [contentView addSubview:titleLabel];
        margin = titleLabel.bottom_mn + MNActionSheetButtonMargin;
    }
    
    [_otherButtonTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
    if (_cancelButtonTitle.length <= 0) {
        margin -= MNActionSheetButtonMargin;
    } else {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, margin + 7.f, contentView.width_mn, MNActionSheetButtonHeight)
                                             image:nil
                                               title:_cancelButtonTitle
                                          titleColor:TEXT_COLOR
                                           titleFont:UIFontWithNameSize(MNFontNameRegular, 17.f)];
        [button setTag:_otherButtonTitles.count];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        margin = button.bottom_mn;
    }
    contentView.height_mn = margin + UITabSafeHeight();
}

#pragma mark - Show & Dismiss
- (void)show {
    [self showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)showInView:(UIView *)view {
    if (!view || _contentView.top_mn < self.height_mn) return;
    [view addActionSheet_:self];
    if (view.actionSheets_.count > 1) return;
    [view addSubview:self];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [UIView animateWithDuration:.33f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.35f];
        self.contentView.bottom_mn = self.height_mn;
    } completion:nil];
}

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(UIButton *)button {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self actionSheetButtonClicked:button];
        [self removeFromSuperview];
    }];
}

- (void)actionSheetButtonClicked:(UIButton *)button {
    if (!button) return;
    if (self.handler) {
        self.handler(self, button.tag);
    }
    if (button.tag == self.otherButtonTitles.count && [self.delegate respondsToSelector:@selector(actionSheetCancelButtonClicked:)]) {
        [self.delegate actionSheetCancelButtonClicked:self];
    }
    if ([self.delegate respondsToSelector:@selector(actionSheet:buttonClickedAtIndex:)]) {
        [self.delegate actionSheet:self buttonClickedAtIndex:button.tag];
    }
}

#pragma mark - 删除表单
+ (void)closeActionSheet {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSArray <MNActionSheet *>*actionSheets = keyWindow.actionSheets_.copy;
    if (actionSheets.count <= 0) return;
    BOOL allowsAppend = MNActionSheetAllowsAppend;
    MNActionSheetAllowsAppend = NO;
    [actionSheets enumerateObjectsUsingBlock:^(MNActionSheet * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    MNActionSheetAllowsAppend = allowsAppend;
}

#pragma mark - Override Super
- (void)removeFromSuperview {
    UIView *superView = self.superview;
    [superView removeActionSheet_:self];
    [super removeFromSuperview];
    if (![superView isKindOfClass:UIWindow.class] && !superView.window) return;
    if (!MNActionSheetAllowsAppend || superView.actionSheets_.count <= 0) return;
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
            ///[button setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    if (!cancelButtonTitleColor) return;
    _cancelButtonTitleColor = cancelButtonTitleColor;
    NSUInteger cancelButtonIndex = [self cancelButtonIndex];
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == cancelButtonIndex) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
            ///[button setTitleColor:cancelButtonTitleColor forState:UIControlStateHighlighted];
        }
    }];
}

- (void)setButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index {
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == index) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
            ///[button setTitleColor:buttonTitleColor forState:UIControlStateHighlighted];
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
    if (_cancelButtonTitle.length <= 0) return NSIntegerMin;
    return _otherButtonTitles.count;
}

- (NSString *)buttonTitleOfIndex:(NSInteger)index {
    if (index == [self cancelButtonIndex]) {
        return _cancelButtonTitle;
    } else if (index < _otherButtonTitles.count) {
        return _otherButtonTitles[index];
    }
    return nil;
}

- (UIColor *)tintColor {
    return self.contentView.backgroundColor;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
