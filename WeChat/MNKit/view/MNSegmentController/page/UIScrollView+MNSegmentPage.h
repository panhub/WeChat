//
//  UIScrollView+MNPage.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (MNSegmentPage)

/**记录索引*/
@property(nonatomic) NSUInteger pageIndex;
/**是否允许改变偏移*/
@property(nonatomic) BOOL changeOffsetEnabled;
/**是否满足内容大小的条件*/
@property(nonatomic) BOOL contentSizeReached;
/**是否已被监听*/
@property(nonatomic) BOOL observed;

@end
