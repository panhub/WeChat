//
//  MNActionSheetController.m
//  MNFoundation
//
//  Created by Vicent on 2020/10/2.
//

#import "MNActionSheetController.h"
#import "UIButton+MNHelper.h"
#import "UIFont+MNHelper.h"
#import "UIColor+MNHelper.h"

@interface MNActionSheetController ()
@property (nonatomic, copy) id sheetTitle;
@property (nonatomic, copy) id cancelButtonTitle;
@property (nonatomic, copy) NSArray <id>*otherButtonTitles;
@property (nonatomic, copy) MNActionSheetControllerHandler handler;
@property (nonatomic, weak) id<MNActionSheetControllerDelegate> delegate;
@end


#define MNActionSheetButtonHeight               53.f
#define MNActionSheetButtonMargin              (UIScreen.mainScreen.scale < 3.f ? 1.f : .8f)
#define MNActionSheetCancelButtonMargin     8.f

@implementation MNActionSheetController
+ (instancetype)actionSheetWithTitle:(id _Nullable)title
                            delegate:(id<MNActionSheetControllerDelegate>_Nullable)delegate
                   cancelButtonTitle:(id _Nullable)cancelButtonTitle
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
    return [[MNActionSheetController alloc] initWithTitle:title delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles];
}

+ (instancetype)actionSheetWithTitle:(id _Nullable)title
                   cancelButtonTitle:(id _Nullable)cancelButtonTitle
                             handler:(MNActionSheetControllerHandler _Nullable)handler
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
    return [[MNActionSheetController alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles handler:handler];
}

- (instancetype)initWithTitle:(NSString *_Nullable)title
                     delegate:(id<MNActionSheetControllerDelegate> _Nullable)delegate
            cancelButtonTitle:(id _Nullable)cancelButtonTitle
            otherButtonTitles:(NSArray <id>*)otherButtonTitles {
    NSInteger buttonCount = otherButtonTitles.count;
    if (cancelButtonTitle && [cancelButtonTitle length] > 0) buttonCount ++;
    if (buttonCount <= 1) return nil;
    CGFloat height = otherButtonTitles.count*MNActionSheetButtonHeight + (otherButtonTitles.count - 1)*MNActionSheetButtonMargin;
    if (title && [title length] > 0) height += (MNActionSheetButtonHeight/3.f*2.f + MNActionSheetButtonMargin);
    if (cancelButtonTitle && [cancelButtonTitle length] > 0) height += (MNActionSheetButtonHeight + MNActionSheetCancelButtonMargin);
    height += MN_TAB_SAFE_HEIGHT;
    if (self = [super initWithFrame:CGRectMake(0.f, 0.f, UIScreen.mainScreen.bounds.size.width, height)]) {
        self.delegate = delegate;
        self.otherButtonTitles = otherButtonTitles ? : @[];
        if (title && [title length] > 0) self.sheetTitle = title;
        if (cancelButtonTitle && [cancelButtonTitle length] > 0) self.cancelButtonTitle = cancelButtonTitle;
    }
    return self;
}

- (instancetype)initWithTitle:(id _Nullable)title
            cancelButtonTitle:(id _Nullable)cancelButtonTitle
                otherButtonTitles:(NSArray <id>*)otherButtonTitles
            handler:(MNActionSheetControllerHandler _Nullable)handler {
    NSInteger buttonCount = otherButtonTitles.count;
    if (cancelButtonTitle && [cancelButtonTitle length] > 0) buttonCount ++;
    if (buttonCount <= 1) return nil;
    CGFloat height = otherButtonTitles.count*MNActionSheetButtonHeight + (otherButtonTitles.count - 1)*MNActionSheetButtonMargin;
    if (title && [title length] > 0) height += (MNActionSheetButtonHeight/3.f*2.f + MNActionSheetButtonMargin);
    if (cancelButtonTitle && [cancelButtonTitle length] > 0) height += (MNActionSheetButtonHeight + MNActionSheetCancelButtonMargin);
    height += MN_TAB_SAFE_HEIGHT;
    if (self = [super initWithFrame:CGRectMake(0.f, 0.f, UIScreen.mainScreen.bounds.size.width, height)]) {
        self.handler = handler;
        self.otherButtonTitles = otherButtonTitles ? : @[];
        if (title && [title length] > 0) self.sheetTitle = title;
        if (cancelButtonTitle && [cancelButtonTitle length] > 0) self.cancelButtonTitle = cancelButtonTitle;
    }
    return self;
}

- (void)initialized {
    [super initialized];
    self.modalPresentationStyle = UIModalPresentationCustom;
}

- (void)createView {
    [super createView];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = MN_RGB(247.f);
    self.contentView.backgroundColor = MN_RGB(247.f);
    
    __block CGFloat margin = 0.f;
    if (self.sheetTitle) {
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MNActionSheetButtonHeight/3.f*2.f)
                                                 text:self.sheetTitle
                                            alignment:NSTextAlignmentCenter
                                            textColor:(self.titleColor ? : [UIColor.darkTextColor colorWithAlphaComponent:.6f])
                                                 font:UIFontWithNameSize(MNFontNameRegular, 13.f)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:titleLabel];
        margin = titleLabel.bottom_mn + MNActionSheetButtonMargin;
        [self.view.layer setMaskRadius:15.f byCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    }
    
    [self.otherButtonTitles enumerateObjectsUsingBlock:^(id _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, margin, self.contentView.width_mn, MNActionSheetButtonHeight)
                                             image:nil
                                               title:title
                                          titleColor:self.buttonTitleColor
                                           titleFont:UIFontWithNameSize(MNFontNameRegular, 17.f)];
        [button setTag:idx];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        margin = button.bottom_mn + MNActionSheetButtonMargin;
    }];
    
    if (self.cancelButtonTitle) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, MNActionSheetButtonHeight)
                                             image:nil
                                               title:self.cancelButtonTitle
                                          titleColor:self.cancelButtonTitleColor
                                           titleFont:UIFontWithNameSize(MNFontNameRegular, 17.f)];
        button.bottom_mn = self.contentView.height_mn - MN_TAB_SAFE_HEIGHT;
        [button setTag:self.otherButtonTitles.count];
        [button setBackgroundColor:UIColor.whiteColor];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
    }
}

#pragma mark - Show&Dismiss
- (void)show {
    [self showInController:nil];
}

- (void)showInController:(UIViewController *)parentViewController {
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheetController:)]) {
        [self.delegate willPresentActionSheetController:self];
    }
    __weak typeof(self) weakself = self;
    if (!parentViewController) parentViewController = [self forwardViewController];
    [parentViewController presentViewController:self animated:YES completion:^{
        if ([weakself.delegate respondsToSelector:@selector(didPresentActionSheetController:)]) {
            [weakself.delegate didPresentActionSheetController:weakself];
        }
    }];
}

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(willDismissActionSheetController:)]) {
        [self.delegate willDismissActionSheetController:self];
    }
    __weak typeof(self) weakself = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender) {
            if (weakself.handler) weakself.handler(weakself, sender.tag);
            if (sender.tag == weakself.otherButtonTitles.count && [weakself.delegate respondsToSelector:@selector(actionSheetControllerCancelButtonClicked:)]) {
                [weakself.delegate actionSheetControllerCancelButtonClicked:weakself];
            }
            if ([weakself.delegate respondsToSelector:@selector(actionSheetController:buttonClickedAtIndex:)]) {
                [weakself.delegate actionSheetController:weakself buttonClickedAtIndex:sender.tag];
            }
        }
        if ([weakself.delegate respondsToSelector:@selector(didDismissActionSheetController:)]) {
            [weakself.delegate didDismissActionSheetController:weakself];
        }
    }];
}

#pragma mark - Setter
- (void)setTintColor:(UIColor *)tintColor {
    self.view.backgroundColor = tintColor;
    self.contentView.backgroundColor = tintColor;
}

#pragma mark - Getter
- (NSString *)title {
    return self.sheetTitle ? ([self.sheetTitle isKindOfClass:NSString.class] ? self.sheetTitle : ((NSAttributedString*)(self.sheetTitle)).string) : nil;
}

- (UIColor *)buttonTitleColor {
    return _buttonTitleColor ? : [UIColor.darkTextColor colorWithAlphaComponent:.8f];
}

- (UIColor *)cancelButtonTitleColor {
    return _cancelButtonTitleColor ? : self.buttonTitleColor;
}

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

- (UIViewController *)forwardViewController {
    UIViewController *viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    do {
        if (viewController.presentedViewController) {
            viewController = viewController.presentedViewController;
        } else if ([viewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            viewController = nav.viewControllers.count ? nav.viewControllers.lastObject : nil;
        } else if ([viewController isKindOfClass:UITabBarController.class]) {
            UITabBarController *tab = (UITabBarController *)viewController;
            viewController = tab.viewControllers.count ? tab.selectedViewController : nil;
        } else {
            break;
        }
    } while (viewController != nil);
    return viewController;
}

#pragma mark - Super
- (MNControllerTransitionStyle)transitionAnimationStyle {
    return MNControllerTransitionStyleModal;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSheetModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSheetModal];
}

- (void)beginDismissTransitionAnimation {
    [self dismiss:nil];
}

@end
