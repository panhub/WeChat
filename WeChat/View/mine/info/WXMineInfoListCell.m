//
//  WXMineInfoListCell.m
//  MNChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineInfoListCell.h"
#import "WXDataValueModel.h"

@interface WXMineInfoListCell ()
@property (nonatomic, weak) UIImageView *arrowView;
@end

@implementation WXMineInfoListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn) - 11.f, 100.f, 20.f);
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.imgView.frame = CGRectMake(arrowView.left_mn - 22.f, 0.f, 22.f, 22.f);
        self.imgView.image = UIImageNamed(@"wx_mine_qrcode");
        self.imgView.centerY_mn = MEAN(self.contentView.height_mn);
        
        self.detailLabel.frame = self.titleLabel.frame;
        self.detailLabel.left_mn = self.titleLabel.right_mn + 15.f;
        self.detailLabel.width_mn = arrowView.centerX_mn - self.detailLabel.left_mn;
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .55f);
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.detailLabel.text = model.desc;
    self.titleLabel.text = model.title;
    self.imgView.hidden = model.img.length <= 0;
    if (self.type == WXMineInfoTypeDefault) {
        self.arrowView.hidden = model.desc.length > 0;
        self.detailLabel.hidden = !self.arrowView.hidden;
    } else {
        [self.titleLabel sizeToFit];
        self.detailLabel.left_mn = self.titleLabel.right_mn + 15.f;
        self.detailLabel.width_mn = self.arrowView.left_mn - self.detailLabel.left_mn;
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
