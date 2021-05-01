//
//  WXAboutListCell.m
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAboutListCell.h"
#import "WXDataValueModel.h"

@implementation WXAboutListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(0.f, MEAN(self.contentView.height_mn - 17.f), 100.f, 17.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.88f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 5.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
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
