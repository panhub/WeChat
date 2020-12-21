//
//  MNDatePicker.m
//  MCT_Note
//
//  Created by Vincent on 2018/7/3.
//  Copyright © 2018年 Apple.lnc. All rights reserved.
//

#import "MNDatePicker.h"

static NSDateFormatter * NSDatePickerFormatter (void) {
    static NSDateFormatter *date_picker_formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        date_picker_formatter = [NSDateFormatter new];
        [date_picker_formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
        [date_picker_formatter setDateFormat:@"yyyy年MM月dd日/HH/mm"];
    });
    return date_picker_formatter;
}

@interface MNDatePicker ()<UIGestureRecognizerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSMutableArray <NSString *>*dateArray;
@property (nonatomic, strong) NSArray <NSString *>*hourArray;
@property (nonatomic, strong) NSArray <NSString *>*minuteArray;
@property (nonatomic, copy) MNDatePickerHandler handler;
@end

@implementation MNDatePicker

+ (instancetype)datePicker {
    MNDatePicker *datePicker = [[NSClassFromString(@"MNDatePicker") alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    return datePicker;
}

+ (instancetype)datePickerWithHandler:(MNDatePickerHandler)handler {
    MNDatePicker *datePicker = [MNDatePicker datePicker];
    datePicker.handler = handler;
    return datePicker;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    self.type = MNDatePickerTypeCancel;
    self.backgroundColor = [UIColor clearColor];
    NSString *current = [NSDatePickerFormatter() stringFromDate:[NSDate date]];
    NSArray <NSString *>*array = [current componentsSeparatedByString:@"/"];
    self.hour = [array[1] intValue];
    self.minute = [[array lastObject] intValue];
    NSInteger interval = 0;
    for (NSInteger idx = 0; idx < 365*5; idx ++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval];
        NSString *string = [NSDatePickerFormatter() stringFromDate:date];
        [self.dateArray addObject:[[string componentsSeparatedByString:@"/"] firstObject]];
        interval -= 86400;
    }
}

- (void)createView {
    UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0.f, self.height_mn, self.width_mn, 0.f)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    self.contentView = contentView;
    
    [@[@"取消", @"现在"] enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithFrame:CGRectMake(10.f, 10.f, 50.f, 30.f)
                                               image:nil
                                               title:title
                                          titleColor:TEXT_COLOR
                                                titleFont:@(17.f)];
        button.tag = idx;
        if (idx == 1) button.right_mn = contentView.width_mn - button.left_mn;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
    }];
    
    UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.f, 35.f, contentView.width_mn, 200.f)];
    picker.delegate = self;
    picker.dataSource = self;
    [contentView addSubview:picker];
    self.picker = picker;

    UIButton *confirmButton = [UIButton buttonWithFrame:CGRectMake(0.f, picker.bottom_mn - 15.f, contentView.width_mn, 50.f)
                                                  image:nil
                                                  title:@"确定"
                                             titleColor:TEXT_COLOR
                                                   titleFont:UIFontRegular(18.f)];
    confirmButton.tag = 2;
    [confirmButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:confirmButton];
    
    contentView.height_mn = confirmButton.bottom_mn;
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.dateArray.count;
    } else if (component == 1) {
        return self.hourArray.count;
    }
    return self.minuteArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return pickerView.width_mn/2.f + 50.f;
    }
    return (pickerView.width_mn/2.f - 50.f)/2.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 33.f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if (component == 0) {
        title = _dateArray[row];
    } else if (component == 1) {
        title = [_hourArray[row] stringByAppendingString:@"时"];
    } else {
        title = [_minuteArray[row] stringByAppendingString:@"分"];
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (row == 0) {
            if ([pickerView selectedRowInComponent:1] > _hour) {
                [self updateDateWithAnimated:YES];
            } else if ([pickerView selectedRowInComponent:1] == _hour && [pickerView selectedRowInComponent:2] > _minute) {
                [self updateDateWithAnimated:YES];
            }
        }
    } else if (component == 1) {
        if ([pickerView selectedRowInComponent:0] == 0) {
            if (row > _hour) {
                [self updateDateWithAnimated:YES];
            } else if (row == _hour && [pickerView selectedRowInComponent:2] > _minute) {
                [self updateDateWithAnimated:YES];
            }
        }
    } else {
        if ([pickerView selectedRowInComponent:0] == 0 && [pickerView selectedRowInComponent:1] == _hour) {
            if (row > _minute) {
                [self updateDateWithAnimated:YES];
            }
        }
    }
}

#pragma mark - 初始日期
- (void)updateDateWithAnimated:(BOOL)animated {
    [_picker selectRow:0 inComponent:0 animated:animated];
    [_picker selectRow:_hour inComponent:1 animated:animated];
    [_picker selectRow:_minute inComponent:2 animated:animated];
}

#pragma mark - 按钮响应
- (void)buttonClicked:(UIButton *)button {
    self.type = (MNDatePickerType)(button.tag);
    [self dismissWithAnimated:YES];
}

#pragma mark - show
- (void)show {
    [self showInView:[[UIApplication sharedApplication] keyWindow]];
}

- (void)showInView:(UIView *)view {
    if (!view || _contentView.top_mn < self.height_mn) return;
    [view addSubview:self];
    [self updateDateWithAnimated:NO];
    self.type = MNDatePickerTypeCancel;
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
        self.contentView.top_mn = self.height_mn - self.contentView.height_mn;
    } completion:nil];
}

#pragma mark - dismiss
- (void)dismiss {
    self.type = MNDatePickerTypeCancel;
    [self dismissWithAnimated:YES];
}

- (void)dismissWithAnimated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? .3f : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.type != MNDatePickerTypeCancel) {
            if (self.handler) {
                self.handler(self);
            }
            if ([self.delegate respondsToSelector:@selector(datePickerEnsureButtonClicked:)]) {
                [_delegate datePickerEnsureButtonClicked:self];
            }
        }
    }];
}

#pragma mark - Getter
- (NSDate *)date {
    NSString *date = _dateArray[[_picker selectedRowInComponent:0]];
    NSString *hour = _hourArray[[_picker selectedRowInComponent:1]];
    NSString *minute = _minuteArray[[_picker selectedRowInComponent:2]];
    NSString *string = [NSString stringWithFormat:@"%@/%@/%@",date,hour,minute];
    return [NSDatePickerFormatter() dateFromString:string];
}

- (NSString *)timestamp {
    return [NSString stringWithFormat:@"%@",@(self.date.timeIntervalSince1970)];
}

- (NSMutableArray <NSString *>*)dateArray {
    if (!_dateArray) {
        _dateArray = [NSMutableArray arrayWithCapacity:360];
    }
    return _dateArray;
}

- (NSArray <NSString *>*)hourArray {
    if (!_hourArray) {
        _hourArray = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",
                              @"08",@"09",@"10",@"11",@"12",@"13",@"14",
                              @"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"];
    }
    return _hourArray;
}

- (NSArray <NSString *>*)minuteArray {
    if (!_minuteArray) {
        _minuteArray = @[@"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",
                                 @"08",@"09",@"10",@"11",@"12",@"13",@"14",
                                 @"15",@"16",@"17",@"18",@"19",@"20",@"21",
                                 @"22",@"23",@"24",@"25",@"26",@"27",@"28",
                                 @"29",@"30",@"31",@"32",@"33",@"34",@"35",
                                 @"36",@"37",@"38",@"39",@"40",@"41",@"42",
                                 @"43",@"44",@"45",@"46",@"47",@"48",@"49",
                                 @"50",@"51",@"52",@"53",@"54",@"55",@"56",
                                 @"57",@"58",@"59"];
    }
    return _minuteArray;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)dealloc {
    MNDeallocLog;
}

@end
