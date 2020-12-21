//
//  WXAddMomentTableViewCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈底部cell

#import "MNTableViewCell.h"
@class WXDataValueModel;

typedef NS_ENUM(NSInteger, WXAddMomentTableViewCellType) {
    WXAddMomentTableViewCellTypeNormal = 0, /// 文字
    WXAddMomentTableViewCellTypeLocation,   /// 位置
    WXAddMomentTableViewCellTypeImage   /// 图片
};

@interface WXAddMomentTableViewCell : MNTableViewCell

@property (nonatomic, strong) WXDataValueModel *model;

@end
