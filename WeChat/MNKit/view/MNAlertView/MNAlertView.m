//
//  MNAlertView.m
//  MNKit
//
//  Created by Vincent on 2018/5/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNAlertView.h"
#import "UIView+MNLayout.h"
#import "NSString+MNHelper.h"

#define kAlertViewButtonHeight        45.5f
#define kAlertViewVerticalMargin      18.f
#define kAlertViewHorizontalMargin   15.f
#define kAlertViewSeparatorHeight    .5f
#define kAlertViewSeparatorColor      [[UIColor darkTextColor] colorWithAlphaComponent:.18f]

const NSInteger MNAlertViewTag = 1413161;

/// 判断是否可以追加弹窗的环境变量
static BOOL MNAlertViewAllowsAppend = YES;
/// 获取弹窗的Key
static NSString * const MNAlertViewAssociatedKey = @"com.mn.alert.view.associated.key";

@interface UIView (MNAlertView)

@property (nonatomic) NSMutableArray <MNAlertView *>*alertViews_;

- (void)addAlertView_:(MNAlertView *)alertView;
- (void)removeAlertView_:(MNAlertView *)alertView;

@end

@implementation UIView (MNAlertView)

- (NSMutableArray <MNAlertView *>*)alertViews_ {
    NSMutableArray <MNAlertView *>*container = objc_getAssociatedObject(self, &MNAlertViewAssociatedKey);
    if (!container) {
        container = [NSMutableArray arrayWithCapacity:0];
        self.alertViews_ = container;
    }
    return container;
}

- (void)setAlertViews_:(NSMutableArray<MNAlertView *> *)alertViews_ {
    objc_setAssociatedObject(self, &MNAlertViewAssociatedKey, alertViews_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addAlertView_:(MNAlertView *)alertView {
    if (!alertView || [self.alertViews_ containsObject:alertView]) return;
    [self.alertViews_ addObject:alertView];
}

- (void)removeAlertView_:(MNAlertView *)alertView {
    if (!alertView || ![self.alertViews_ containsObject:alertView]) return;
    [self.alertViews_ removeObject:alertView];
}

@end

@interface MNAlertView ()
@property (nonatomic, strong) id title;
@property (nonatomic, strong) id message;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, copy) NSArray <id>*buttonTitles;
@property (nonatomic, copy) id ensureButtonTitle;
@property (nonatomic, copy) MNAlertViewHandler handler;
@property (nonatomic, weak) id<MNAlertViewDelegate> delegate;
@end
@implementation MNAlertView
#pragma mark - instance
+ (instancetype)alertViewWithTitle:(id)title
                           message:(id)message
                          delegate:(id<MNAlertViewDelegate>)delegate
                 ensureButtonTitle:(id)ensureButtonTitle
                 otherButtonTitles:(id)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray <id>*buttonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [buttonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [buttonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    if (ensureButtonTitle && [ensureButtonTitle length] > 0) [buttonTitles addObject:ensureButtonTitle];
    if (buttonTitles.count <= 0 || ([title length] <= 0 && [message length] <= 0)) return nil;
    return [[MNAlertView alloc] initWithTitle:title image:nil message:message ensureButtonTitle:ensureButtonTitle buttonTitles:buttonTitles delegate:delegate handler:nil];
}

+ (instancetype)alertViewWithTitle:(id)title
                           message:(id)message
                           handler:(MNAlertViewHandler)handler
                 ensureButtonTitle:(id)ensureButtonTitle
                 otherButtonTitles:(id)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray <id>*buttonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [buttonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [buttonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    if (ensureButtonTitle && [ensureButtonTitle length] > 0) [buttonTitles addObject:ensureButtonTitle];
    if (buttonTitles.count <= 0 || ([title length] <= 0 && [message length] <= 0)) return nil;
    return [[MNAlertView alloc] initWithTitle:title image:nil message:message ensureButtonTitle:ensureButtonTitle buttonTitles:buttonTitles delegate:nil handler:handler];
}

+ (instancetype)alertViewWithTitle:(id)title
                             image:(UIImage *)image
                           message:(id)message
                          delegate:(id<MNAlertViewDelegate>)delegate
                 ensureButtonTitle:(id)ensureButtonTitle
                 otherButtonTitles:(id)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray <id>*buttonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [buttonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [buttonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    if (ensureButtonTitle && [ensureButtonTitle length] > 0) [buttonTitles addObject:ensureButtonTitle];
    if (buttonTitles.count <= 0 || ([title length] <= 0 && [message length] <= 0)) return nil;
    return [[MNAlertView alloc] initWithTitle:title image:image message:message ensureButtonTitle:ensureButtonTitle buttonTitles:buttonTitles delegate:delegate handler:nil];
}

+ (instancetype)alertViewWithTitle:(id)title
                             image:(UIImage *)image
                           message:(id)message
                           handler:(MNAlertViewHandler)handler
                 ensureButtonTitle:(id)ensureButtonTitle
                 otherButtonTitles:(id)otherButtonTitle,...NS_REQUIRES_NIL_TERMINATION
{
    NSMutableArray <id>*buttonTitles = @[].mutableCopy;
    if (otherButtonTitle && [otherButtonTitle length] > 0) {
        [buttonTitles addObject:otherButtonTitle];
        va_list args;
        va_start(args, otherButtonTitle);
        while ((otherButtonTitle = va_arg(args, id))) {
            [buttonTitles addObject:otherButtonTitle];
        }
        va_end(args);
    }
    if (ensureButtonTitle && [ensureButtonTitle length] > 0) [buttonTitles addObject:ensureButtonTitle];
    if (buttonTitles.count <= 0 || ([title length] <= 0 && [message length] <= 0)) return nil;
    return [[MNAlertView alloc] initWithTitle:title image:image message:message ensureButtonTitle:ensureButtonTitle buttonTitles:buttonTitles delegate:nil handler:handler];
}

+ (void)showAlertWithTitle:(id)title
                   message:(id)message
         cancelButtonTitle:(NSString *)cancelButtonTitle {
    MNAlertView *alertView = [MNAlertView alertViewWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           ensureButtonTitle:nil
                                           otherButtonTitles:cancelButtonTitle, nil];
    [alertView show];
}

- (instancetype)initWithTitle:(id)title image:(UIImage *)image message:(id)message ensureButtonTitle:(id)ensureButtonTitle buttonTitles:(NSArray <id>*)buttonTitles delegate:(id<MNAlertViewDelegate>)delegate handler:(MNAlertViewHandler)handler {
    if (self = [super initWithFrame:[[UIScreen mainScreen] bounds]]) {
        self.image = image;
        self.handler = handler;
        self.delegate = delegate;
        self.buttonTitles = buttonTitles ? : @[];
        if (title && [title length] > 0) self.title = title;
        if (message && [message length] > 0) self.message = message;
        if (ensureButtonTitle && [ensureButtonTitle length] > 0) self.ensureButtonTitle = ensureButtonTitle;
        self.backgroundColor = UIColor.clearColor;
        [self createView];
    }
    return self;
}

#pragma mark - createView
- (void)createView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 270.f, 0.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    __block CGFloat margin = kAlertViewVerticalMargin;
    CGFloat kWidth = contentView.width_mn - kAlertViewHorizontalMargin*2.f;
    
    //title
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(kAlertViewHorizontalMargin, margin, kWidth, 0.f) text:_title textColor:nil font:nil];
    [titleLabel setNumberOfLines:0];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    if (titleLabel.text.length > 0) {
        NSAttributedString *attributedTitle = [_title isKindOfClass:NSAttributedString.class] ? _title : [[NSAttributedString alloc] initWithString:_title attributes:self.titleAttributes];
        titleLabel.height_mn = [attributedTitle sizeOfLimitWidth:titleLabel.width_mn].height;
        titleLabel.attributedText = attributedTitle;
        margin = titleLabel.bottom_mn + (_image ? kAlertViewVerticalMargin : 3.f);
    }
    
    //image
    CGSize size = [self imageSizeMultiplyToHeight:50.f];
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, margin, size.width, size.height)
                                                       image:self.image];
    imageView.centerX_mn = contentView.width_mn/2.f;
    [contentView addSubview:imageView];
    self.imageView = imageView;
    margin = imageView.bottom_mn + (size.height > 0.f ? kAlertViewVerticalMargin : 0.f);
    
    //计算内容高度
    NSAttributedString *attributedMessage = self.attributedMessage;
    CGFloat kMessageHeight = [attributedMessage sizeOfLimitWidth:kWidth].height;
    
    /**内容*/
    UILabel *contentLabel = [UILabel labelWithFrame:CGRectMake(kAlertViewHorizontalMargin, margin, kWidth, kMessageHeight)
                                               text:nil
                                          textColor:[UIColor darkTextColor]
                                               font:nil];
    [contentLabel setNumberOfLines:0];
    [contentLabel setTextAlignment:NSTextAlignmentCenter];
    [contentLabel setAttributedText:attributedMessage.copy];
    [contentView addSubview:contentLabel];
    
    margin = contentLabel.bottom_mn + titleLabel.top_mn;
    
    /**分割横线*/
    UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, margin, contentView.width_mn, kAlertViewSeparatorHeight)];
    shadow.contentMode = UIViewContentModeScaleAspectFill;
    shadow.clipsToBounds = YES;
    shadow.image = [UIImage imageWithColor:kAlertViewSeparatorColor];
    [contentView addSubview:shadow];
    margin = shadow.bottom_mn;
    
    /**第一个按钮*/
    UIButton *button1 = [UIButton buttonWithFrame:CGRectMake(0.f, margin, contentView.width_mn, kAlertViewButtonHeight)
                                            image:nil
                                            title:[self.buttonTitles firstObject]
                                       titleColor:[self buttonTitleColorWithTitle:self.buttonTitles.firstObject]
                                             titleFont:[UIFont systemFontOfSize:15.5f]];
    [button1 setTag:0];
    [button1 addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:button1];
    
    margin = button1.bottom_mn;
    
    if (self.buttonTitles.count == 2) {
        
        /**重新约束*/
        button1.width_mn = (contentView.width_mn - kAlertViewSeparatorHeight)/2.f;
        
        UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(button1.right_mn, shadow.bottom_mn, kAlertViewSeparatorHeight, button1.height_mn)];
        line.contentMode = UIViewContentModeScaleAspectFill;
        line.clipsToBounds = YES;
        line.image = [UIImage imageWithColor:kAlertViewSeparatorColor];
        [contentView addSubview:line];
        
        /**第二个按钮*/
        UIButton *button = [UIButton buttonWithFrame:button1.frame
                                                image:nil
                                                title:self.buttonTitles[1]
                                           titleColor:[self buttonTitleColorWithTitle:self.buttonTitles[1]]
                                                 titleFont:button1.titleFont];
        button.left_mn = line.right_mn;
        [button setTag:1];
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
        
    } else if (_buttonTitles.count >= 3) {
        //从第二个按钮计算
        [self.buttonTitles enumerateObjectsUsingBlock:^(id _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) return;
            UIImageView *line = [[UIImageView alloc]initWithFrame:shadow.frame];
            line.top_mn = margin;
            line.contentMode = UIViewContentModeScaleAspectFill;
            line.clipsToBounds = YES;
            line.image = [UIImage imageWithColor:kAlertViewSeparatorColor];
            [contentView addSubview:line];
            
            UIButton *button = [UIButton buttonWithFrame:button1.frame
                                                   image:nil
                                                   title:title
                                              titleColor:[self buttonTitleColorWithTitle:title]
                                                    titleFont:button1.titleFont];
            button.top_mn = line.bottom_mn;
            [button setTag:idx];
            [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:button];
            
            margin = button.bottom_mn;
        }];
    }
    
    contentView.height_mn = margin;
    contentView.center_mn = self.bounds_center;
    UIViewSetCornerRadius(contentView, 10.f);
}

#pragma mark - MNAlertProtocol
- (void)show {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    if (!keyWindow) return;
    [self showInView:keyWindow];
}

- (void)showInView:(UIView *)superview {
    if (!superview) superview = [[[UIApplication sharedApplication] delegate] window];
    [superview addAlertView_:self];
    if ([[superview alertViews_] count] > 1) return;
    [superview endEditing:YES];
    [superview addSubview:self];
    self.center = CGPointMake(superview.bounds.size.width/2.f, superview.bounds.size.height/2.f);
    self.contentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    [UIView animateWithDuration:.38f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(UIButton *)sender {
    [UIView animateWithDuration:(sender ? .15f : CGFLOAT_MIN) animations:^{
        self.backgroundColor = [UIColor clearColor];
    }];
    [UIView animateWithDuration:(sender ? .2f : CGFLOAT_MIN) delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.alpha = 0.f;
        self.contentView.transform = CGAffineTransformMakeScale(.9f, .9f);
    } completion:^(BOOL finished) {
        [self buttonTouchUpInside:sender];
        [self removeFromSuperview];
    }];
}

- (void)buttonTouchUpInside:(UIButton *)sender {
    if (!sender) return;
    if (self.handler) self.handler(self, sender.tag);
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([title isEqualToString:_ensureButtonTitle] && [_delegate respondsToSelector:@selector(alertViewEnsureButtonClicked:)]) {
        [_delegate alertViewEnsureButtonClicked:self];
    }
    if ([_delegate respondsToSelector:@selector(alertView:buttonClickedAtIndex:)]) {
        [_delegate alertView:self buttonClickedAtIndex:sender.tag];
    }
}

+ (void)close {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    NSArray <MNAlertView *>*alertViews = keyWindow.alertViews_.copy;
    if (alertViews.count <= 0) return;
    BOOL allowsAppend = MNAlertViewAllowsAppend;
    MNAlertViewAllowsAppend = NO;
    [alertViews enumerateObjectsUsingBlock:^(MNAlertView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview) [obj removeFromSuperview];
    }];
    [keyWindow.alertViews_ removeObjectsInArray:alertViews];
    MNAlertViewAllowsAppend = allowsAppend;
}

+ (BOOL)isPresenting {
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    return [keyWindow viewWithTag:MNAlertViewTag] != nil;
}

#pragma mark - Override Super
- (void)removeFromSuperview {
    UIView *superview = self.superview;
    [superview removeAlertView_:self];
    [super removeFromSuperview];
    if (!MNAlertViewAllowsAppend || superview.alertViews_.count <= 0 || !superview.window) return;
    MNAlertView *alertView = superview.alertViews_.firstObject;
    if (alertView) [alertView showInView:superview];
}

#pragma mark - Setter
- (void)setButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index {
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UIButton.class] && obj.tag == index) {
            UIButton *button = (UIButton *)obj;
            [button setTitleColor:buttonTitleColor forState:UIControlStateNormal];
        }
    }];
}

- (void)resizingImageToHeight:(CGFloat)height {
    CGSize size = [self imageSizeMultiplyToHeight:height];
    CGFloat interval = size.height - self.imageView.height_mn;
    [self.contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == self.imageView) {
            obj.size_mn = size;
            obj.centerX_mn = self.contentView.width_mn/2.f;
        } else if (obj.top_mn >= self.imageView.top_mn) {
            obj.top_mn += interval;
        }
    }];
    self.contentView.height_mn += interval;
    self.contentView.centerY_mn = self.height_mn/2.f;
}

+ (void)setAlertViewButtonTitleColor:(UIColor *)buttonTitleColor ofIndex:(NSInteger)index {
    MNAlertView *alertView = self.currentAlertView;
    if (alertView) [alertView setButtonTitleColor:buttonTitleColor ofIndex:index];
}

#pragma mark - Getter
- (UIColor *)buttonTitleColorWithTitle:(id)title {
    return [self isEnsureButtonTitle:title] ? [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f] : UIColor.darkTextColor;
}

- (BOOL)isEnsureButtonTitle:(id)title {
    if (!self.ensureButtonTitle) return NO;
    NSString *ensureButtonTitle = [self.ensureButtonTitle isKindOfClass:NSString.class] ? self.ensureButtonTitle : ((NSAttributedString *)(self.ensureButtonTitle)).string;
    return [title isKindOfClass:NSString.class] ? [(NSString *)title isEqualToString:ensureButtonTitle] : [((NSAttributedString *)title).string isEqualToString:ensureButtonTitle];
}

- (NSInteger)ensureButtonIndex {
    return self.ensureButtonTitle ? (self.buttonTitles.count - 1) : NSIntegerMin;
}

- (NSDictionary *)titleAttributes {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 0.f;
    paragraphStyle.paragraphSpacing = 0.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    return @{NSFontAttributeName:[UIFont systemFontOfSizes:16.f weights:.23f], NSForegroundColorAttributeName:UIColor.darkTextColor, NSParagraphStyleAttributeName:paragraphStyle};
}

- (NSDictionary *)messageAttributes {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 0.f;
    paragraphStyle.paragraphSpacing = 0.f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    if (self.titleLabel.text.length) {
        return @{NSFontAttributeName:[UIFont systemFontOfSize:14.f], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor.darkGrayColor colorWithAlphaComponent:.75f]};
    }
    return @{NSFontAttributeName:[UIFont systemFontOfSize:16.f], NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:UIColor.darkTextColor};
}

- (NSAttributedString *)attributedMessage {
    return [self.message isKindOfClass:NSAttributedString.class] ? self.message : [[NSAttributedString alloc] initWithString:(self.message ? : @"") attributes:self.messageAttributes];
}

- (NSString *)buttonTitleOfIndex:(NSUInteger)buttonIndex {
    if (buttonIndex >= self.buttonTitles.count) return nil;
    id buttonTitle = [self.buttonTitles objectAtIndex:buttonIndex];
    return [buttonTitle isKindOfClass:NSString.class] ? buttonTitle : ((NSAttributedString *)buttonTitle).string;
}

- (CGSize)imageSizeMultiplyToHeight:(CGFloat)height {
    if (!self.image) return CGSizeZero;
    CGSize size = self.image.size;
    size = CGSizeMultiplyToHeight(size, height);
    CGFloat max = self.contentView.width_mn - kAlertViewHorizontalMargin*2.f;
    if (size.width > max) {
        size = CGSizeMultiplyToWidth(size, max);
    }
    return size;
}

- (NSString *)messageText {
    if (!self.message) return nil;
    return ([self.message isKindOfClass:NSAttributedString.class]) ? ((NSAttributedString *)(self.message)).string : self.message;
}

+ (MNAlertView *)currentAlertView {
    NSArray <MNAlertView *>*alertViews = UIApplication.sharedApplication.keyWindow.alertViews_;
    if (alertViews.count <= 0) return nil;
    __block MNAlertView *alertView = nil;
    [alertViews enumerateObjectsUsingBlock:^(MNAlertView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.superview) {
            alertView = obj;
            *stop = YES;
        }
    }];
    return alertView;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end

