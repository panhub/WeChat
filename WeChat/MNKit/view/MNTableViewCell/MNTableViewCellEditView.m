//
//  MNTableViewCellEditView.m
//  MNKit
//
//  Created by Vincent on 2019/4/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCellEditView.h"
#import "MNTableViewCellEditAction.h"

@interface MNTableViewCellEditContentView : UIView
@property (nonatomic, weak) UIButton *button;
@end
@implementation MNTableViewCellEditContentView @end

@interface MNTableViewCellEditView ()
@property (nonatomic) CGFloat totalWidth;
@property (nonatomic, strong) NSArray<UIView *> *contentViews;
@property (nonatomic, strong) NSMutableArray<NSNumber *>*contentWidths;
@property (nonatomic, strong) NSArray<MNTableViewCellEditAction *> *actions;
@property (nonatomic, strong) NSMutableDictionary <NSNumber *, MNTableViewCellEditContentView *>*cache;
@end

@implementation MNTableViewCellEditView
- (void)updateContentViews:(NSArray<MNTableViewCellEditAction *> *)actions {
    [self removeContentViews];
    _actions = actions.copy;
    [actions enumerateObjectsUsingBlock:^(MNTableViewCellEditAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = obj.width;
        [obj setValue:@(idx) forKey:@"index"];
        MNTableViewCellEditContentView *view = [self viewOfIndex:idx];
        if (obj.image) {
            view.button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            view.button.imageEdgeInsets = obj.inset;
            [view.button setImage:obj.image forState:UIControlStateNormal];
        } else if (obj.title.length > 0) {
            if (obj.titleFont) view.button.titleLabel.font = obj.titleFont;
            if (obj.titleColor) [view.button setTitleColor:obj.titleColor forState:UIControlStateNormal];
            [view.button setTitle:obj.title forState:UIControlStateNormal];
            width = [obj.title boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : view.button.titleLabel.font} context:nil].size.width;
            width += (obj.inset.left + obj.inset.right);
            view.button.titleEdgeInsets = obj.inset;
        }
        if (obj.backgroundColor) view.button.backgroundColor = obj.backgroundColor;
        view.backgroundColor = view.button.backgroundColor;
        view.frame = CGRectMake(_totalWidth, 0.f, width, self.height_mn);
        view.button.frame = view.bounds;
        /// 需要对初始的宽度进行保存, 在形变等操作后恢复
        [self.contentWidths addObject:@(view.width_mn)];
        /// 需要对总宽度进行保存
        _totalWidth += view.width_mn;
        [self addSubview:view];
    }];
    self.width_mn = _totalWidth;
    self.contentViews = self.subviews.copy;
}

- (void)removeContentViews {
    if (self.subviews.count <= 0) return;
    _actions = nil;
    _contentViews = nil;
    _totalWidth = self.width_mn = 0.f;
    [_contentWidths removeAllObjects];
    [self removeAllSubviews];
}

- (void)buttonClicked:(UIButton *)button {
    if (button.tag >= self.actions.count) return;
    MNTableViewCellEditAction *action = self.actions[button.tag];
    if ([_delegate respondsToSelector:@selector(tableViewCellEditView:didClickAction:)]) {
        [_delegate tableViewCellEditView:self didClickAction:action];
    }
}

- (void)resetting {
    CGFloat x = 0.f;
    for (NSInteger idx = 0; idx < self.contentViews.count; idx++) {
        UIView *view = self.contentViews[idx];
        CGRect frame = view.frame;
        frame.origin.x = x;
        frame.size.width = [self.contentWidths[idx] floatValue];
        view.frame = frame;
        x += view.width_mn;
    }
}

- (void)layoutContentIfNeeded {
    if (self.width_mn == _totalWidth) return;
    NSArray <NSNumber *>*contentWidths = self.contentWidths.copy;
    [self.contentWidths removeAllObjects];
    __block CGFloat totalWidth = 0.f;
    [self.contentViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:MNTableViewCellEditContentView.class]) {
            CGFloat width = [contentWidths[idx] floatValue]/_totalWidth*self.width_mn;
            MNTableViewCellEditContentView *view = (MNTableViewCellEditContentView *)obj;
            view.left_mn = totalWidth;
            view.width_mn = width;
            view.button.width_mn = width;
            totalWidth += width;
            [self.contentWidths addObject:@(width)];
        }
    }];
    _totalWidth = totalWidth;
}


- (void)autoresizing:(CGFloat)width {
    CGFloat needExpandWidth = width - _totalWidth;
    CGFloat x = 0.f;
    for (int i = 0; i < _contentViews.count; i++) {
        UIView *sub = _contentViews[i];
        sub.left_mn = x;
        CGRect sframe = sub.frame;
        sframe.origin.x = x;
        CGFloat sneedExpandWidth = ([_contentWidths[i] floatValue]/_totalWidth*needExpandWidth);
        sframe.size.width = [_contentWidths[i] floatValue] + sneedExpandWidth;
        sub.frame = sframe;
        x += sframe.size.width;
    }
}

#pragma mark - Getter
- (NSMutableArray<NSNumber *> *)contentWidths {
    if (!_contentWidths) {
        _contentWidths = [NSMutableArray new];
    }
    return _contentWidths;
}

- (NSMutableDictionary <NSNumber *, MNTableViewCellEditContentView *>*)cache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _cache;
}

- (MNTableViewCellEditContentView *)viewOfIndex:(NSInteger)index {
    MNTableViewCellEditContentView *view = self.cache[@(index)];
    if (!view) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.adjustsImageWhenHighlighted = NO;
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        view = [MNTableViewCellEditContentView new];
        view.tag = index;
        view.clipsToBounds = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [view addSubview:button];
        view.button = button;
        [self.cache setObject:view forKey:@(index)];
    }
    view.hidden = NO;
    return view;
}

@end
