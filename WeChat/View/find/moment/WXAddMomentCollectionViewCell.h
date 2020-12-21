//
//  WXAddMomentCollectionViewCell.h
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNCollectionViewCell.h"
#import "WXAddMomentCollectionModel.h"
@class WXAddMomentCollectionViewCell;

UIKIT_EXTERN NSString * const WXMomentCollectionCellShakeAnimationKey;
UIKIT_EXTERN NSString * const WXMomentCollectionCellShakeNotificationName;
UIKIT_EXTERN NSString * const WXMomentCollectionCellCancelShakeNotificationName;

@protocol WXAddMomentCellDelegate <NSObject>
- (void)collectionViewCellDeleteButtonDidClick:(WXAddMomentCollectionViewCell *)cell;
@end

@interface WXAddMomentCollectionViewCell : MNCollectionViewCell

@property (nonatomic, weak) WXAddMomentCollectionModel *model;

@property (nonatomic, weak) id<WXAddMomentCellDelegate> delegate;

@end

