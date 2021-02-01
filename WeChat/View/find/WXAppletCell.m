//
//  WXAppletCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAppletCell.h"
#import "WXDataValueModel.h"

@interface WXAppletCell ()

@end

@implementation WXAppletCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(10.f, MEAN(self.contentView.height_mn - 30.f), 30.f, 30.f);
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.right_mn = self.contentView.width_mn - 10.f;
        arrowView.centerY_mn = self.imgView.centerY_mn;
        [self.contentView addSubview:arrowView];
        
        self.titleLabel.font = UIFontRegular(16.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .95f);
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 8.f, MEAN(self.contentView.height_mn - 16.f), arrowView.left_mn - self.imgView.right_mn - 16.f, 16.f);
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.imgView.image = [UIImage imageNamed:model.img];
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
