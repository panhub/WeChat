//
//  MNLinkTableView.h
//  MNKit
//
//  Created by Vincent on 2018/12/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNLinkTableView, MNLinkTableConfiguration;

@protocol MNLinkTableViewDelegate <NSObject>
@required
- (void)linkTableView:(MNLinkTableView *)tableView didSelectRowAtIndex:(NSInteger)index;
@end

@interface MNLinkTableView : UIView
/**
 选择项高度
 */
@property (nonatomic) CGFloat rowHeight;
/**
 事件回调代理
 */
@property (nonatomic, weak) id<MNLinkTableViewDelegate> delegate;
/**
 配置信息
 */
@property (nonatomic, strong) MNLinkTableConfiguration *configuration;
/**
 当前选择索引
 */
@property (nonatomic, assign, readonly) NSInteger selectedIndex;
/**
 上一次选择索引
 */
@property (nonatomic, assign, readonly) NSInteger lastSelectedIndex;
/**
 获取页数
 */
@property (nonatomic, assign, readonly) NSInteger numberOfRows;
/**
 外界标记禁止交互
 */
@property (nonatomic, assign) BOOL interactiveEnabled;
/**
 外界控制是否允许选择<默认与重载YES>
 */
@property (nonatomic) BOOL selectEnabled;

/**
 更新标题
 @param titles 标题数组<NSString NSAttributedString>
 */
- (void)updateTitles:(NSArray <id>*)titles;

/**
 Page交互期间更新当前指示图
 @param ratio 偏移比率
 */
- (void)updateShadowOffsetOfRatio:(CGFloat)ratio;

/**
 Page交互结束滑动指示图到目标索引
 @param toIndex 目标索引
 */
- (void)scrollShadowToIndex:(NSInteger)toIndex;

/**
 更新当前索引
 @param currentIndex 当前索引
 @param animated 是否动态
 */
- (void)updateSelectIndex:(NSInteger)currentIndex animated:(BOOL)animated;

/**
 重载
 */
- (void)reloadData;

@end

