//
//  MNLinkPageView.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNLinkPageView : UIScrollView

/**计算当前展示的页码*/
@property (nonatomic, readonly) NSInteger currentPageIndex;

/**
 更新内容视图大小
 @param numberOfPages 总页数
 */
- (void)updateContentSizeWithNumberOfPages:(NSInteger)numberOfPages;

/**
 计算Page对应的偏移
 @param pageIndex 页数
 @return 偏移
 */
- (CGFloat)offsetYOfIndex:(NSInteger)pageIndex;

/**
 更新偏移到指定索引
 @param pageIndex 页数索引
 */
- (void)updateOffsetWithIndex:(NSInteger)pageIndex;

@end
