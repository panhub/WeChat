//
//  MNLinkTableViewCell.h
//  MNChat
//
//  Created by Vincent on 2019/6/25.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNLinkTableViewCell : UITableViewCell

@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSTextAlignment titleAlignment;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

@end
