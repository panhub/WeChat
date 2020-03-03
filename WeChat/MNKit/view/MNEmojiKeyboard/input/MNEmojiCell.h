//
//  MNEmojiCell.h
//  MNChat
//
//  Created by Vincent on 2020/2/16.
//  Copyright © 2020 Vincent. All rights reserved.
//  表情展示Cell

#import <UIKit/UIKit.h>
@class MNEmoji;

@interface MNEmojiCell : UICollectionViewCell

/**表情*/
@property (nonatomic, strong) MNEmoji *emoji;

@end
