//
//  WXChangeInfoCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeInfoCell.h"
#import "WXDataValueModel.h"

@interface WXChangeInfoCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation WXChangeInfoCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel.frame = CGRectMake(25.f, MEAN(self.contentView.height_mn - 14.f), 75.f, 14.f);
        self.titleLabel.font = UIFontRegular(self.titleLabel.height_mn);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn, self.titleLabel.top_mn, self.contentView.width_mn - self.titleLabel.right_mn - self.titleLabel.left_mn, self.titleLabel.height_mn);
        self.detailLabel.font = [UIFont systemFontOfSize:self.detailLabel.height_mn];
        self.detailLabel.textAlignment = NSTextAlignmentLeft;
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .78f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.detailLabel.text = model.desc;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
