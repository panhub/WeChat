//
//  MNLinkTableViewCell.h
//  MNKit
//
//  Created by Vincent on 2019/6/25.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNLinkTableViewCell : UITableViewCell

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, copy) id title;
@property (nonatomic, assign) NSTextAlignment titleAlignment;
@property (nonatomic, assign) UIEdgeInsets titleInset;
@property (nonatomic, assign) NSInteger titleNumberOfLines;

@end
