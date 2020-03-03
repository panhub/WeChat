//
//  MNTableViewHeaderFooterView.h
//  MNKit
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  区头区尾视图

#import <UIKit/UIKit.h>

@interface MNTableViewHeaderFooterView : UITableViewHeaderFooterView

/**
 预留标题信息控件
 */
@property (nonatomic, readonly, strong) UILabel *titleLabel;
/**
 预留描述信息控件
 */
@property (nonatomic, readonly, strong) UILabel *detailLabel;
/**
 预留图片控件
 */
@property (nonatomic, readonly, strong) UIImageView *imageView;

@end

