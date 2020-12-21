//
//  MNTabBar.m
//  MNKit
//
//  Created by Vincent on 2018/12/15.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTabBar.h"
#import "MNTabBarItem.h"
#import "UIView+MNHelper.h"
#import "UIViewController+MNInterface.h"

@interface MNTabBar ()
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIVisualEffectView *blurEffect;
@property (nonatomic, strong) NSMutableArray <MNTabBarItem *>*items;
@end

@implementation MNTabBar
+ (instancetype)tabBar {
    return [[MNTabBar alloc] initWithFrame:CGRectMake(0.f, MN_SCREEN_HEIGHT - MN_TAB_BAR_HEIGHT, MN_SCREEN_WIDTH, MN_TAB_BAR_HEIGHT)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialized];
        [self createView];
    }
    return self;
}

- (void)initialized {
    _selectedIndex = 0;
    _itemOffset = UIOffsetZero;
    _items = @[].mutableCopy;
    _itemSize = CGSizeMake(50.f, 35.f);
    _itemTouchInset = UIEdgeInsetsZero;
    self.backgroundColor = UIColor.whiteColor;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
}

- (void)createView {
    
    UIVisualEffectView *blurEffect = UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight);
    blurEffect.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:blurEffect];
    self.blurEffect = blurEffect;
    
    UIImageView *shadowView = [[UIImageView alloc]initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT)];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    shadowView.clipsToBounds = YES;
    shadowView.contentMode = UIViewContentModeScaleAspectFill;
    shadowView.image = [UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .15f)];
    [self addSubview:shadowView];
    self.shadowView = shadowView;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.items removeAllObjects];
    _viewControllers = viewControllers;
    if (viewControllers.count <= 0) return;
    UIEdgeInsets touchInset = self.itemTouchInset;
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *viewController = [controller isKindOfClass:[UINavigationController class]] ? [((UINavigationController *)controller).viewControllers firstObject] : controller;
        MNTabBarItem *item = [[MNTabBarItem alloc] init];
        item.tag = idx;
        item.selected = (idx == self.selectedIndex);
        item.title = viewController.tabBarItem.title;
        item.selectedTitle = viewController.tabBarItem.title;
        item.image = viewController.tabBarItem.image;
        item.selectedImage = viewController.tabBarItem.selectedImage;
        item.touchInset = touchInset;
        [item addTarget:self action:@selector(tabBarItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.items addObject:item];
        [self addSubview:item];
    }];
    [self layoutTabItemIfNeeded];
}

#pragma mark - 点击索引
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex == _selectedIndex || selectedIndex >= self.items.count) return;
    _selectedIndex = selectedIndex;
    [self.items enumerateObjectsUsingBlock:^(MNTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.selected = (idx == selectedIndex);
    }];
}

- (void)layoutTabItemIfNeeded {
    if (self.items.count <= 0) return;
    CGFloat interval = self.width_mn - self.itemSize.width*self.items.count;
    interval = interval/(self.items.count + 1);
    CGFloat margin = (self.height_mn - MN_TAB_SAFE_HEIGHT - self.itemSize.height)/2.f;
    [self.items enumerateObjectsUsingBlock:^(MNTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = CGRectMake(interval + (self.itemSize.width + interval)*idx, margin, self.itemSize.width, self.itemSize.height);
        frame.origin.x += self.itemOffset.horizontal;
        frame.origin.y += self.itemOffset.vertical;
        item.frame = frame;
    }];
}

#pragma mark - Setter
- (void)setTranslucent:(BOOL)translucent {
    [_blurEffect setHidden:!translucent];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (!shadowColor) return;
    _shadowView.image = [UIImage imageWithColor:shadowColor];
}

- (void)setItemSize:(CGSize)itemSize {
    if (CGSizeEqualToSize(itemSize, _itemSize)) return;
    _itemSize = itemSize;
    [self layoutTabItemIfNeeded];
}

- (void)setItemOffset:(UIOffset)itemOffset {
    if (UIOffsetEqualToOffset(itemOffset, _itemOffset)) return;
    _itemOffset = itemOffset;
    [self layoutTabItemIfNeeded];
}

- (void)setItemTouchInset:(UIEdgeInsets)itemTouchInset {
    _itemTouchInset = itemTouchInset;
    if (self.items.count) [self.items setValue:[NSValue valueWithUIEdgeInsets:itemTouchInset] forKey:@"touchInset"];
}

#pragma mark - Getter
- (BOOL)isTranslucent {
    return !_blurEffect.hidden;
}

#pragma mark - 按钮点击
- (void)tabBarItemSelected:(MNTabBarItem *)item {
    if (item.tag == _selectedIndex) {
        if ([_delegate respondsToSelector:@selector(tabBar:didRepeatSelectItemOfIndex:)]) {
            [_delegate tabBar:self didRepeatSelectItemOfIndex:item.tag];
        }
    } else {
        if (![self shouldSelectItemOfIndex:item.tag]) return;
        if ([_delegate respondsToSelector:@selector(tabBar:didSelectItemOfIndex:)]) {
            [_delegate tabBar:self didSelectItemOfIndex:item.tag];
        }
    }
}

- (BOOL)shouldSelectItemOfIndex:(NSUInteger)selectIndex {
    if ([_delegate respondsToSelector:@selector(tabBar:shouldSelectItemOfIndex:)]) {
        return [_delegate tabBar:self shouldSelectItemOfIndex:selectIndex];
    }
    return YES;
}

#pragma mark - 角标
- (void)setBadgeValue:(NSString *)badgeValue ofIndex:(NSUInteger)index {
    if (index >= _items.count) return;
    MNTabBarItem *tabBarItem = _items[index];
    tabBarItem.badgeValue = badgeValue;
}

- (NSString *)badgeValueOfIndex:(NSUInteger)index {
    if (index >= _items.count) return nil;
    MNTabBarItem *tabBarItem = _items[index];
    return tabBarItem.badgeValue;
}

#pragma mark - 拒绝交互
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
