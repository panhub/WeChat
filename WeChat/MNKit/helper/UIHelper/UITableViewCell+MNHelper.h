//
//  UITableViewCell+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (MNHelper)

/**
 寻找自身所在的TableView
 */
@property (nonatomic, weak, readonly) UITableView *tableView;

/**
 自身在表中的索引
 */
@property (nonatomic, strong, readonly) NSIndexPath *index_path;

@end


