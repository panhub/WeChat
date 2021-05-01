//
//  WXShakeHistoryCell.h
//  WeChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXShakeHistory;

@interface WXShakeHistoryCell : MNTableViewCell

/**数据模型*/
@property (nonatomic, strong) WXShakeHistory *history;

@end
