//
//  WXBankCardBindCell.m
//  WeChat
//
//  Created by Vincent on 2019/6/4.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXBankCardBindCell.h"
#import "WXDataValueModel.h"

@interface WXBankCardBindCell ()
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXBankCardBindCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 16.f), 100.f, 16.f);
        self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.height_mn];
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .9f);
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 12.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = self.titleLabel.centerY_mn;
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn + 10.f, self.titleLabel.top_mn, arrowView.left_mn - self.titleLabel.right_mn - 10.f, self.titleLabel.height_mn);
        self.detailLabel.font = [UIFont systemFontOfSize:self.detailLabel.height_mn];
        self.detailLabel.textColor = UIColorWithAlpha([UIColor grayColor], .6f);
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        
        self.imgView.frame = CGRectMake(arrowView.centerX_mn - (self.contentView.height_mn - 24.f), 12.f, self.contentView.height_mn - 24.f, self.contentView.height_mn - 24.f);
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.detailLabel.text = model.desc;
    self.imgView.image = [UIImage imageNamed:model.img];
    self.arrowView.hidden = [model.value boolValue];
    self.detailLabel.right_mn = self.arrowView.hidden ? self.arrowView.centerX_mn : self.arrowView.left_mn;
    self.detailLabel.hidden = model.img.length > 0;
    self.imgView.hidden = !self.detailLabel.hidden;
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
