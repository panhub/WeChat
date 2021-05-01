//
//  WXMineInfoListCell.h
//  WeChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTableViewCell.h"
@class WXDataValueModel;

typedef NS_ENUM(NSInteger, WXMineInfoType) {
    WXMineInfoTypeDefault = 0,
    WXMineInfoTypeMore
};

@interface WXMineInfoListCell : WXTableViewCell

@property (nonatomic) WXMineInfoType type;

/**数据模型*/
@property (nonatomic, weak) WXDataValueModel *model;

@end

