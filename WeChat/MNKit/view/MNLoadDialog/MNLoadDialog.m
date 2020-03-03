//
//  MNLoadDialog.m
//  MNKit
//
//  Created by Vincent on 2018/7/20.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNLoadDialog.h"

const CGFloat MNLoadDialogMargin = 19.f;
const CGFloat MNLoadDialogFontSize = 15.f;
const CGFloat MNLoadDialogMaxWidth = 200.f;
const CGFloat MNLoadDialogTextMargin = 8.f;
NSString *const MNLoadDialogAnimationKey = @"com.mn.dialog.animation.key";

static MNLoadDialogStyle _LoadDialogDefaultStyle;

static MNLoadDialogContentStyle _LoadDialogContentStyle;

void MNLoadDialogSetContentStyle (MNLoadDialogContentStyle type) {
    _LoadDialogContentStyle = type;
}

MNLoadDialogContentStyle MNLoadDialogGetContentStyle (void) {
    return _LoadDialogContentStyle;
}

void MNLoadDialogSetDefaultStyle (MNLoadDialogStyle style) {
    _LoadDialogDefaultStyle = style;
}

MNLoadDialogStyle MNLoadDialogGetDefaultStyle (void) {
    return _LoadDialogDefaultStyle;
}

UIColor *MNLoadDialogContentColor (void) {
    return _LoadDialogContentStyle ? UIColor.darkTextColor : [UIColor colorWithRed:250.f/255.f green:250.f/255.f blue:250.f/255.f alpha:.93f];
}

@interface UIView (MNLoadDialogShadow)

- (void)addLoadDialogBlurEffect;
- (void)addLoadDialogMotionEffect;

@end

@implementation UIView (MNLoadDialogShadow)

- (void)addLoadDialogBlurEffect {
    self.backgroundColor = _LoadDialogContentStyle ? [UIColor colorWithWhite:0.f alpha:.12f] : UIColor.clearColor;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:(_LoadDialogContentStyle ? UIBlurEffectStyleLight : UIBlurEffectStyleDark)];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self insertSubview:effectView atIndex:0];
}

- (void)addLoadDialogMotionEffect {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectX.maximumRelativeValue = @(10.f);
    effectX.minimumRelativeValue = @(-10.f);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    effectY.maximumRelativeValue = @(10.f);
    effectY.minimumRelativeValue = @(-10.f);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[effectX, effectY];
    
    [self addMotionEffect:group];
}

@end

@interface MNLoadDialog ()
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSDictionary *attributes;
@end

static NSArray <NSString *>*MNLoadDialogPool;

@implementation MNLoadDialog
+ (void)load {
    MNLoadDialogSetDefaultStyle(MNLoadDialogStyleMask);
    MNLoadDialogPool = @[@"MNInfoDialog",
                                    @"MNActivityDialog",
                                    @"MNShapeDialog",
                                    @"MNRotatedDialog",
                                    @"MNBallDialog",
                                    @"MNDotDialog",
                                    @"MNErrorDialog",
                                    @"MNCompleteDialog",
                                    @"MNProgressDialog",
                                    @"MNMaskDialog",
                                    @"MNPayDialog",
                                    @"MNWeChatDialog"];
}

+ (instancetype)loadDialogWithStyle:(MNLoadDialogStyle)style {
    return [self loadDialogWithStyle:style message:nil];
}

+ (instancetype)loadDialogWithStyle:(MNLoadDialogStyle)style message:(NSString *)message {
    if (style >= MNLoadDialogPool.count) return nil;
    return [[NSClassFromString([MNLoadDialogPool objectAtIndex:style]) alloc] initWithMessage:message];
}

- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super init]) {
        _message = message ? message.copy : @"";
        [self initialized];
        [self createView];
    }
    return self;
}

#pragma mark - 布局子视图
- (void)layoutSubviewIfNeeded {
    // layout textLabel
    self.containerView.top_mn = MNLoadDialogMargin;
    NSAttributedString *attributedString = self.attributedString;
    if ([self.textLabel.text isEqualToString:attributedString.string]) return;
    CGSize size = [attributedString sizeOfLimitWidth:MNLoadDialogMaxWidth - MNLoadDialogMargin*2.f];
    if (size.width <= 0.f) size.height = 0.f;
    CGFloat margin = size.width <= 0.f ? 0.f : MNLoadDialogTextMargin;
    size.width = MAX(size.width, self.containerView.width_mn);
    self.textLabel.size_mn = size;
    self.textLabel.top_mn = self.containerView.bottom_mn + margin;
    self.textLabel.attributedText = attributedString;
    // layout contentView
    CGFloat width = size.width + MNLoadDialogMargin*2.f;
    CGFloat height = self.textLabel.bottom_mn + MNLoadDialogMargin;
    if (size.height < MNLoadDialogFontSize*2.f) width = MIN(MAX(width, height), MNLoadDialogMaxWidth);
    self.contentView.size_mn = CGSizeMake(width, height);
    self.containerView.centerX_mn = self.textLabel.centerX_mn = self.contentView.width_mn/2.f;
    if (self.superview && self.interactionEnabled) {
        self.size_mn = self.contentView.size_mn;
        self.center_mn = self.superview.bounds_center;
    }
    if (!CGRectIsEmpty(self.bounds)) self.contentView.center_mn = self.bounds_center;
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [UIView new];
        contentView.layer.cornerRadius = 6.f;
        contentView.userInteractionEnabled = NO;
        contentView.clipsToBounds = YES;
        _contentView = contentView;
    }
    return _contentView;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [UIView new];
        containerView.userInteractionEnabled = NO;
        _containerView = containerView;
    }
    return _containerView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        UILabel *textLabel = [UILabel new];
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = MNLoadDialogContentColor();
        _textLabel = textLabel;
    }
    return _textLabel;
}

- (NSString *)message {
    return _message.length <= 0 ? @"" : _message;
}

- (NSAttributedString *)attributedString {
    return [[NSAttributedString alloc] initWithString:self.message attributes:[self attributes]];
}

- (NSDictionary *)attributes {
    if (!_attributes) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineSpacing = 0.f;
        paragraphStyle.paragraphSpacing = 1.f;
        paragraphStyle.lineHeightMultiple = 1.f;
        paragraphStyle.paragraphSpacingBefore = 1.f;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        _attributes = @{NSFontAttributeName:UIFontSystem(MNLoadDialogFontSize), NSForegroundColorAttributeName:MNLoadDialogContentColor(), NSParagraphStyleAttributeName:paragraphStyle};
    }
    return _attributes;
}

- (MNLoadDialogStyle)style {
    return [MNLoadDialogPool indexOfObject:NSStringFromClass(self.class)];
}

#pragma mark - Show
- (BOOL)show {
    return [self showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (BOOL)showInView:(UIView *)superview {
    if (!superview || !CGRectContainsRect(superview.bounds, _contentView.bounds)) return NO;
    self.frame = superview.bounds;
    [superview addSubview:self];
    if ([self interactionEnabled]) {
        self.size_mn = _contentView.size_mn;
        self.center_mn = superview.bounds_center;
    }
    if ([self blurEffectEnabled]) [_contentView addLoadDialogBlurEffect];
    if ([self motionEffectEnabled]) [_contentView addLoadDialogMotionEffect];
    _contentView.center_mn = self.bounds_center;
    [self addSubview:_contentView];
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self startAnimation];
    return YES;
}

#pragma mark - 子类实现
- (void)initialized {}
- (void)createView {}
- (BOOL)updateMessage:(NSString *)message {
    if (!self.superview) return NO;
    self.message = message;
    [self layoutSubviewIfNeeded];
    return YES;
}
- (BOOL)updateProgress:(float)progress {
    return NO;
}
- (BOOL)interactionEnabled {
    return NO;
}
- (BOOL)blurEffectEnabled {
    return YES;
}
- (BOOL)motionEffectEnabled {
    return NO;
}
- (void)startAnimation {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
- (void)dismiss {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didEnterBackgroundNotification {}
- (void)willEnterForegroundNotification {}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
@end
