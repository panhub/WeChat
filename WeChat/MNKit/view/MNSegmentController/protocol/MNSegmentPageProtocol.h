//
//  MNSegmentPageProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//  分段控制器页面协议

#import <Foundation/Foundation.h>
#import "MNSegmentSubpageProtocol.h"
@class MNSegmentPageController;

@protocol MNSegmentPageDataSource <NSObject>
@required
/**总页数*/
@property (nonatomic, readonly) NSInteger numberOfPages;
/**应为page顶部添加的空位高度*/
@property (nonatomic, readonly) CGFloat pageInsetOfInitialized;
/**此时应为page配置的偏移*/
@property (nonatomic, readonly) CGFloat pageOffsetYAtCurrent;
/**头视图最大偏移 依次计算符合滑动的尺寸*/
@property (nonatomic, readonly) CGFloat pageHeaderMaxOffsetY;
/**==page==*/
- (UIViewController <MNSegmentSubpageDataSource>*)pageOfIndex:(NSUInteger)pageIndex;
@end

@protocol MNSegmentPageDelegate <NSObject>
@optional
/**切换page*/
- (void)pageController:(MNSegmentPageController*)pageController
                    willLeavePage:(UIViewController <MNSegmentSubpageDataSource>*)fromPage
                toPage:(UIViewController <MNSegmentSubpageDataSource>*)toPage;

- (void)pageController:(MNSegmentPageController*)pageController
                    didLeavePage:(UIViewController <MNSegmentSubpageDataSource>*)fromPage
                toPage:(UIViewController <MNSegmentSubpageDataSource>*)toPage;

/**Page横向滑动回调*/
- (void)pageDidScrollWithOffsetRatio:(CGFloat)ratio dragging:(BOOL)dragging;

/**Page垂直滑动回调*/
- (void)pageDidScrollWithOffsetY:(CGFloat)offsetY ofIndex:(NSInteger)pageIndex;

@end
