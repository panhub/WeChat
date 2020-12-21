//
//  WXAddMomentCollectionView.h
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈添加图片

#import <UIKit/UIKit.h>
@class WXAddMomentCollectionView;

@protocol WXAddMomentCollectionViewDelegate <NSObject>

- (void)collectionViewDidChangeHeight:(WXAddMomentCollectionView *)collectionView;

@end

@interface WXAddMomentCollectionView : UIView

/**
 交互代理
 */
@property (nonatomic, weak) id<WXAddMomentCollectionViewDelegate> delegate;

/**
 行数
 */
@property (nonatomic, readonly) NSUInteger rows;

/**
 图片
 */
@property (nonatomic, strong) NSArray <UIImage *>*images;

@end
