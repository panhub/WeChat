//
//  MNSegmentPageView.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSegmentPageView : UIScrollView

/**根据总页数更新内容尺寸*/
- (void)updateContentSizeWithNumberOfPages:(NSInteger)numberOfPages;

/**根据索引计算偏移, 必须保证内容尺寸足够*/
- (CGFloat)offsetXOfIndex:(NSUInteger)pageIndex;

/**根据索引更新偏移*/
- (void)updateOffsetWithIndex:(NSUInteger)pageIndex;

/**根据当前偏移计算page索引*/
- (NSUInteger)currentPageIndex;

@end
