//
//  WXMineListCell.m
//  MNChat
//
//  Created by Vincent on 2019/4/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMineListCell.h"
#import "WXDataValueModel.h"

@implementation WXMineListCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.imgView.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 24.f), 24.f, 24.f);
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 15.f, MEAN(self.contentView.height_mn - 17.f), 100.f, 17.f);
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                           image:image];
        imageView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:imageView];
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
