//
//  WXContactsPageCell.h
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  PageControlCell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXContactsPageCell : UIView

@property (nonatomic) NSUInteger index;
@property (nonatomic, weak) UILabel *textLabel;
@property (nonatomic, weak) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
