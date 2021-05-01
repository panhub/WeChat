//
//  MNSegmentControllerProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//  分段控制器协议

#import <Foundation/Foundation.h>
@class MNSegmentController;
@class MNSegmentConfiguration;

@protocol MNSegmentControllerDataSource <NSObject>
@required
- (NSArray <NSString *>*)segmentControllerShouldLoadPageTitles:(MNSegmentController *)segmentController;
- (UIViewController *)segmentController:(MNSegmentController *)segmentController childControllerOfPageIndex:(NSUInteger)pageIndex;
@optional
/**初始页数*/
- (NSUInteger)segmentControllerPageIndexOfInitialized;
/**公共头部视图*/
- (UIView *)segmentControllerShouldLoadHeaderView:(MNSegmentController *)segmentController;
/**分段列表右视图*/
- (UIView *)segmentControllerShouldLoadRightView:(MNSegmentController *)segmentController;
/**分段列表配置*/
- (void)segmentControllerInitializedConfiguration:(MNSegmentConfiguration *)configuration;
@end

@protocol MNSegmentControllerDelegate <NSObject>
@optional
/**回调外界界面切换事件<不一定成对调用>*/
- (void)segmentController:(MNSegmentController*)segmentController
     willLeavePageOfIndex:(NSUInteger)fromPageIndex
            toPageOfIndex:(NSUInteger)toPageIndex;

- (void)segmentController:(MNSegmentController*)segmentController
      didLeavePageOfIndex:(NSUInteger)fromPageIndex
            toPageOfIndex:(NSUInteger)toPageIndex;

/**SegmentHeader滑动回调<没有则不回调> scrollViewDidScroll*/
- (void)segmentControllerPageDidScroll:(MNSegmentController *)segmentController;

/**回调外界重载事件*/
- (void)segmentControllerWillReload:(MNSegmentController *)segmentController;
- (void)segmentControllerDidReload:(MNSegmentController *)segmentController;
@end
