//
//  MNCollectionReusableView.h
//  MNKit
//
//  Created by Vincent on 2019/5/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNCollectionReusableView : UICollectionReusableView
/**
 预留标题信息控件
 */
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/**
 预留描述信息控件
 */
@property (nonatomic, strong, readonly) UILabel *detailLabel;
/**
 预留图片控件
 */
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

