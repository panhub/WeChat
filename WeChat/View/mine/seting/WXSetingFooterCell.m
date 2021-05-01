//
//  WXSetingFooterCell.m
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSetingFooterCell.h"
#import "WXDataValueModel.h"

@implementation WXSetingFooterCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.titleLabel.frame = self.contentView.bounds;
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.88f];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    if (model.userInfo && [model.userInfo isKindOfClass:UIColor.class]) self.titleLabel.textColor = model.userInfo;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
