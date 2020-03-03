//
//  WXAlbumListCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册cell

#import "MNTableViewCell.h"
@class WXAlbumViewModel;

@interface WXAlbumListCell : MNTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) WXAlbumViewModel *viewModel;

@end
