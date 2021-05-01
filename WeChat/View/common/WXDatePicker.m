//
//  WXDatePicker.m
//  TeamAlbum
//
//  Created by Vicent on 2020/12/1.
//

#import "WXDatePicker.h"

@interface WXDatePicker ()
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, copy) WXDatePickerHandler pickHandler;
@end

@implementation WXDatePicker
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:UIScreen.bounds]) {
        self.backgroundColor = UIColor.clearColor;
        [self createView];
    }
    return self;
}

- (instancetype)initWithPickHandler:(WXDatePickerHandler)pickHandler {
    if (self = [self initWithFrame:CGRectZero]) {
        self.pickHandler = pickHandler;
    }
    return self;
}

- (void)createView {
    
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0.f, self.height_mn, self.width_mn, 0.f)];
    contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    [@[@"取消", @"确定"] enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(10.f, 10.f, 50.f, 30.f)
                                               image:nil
                                               title:title
                                          titleColor:THEME_COLOR
                                                titleFont:@(17.f)];
        button.tag = idx;
        if (idx == 1) button.right_mn = contentView.width_mn - button.left_mn;
        [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
    }];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.maximumDate = NSDate.date;
    datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:NSDate.date.timeIntervalSince1970 - 3600*24*365*3];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8*3600];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
#ifdef __IPHONE_13_4
    if (@available(iOS 13.4, *)) {
        datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
#endif
#ifdef __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        datePicker.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
#endif
    datePicker.frame = CGRectMake(0.f, 35.f, contentView.width_mn, 200.f);
    datePicker.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:datePicker];
    self.datePicker = datePicker;
    
    contentView.height_mn = datePicker.bottom_mn + MN_TAB_SAFE_HEIGHT;
}

- (void)show {
    [self showInView:UIApplication.sharedApplication.delegate.window];
}

- (void)showInView:(UIView *)superview {
    if (!superview) superview = UIApplication.sharedApplication.delegate.window;
    [superview endEditing:YES];
    [superview addSubview:self];
    self.center = CGPointMake(superview.bounds.size.width/2.f, superview.bounds.size.height/2.f);
    [UIView animateWithDuration:.33f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.4f];
        self.contentView.bottom_mn = self.height_mn;
    } completion:nil];
}

- (void)dismiss {
    [self dismiss:nil];
}

- (void)dismiss:(UIButton *)sender {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = UIColor.clearColor;
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (sender && sender.tag == 1) {
            if (self.pickHandler) self.pickHandler(self.date);
            if ([self.delegate respondsToSelector:@selector(datePickerEnsureButtonTouchUpInside:)]) {
                [self.delegate datePickerEnsureButtonTouchUpInside:self];
            }
        }
    }];
}

- (void)setDate:(NSDate *)date {
    self.datePicker.date = date;
}

- (NSDate *)date {
    return self.datePicker.date;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
