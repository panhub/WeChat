//
//  WXAccountListCell.m
//  WeChat
//
//  Created by Vincent on 2019/8/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAccountListCell.h"
#import "WXDataValueModel.h"

@interface WXAccountListCell ()
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation WXAccountListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 85.f, 17.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.88f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - self.titleLabel.left_mn, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn + 10.f, self.titleLabel.top_mn, arrowView.left_mn - self.titleLabel.right_mn - 10.f, self.titleLabel.height_mn);
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];
        self.detailLabel.textColor = [[UIColor darkGrayColor] colorWithAlphaComponent:.7f];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.detailLabel.text = model.desc;
    if ([model.value boolValue]) {
        self.arrowView.hidden = NO;
        self.detailLabel.right_mn = self.arrowView.left_mn;
    } else {
        self.arrowView.hidden = YES;
        self.detailLabel.right_mn = self.arrowView.right_mn - 5.f;
    }
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
