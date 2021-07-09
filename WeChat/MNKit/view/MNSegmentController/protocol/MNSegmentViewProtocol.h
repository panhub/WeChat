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
/**选择了分段索引*/
- (void)segmentView:(MNSegmentView *)segment didSelectItemAtIndex:(NSUInteger)index;
@end

@protocol MNSegmentViewDataSource <NSObject>
@required
/**获取分段标题*/
- (NSArray <NSString *>*)segmentViewShouldLoadTitles;
@optional
/**获取右常驻视图*/
- (UIView *)segmentViewShouldLoadRightView;
@end


