//
//  WXNewsViewModel.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXNewsDataModel, WXExtendViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsViewModel : NSObject

/**高度*/
@property (nonatomic) CGFloat rowHeight;

/**数据模型*/
@property (nonatomic, strong) WXNewsDataModel *dataModel;

/**标题视图描述*/
@property (nonatomic, strong) WXExtendViewModel *titleViewModel;

/**作者视图描述*/
@property (nonatomic, strong) WXExtendViewModel *authorViewModel;

/**日期视图描述*/
@property (nonatomic, strong) WXExtendViewModel *dateViewModel;

/**缩略图视图描述*/
@property (nonatomic, copy) NSArray <WXExtendViewModel *>*imageViewModels;

/**
 依据数据模型实例化新闻视图模型
 */
- (instancetype)initWithDataModel:(WXNewsDataModel *)dataModel;

@end

NS_ASSUME_NONNULL_END
