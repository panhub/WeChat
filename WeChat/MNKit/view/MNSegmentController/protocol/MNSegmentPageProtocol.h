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
- (NSUInteger)numberOfPages;
/**==page==*/
- (UIViewController <MNSegmentSubpageDataSource>*)pageOfIndex:(NSUInteger)pageIndex;
/**应为page顶部添加的空位高度*/
- (CGFloat)pageInsetOfInitialized;
/**此时应为page配置的偏移*/
- (CGFloat)pageOffsetYAtCurrent;
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
- (void)pageDidScrollWithOffsetY:(CGFloat)offsetY ofIndex:(NSUInteger)pageIndex;

@end
