//
//  MNSegmentViewProtocol.h
//  KPoint
//
//  Created by Vincent on 2019/8/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  分段选择视图协议

#import <Foundation/Foundation.h>
@class MNSegmentView;

@protocol MNSegmentViewDelegate <NSObject>
@required
- (void)segmentView:(MNSegmentView *)segment didSelectItemAtIndex:(NSUInteger)index;
@end

@protocol MNSegmentViewDataSource <NSObject>
@required
- (NSArray <NSString *>*)segmentViewShouldLoadTitles;
@optional
- (UIView *)segmentViewShouldLoadRightView;
@end


