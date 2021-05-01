//
//  MNCollectionViewCell.h
//  MNKit
//
//  Created by Vincent on 2017/7/21.
//  Copyright © 2017年 小斯. All rights reserved.
//  瀑布流Cell基类

#import <UIKit/UIKit.h>
#import "MNCollectionReusableView.h"

@interface MNCollectionViewCell : UICollectionViewCell
/**
 预留标题信息控件
 */
@property(nonatomic,strong,readonly) UILabel *titleLabel;
/**
 预留描述信息控件
 */
@property(nonatomic,strong,readonly) UILabel *detailLabel;
/**
 预留图片控件
 */
@property(nonatomic,strong,readonly) UIImageView *imageView;

- (void)didBeginDisplaying;

- (void)didEndDisplaying;

@end
