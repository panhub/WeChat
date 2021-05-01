//
//  WXUserNormalCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXUserNormalCell.h"
#import "WXDataValueModel.h"

@implementation WXUserNormalCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.left_mn = WXUserCellTitleMargin;
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = UIColor.darkTextColor;
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
    
        self.detailLabel.left_mn = WXUserCellSubtitleMargin;
        self.detailLabel.numberOfLines = 1.f;
        self.detailLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.6f];
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];
        
        self.imgView.image = [UIImage imageNamed:@"wx_common_list_arrow"];
        self.imgView.height_mn = 25.f;
        [self.imgView sizeFitToHeight];
        self.imgView.right_mn = self.contentView.width_mn - 10.f;
        self.imgView.centerY_mn = self.contentView.height_mn/2.f;
    }
    return self;
}

- (void)setModel:(WXUserInfo *)model {
    [super setModel:model];
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.detailLabel.text = model.subtitle;
    [self.detailLabel sizeToFit];
    self.titleLabel.centerY_mn = self.detailLabel.centerY_mn = self.contentView.height_mn/2.f;
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
