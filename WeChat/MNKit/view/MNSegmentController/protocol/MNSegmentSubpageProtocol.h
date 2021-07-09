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
/**获取滑动控件以监听偏移*/
- (UIScrollView *)segmentSubpageScrollView;
@optional
/**猜想最小内容尺寸告知*/
- (void)segmentSubpageGuessMinContentSize:(CGSize)minContentSize;
/**向滑动控件嵌入偏移告知*/
- (void)segmentSubpageScrollViewDidInsertInset:(CGFloat)inset ofIndex:(NSInteger)pageIndex;
@end

