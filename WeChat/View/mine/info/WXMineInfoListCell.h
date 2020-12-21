//
//  WXMineInfoListCell.h
//  MNChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXDataValueModel;

typedef NS_ENUM(NSInteger, WXMineInfoType) {
    WXMineInfoTypeDefault = 0,
    WXMineInfoTypeMore
};

@interface WXMineInfoListCell : MNTableViewCell

@property (nonatomic, weak) WXDataValueModel *model;

@property (nonatomic) WXMineInfoType type;

@end

