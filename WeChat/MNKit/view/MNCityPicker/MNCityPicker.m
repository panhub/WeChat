//
//  MNCityPicker.m
//  MNFoundation
//
//  Created by Vincent on 2020/1/20.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNCityPicker.h"

@interface MNCityPicker ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray <NSString *>*provinces;
@property (nonatomic, strong) NSArray <NSArray <NSString *>*>*citys;
@property (nonatomic, copy) void (^selectHandler) (MNCityPicker *picker);
@end

@implementation MNCityPicker
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    NSMutableArray <NSString *>*provinces = @[].mutableCopy;
    NSMutableArray <NSArray <NSString *>*>*citys = @[].mutableCopy;
    NSArray <NSDictionary *>*array = [[NSArray alloc] initWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:NSStringFromClass(self.class) ofType:@"plist"]];
    [array enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [provinces addObject:[obj objectForKey:@"province"]];
        [citys addObject:[obj objectForKey:@"citys"]];
    }];
    self.citys = citys.copy;
    self.provinces = provinces.copy;
}

- (void)createView {
    
    self.backgroundColor = UIColor.clearColor;
    
    UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
    contentView.top_mn = self.height_mn;
    contentView.backgroundColor = UIColor.whiteColor;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    UIButton *ensureButton = [UIButton buttonWithFrame:CGRectZero
                                                 image:nil
                                                 title:@"确定"
                                            titleColor:[UIColor colorWithRed:87.f/255.f green:106.f/255.f blue:149.f/255.f alpha:1.f]
                                             titleFont:[UIFont systemFontOfSize:17.f]];
    ensureButton.size_mn = CGSizeMake(50.f, 30.f);
    ensureButton.top_mn = 10.f;
    ensureButton.right_mn = contentView.width_mn - 10.f;
    [ensureButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:ensureButton];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(15.f, ensureButton.bottom_mn, contentView.width_mn - 30.f, 200.f)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.tintColor = [UIColor.grayColor colorWithAlphaComponent:.2f];
    [contentView addSubview:pickerView];
    self.pickerView = pickerView;
    
    contentView.height_mn = pickerView.bottom_mn + UITabSafeHeight() + 5.f;
}

#pragma mark - UIPickerViewDelegate && UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) return self.provinces.count;
    NSUInteger row = [pickerView selectedRowInComponent:0];
    if (row >= self.provinces.count) return 0;
    return self.citys[row].count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.width_mn/2.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 31.f;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    if (component == 0) {
        title = self.provinces[row];
    } else {
        NSUInteger index = [pickerView selectedRowInComponent:0];
        [pickerView selectRow:index inComponent:0 animated:NO];
        title = index >= self.provinces.count ? @"" : self.citys[index][row];
    }
    return [[NSAttributedString alloc]initWithString:title
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f],NSForegroundColorAttributeName:[UIColor darkTextColor]}];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) [pickerView reloadComponent:1];
}

#pragma mark - show & dismiss
- (void)showWithSelectHandler:(void (^)(MNCityPicker *picker))selectHandler {
    [self showInView:[[UIApplication sharedApplication] keyWindow] selectHandler:selectHandler];
}

- (void)showInView:(UIView *)view selectHandler:(void (^)(MNCityPicker *picker))selectHandler {
    if (!view || [view.subviews containsObject:self] || _contentView.top_mn < self.height_mn) return;
    self.selectHandler = selectHandler;
    [view addSubview:self];
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.35f];
        self.contentView.bottom_mn = self.height_mn;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = UIColor.clearColor;
        self.contentView.top_mn = self.height_mn;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.selectHandler) self.selectHandler(self);
    }];
}

#pragma mark - Getter
- (NSString *)city {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    NSArray <NSString *>*citys = self.citys[row];
    row = [self.pickerView selectedRowInComponent:1];
    return citys[row];
}

- (NSString *)province {
    NSInteger row = [self.pickerView selectedRowInComponent:0];
    return self.provinces[row];
}

#pragma mark - Overwrite
- (void)setFrame:(CGRect)frame {
    frame = UIScreen.mainScreen.bounds;
    [super setFrame:frame];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject.view == self && touches.anyObject.tapCount == 1) {
        self.selectHandler = nil;
        [self dismiss];
    }
}

@end
