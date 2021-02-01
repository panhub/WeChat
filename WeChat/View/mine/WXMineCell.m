//
//  WXMineCell.m
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineCell.h"
#import "WXDataValueModel.h"

@implementation WXMineCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.imgView.frame = CGRectMake(15.f, 0.f, 24.f, 24.f);
        
        self.titleLabel.left_mn = self.imgView.right_mn + 15.f;
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                           image:image];
        [self.contentView addSubview:imageView];
        
        self.imgView.centerY_mn = imageView.centerY_mn = (self.contentView.height_mn)/2.f;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY_mn = self.imgView.centerY_mn;
    self.imgView.image = [UIImage imageNamed:model.img];
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
