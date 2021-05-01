//
//  WXMineInfoHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/4/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineInfoHeaderView.h"

@implementation WXMineInfoHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame {
    if (self = [super initWithReuseIdentifier:reuseIdentifier frame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 0.f, 17.f);
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.text = @"头像";
        [self.titleLabel sizeToFit];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
        
        self.imgView.frame = CGRectMake(arrowView.left_mn - (self.contentView.height_mn - 18.f), 9.f, self.contentView.height_mn - 18.f, self.contentView.height_mn - 18.f);
        self.imgView.layer.cornerRadius = 5.f;
        self.imgView.clipsToBounds = YES;
        
        [self updateUserInfo];
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)updateUserInfo {
    
    self.imgView.image = [WXUser.shareInfo avatar];
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
