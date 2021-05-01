//
//  WXAlbumCell.h
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册cell

#import "MNTableViewCell.h"
@class WXMonthViewModel;

@interface WXAlbumCell : MNTableViewCell

/**视图模型*/
@property (nonatomic, strong) WXMonthViewModel *viewModel;

@end
