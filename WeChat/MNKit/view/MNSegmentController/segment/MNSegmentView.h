//
//  MNSegmentView.h
//  MNKit
//
//  Created by Vincent on 2018/4/14.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNSegmentViewProtocol.h"
#import "MNSegmentConfiguration.h"

@interface MNSegmentView : UIView
/**配置信息模型*/
@property (nonatomic, strong) MNSegmentConfiguration *configuration;
/**是否允许改变索引*/
@property (nonatomic, assign) BOOL updateSelectedIndexEnabled;
/**交互代理*/
@property (nonatomic, weak) id<MNSegmentViewDelegate> delegate;
/**数据源代理*/
@property (nonatomic, weak) id<MNSegmentViewDataSource> dataSource;
/**外界控制是否允许选择<默认与重载YES>*/
@property (nonatomic) BOOL selectEnabled;
/**获取标题数量, 即子页面数量*/
@property (nonatomic) NSUInteger numberOfItems;

/**
 重载右视图
 */
- (void)reloadRightView;

/**
 重载标题
 */
- (void)reloadTitles;

/**滚动到指定索引*/
- (void)selectItemAtIndex:(NSUInteger)pageIndex;

/**更新当前索引*/
- (void)updateSelectIndex:(NSInteger)currentIndex;

/**更新当前标记位置*/
- (void)updateShadowOffsetOfRatio:(CGFloat)ratio;

/**
 Page交互结束滑动指示图到目标索引
 @param index 目标索引
 */
- (void)scrollShadowToIndex:(NSUInteger)index;

/**清空缓存*/
- (void)cleanCache;

/**重载*/
- (void)reloadData;

@end
