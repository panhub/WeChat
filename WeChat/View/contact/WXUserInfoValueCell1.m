//
//  WXUserInfoValueCell1.m
//  MNChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserInfoValueCell1.h"
#import "WXDataValueModel.h"

@implementation WXUserInfoValueCell1

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 0.f, 17.f);
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        self.detailLabel.frame = CGRectMake(103.f, self.titleLabel.top_mn, 0.f, self.titleLabel.height_mn);
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .6f);
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        self.imgView.frame = CGRectMake(self.contentView.width_mn - size.width - 10.f, MEAN(self.contentView.height_mn - size.height), size.width, size.height);
        self.imgView.image = image;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    [super setModel:model];
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.detailLabel.text = model.value;
    [self.detailLabel sizeToFit];
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
