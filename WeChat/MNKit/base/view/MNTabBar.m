//
//  MNTabBar.m
//  MNKit
//
//  Created by Vincent on 2018/12/15.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTabBar.h"
#import "MNTabBarItem.h"
#import "UIViewController+MNInterface.h"
#import "MNMacro.h"

static CGRect MNTabBarFrame (void) {
    CGRect frame;
    if (IS_IPAD) {
        frame = CGRectMake(0.f, 0.f, TAB_BAR_HEIGHT, SCREEN_HEIGHT);
    } else {
        frame = CGRectMake(0.f, SCREEN_MAX - TAB_BAR_HEIGHT, SCREEN_MIN, TAB_BAR_HEIGHT);
    }
    return frame;
}

@interface MNTabBar ()
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UIVisualEffectView *blurEffect;
@property (nonatomic, strong) NSMutableArray <MNTabBarItem *>*itemArray;
@end

@implementation MNTabBar
+ (instancetype)tabBar {
    return [[MNTabBar alloc] initWithFrame:MNTabBarFrame()];
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
    _itemSize = IS_IPAD ? CGSizeMake(50, 45.f) : CGSizeMake(50.f, 35.f);
    _itemArray = [NSMutableArray arrayWithCapacity:0];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)createView {
    self.backgroundColor = [UIColor clearColor];
    UIVisualEffectView *blurEffect = UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight);
    [self addSubview:blurEffect];
    self.blurEffect = blurEffect;
    
    CGRect frame = IS_IPAD ? CGRectMake(self.width_mn - MN_SEPARATOR_HEIGHT, 0.f, MN_SEPARATOR_HEIGHT, self.height_mn) : CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT);
    UIViewAutoresizing autoresizingMask = IS_IPAD ? UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    UIImageView *shadowView = [[UIImageView alloc]initWithFrame:frame];
    shadowView.autoresizingMask = autoresizingMask;
    shadowView.clipsToBounds = YES;
    shadowView.contentMode = UIViewContentModeScaleAspectFill;
    shadowView.image = [UIImage imageWithColor:UIColorWithAlpha([UIColor darkTextColor], .25f)];
    [self addSubview:shadowView];
    self.shadowView = shadowView;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    [self.itemArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.itemArray removeAllObjects];
    _viewControllers = viewControllers;
    if (viewControllers.count <= 0) return;
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull controller, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *viewController = [controller isKindOfClass:[UINavigationController class]] ? [((UINavigationController *)controller).viewControllers firstObject] : controller;
        MNTabBarItem *item = [[MNTabBarItem alloc] init];
        item.tag = idx;
        item.selected = (idx == self.selectedIndex);
        item.title = viewController.tabBarItem.title;
        item.selectedTitle = viewController.tabBarItem.title;
        item.image = viewController.tabBarItem.image;
        item.selectedImage = viewController.tabBarItem.selectedImage;
        [item addTarget:self action:@selector(tabBarItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemArray addObject:item];
        [self addSubview:item];
    }];
    [self layoutTabItemIfNeeded];
}

#pragma mark - 点击索引
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex == _selectedIndex || selectedIndex >= self.itemArray.count) return;
    _selectedIndex = selectedIndex;
    [self.itemArray enumerateObjectsUsingBlock:^(MNTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.selected = (idx == selectedIndex);
    }];
}

- (void)layoutTabItemIfNeeded {
    if (self.itemArray.count <= 0) return;
    CGFloat interval = IS_IPAD ? (self.height_mn - self.itemSize.height*self.itemArray.count) : (self.width_mn - self.itemSize.width*self.itemArray.count);
    interval = interval/(self.itemArray.count + 1);
    CGFloat margin = IS_IPAD ? (self.width_mn - UIStatusBarHeight() - self.itemSize.width)/2.f : (self.height_mn - UITabSafeHeight() - self.itemSize.height)/2.f;
    [self.itemArray enumerateObjectsUsingBlock:^(MNTabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = IS_IPAD ? CGRectMake(UIStatusBarHeight() + margin, interval + (self.itemSize.height + interval)*idx, self.itemSize.width, self.itemSize.height) : CGRectMake(interval + (self.itemSize.width + interval)*idx, margin, self.itemSize.width, self.itemSize.height);
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
    if (index >= _itemArray.count) return;
    MNTabBarItem *tabBarItem = _itemArray[index];
    tabBarItem.badgeValue = badgeValue;
}

- (NSString *)badgeValueOfIndex:(NSUInteger)index {
    if (index >= _itemArray.count) return nil;
    MNTabBarItem *tabBarItem = _itemArray[index];
    return tabBarItem.badgeValue;
}

#pragma mark - Overwrite
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}

@end
