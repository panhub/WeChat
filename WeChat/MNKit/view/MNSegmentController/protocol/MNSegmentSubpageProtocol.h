//
//  MNSegmentSubpageProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//  分段控制器子页面协议

#import <Foundation/Foundation.h>

@protocol MNSegmentSubpageDataSource <NSObject>
@required
- (UIScrollView *)segmentSubpageScrollView;
@optional
- (void)segmentSubpageScrollViewDidInsertInset:(CGFloat)inset ofIndex:(NSInteger)pageIndex;
@end

