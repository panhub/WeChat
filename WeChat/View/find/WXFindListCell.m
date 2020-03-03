//
//  WXFindListCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXFindListCell.h"
#import "WXDataValueModel.h"

@interface WXFindListCell ()
@property (nonatomic, strong) UILabel *badgeLabel;
@end

@implementation WXFindListCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(10.f, MEAN(self.contentView.height_mn - 30.f), 30.f, 30.f);
        
        self.titleLabel.font = UITabSafeHeight() > 0.f ? UIFontRegular(16.f) : UIFontRegular(17.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .85f);
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, MEAN(self.contentView.height_mn - 19.f), 120.f, UITabSafeHeight() > 0.f ? 18.f : 19.f);
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height)
                                                           image:image];
        imageView.left_mn = self.contentView.width_mn - size.width - 10.f;
        imageView.centerY_mn = self.imgView.centerY_mn;
        [self.contentView addSubview:imageView];
        
        UIFont *font = UITabSafeHeight() > 0.f ? UIFontRegular(12.f) : UIFontRegular(13.f);
        UILabel *badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, font.lineHeight, font.lineHeight)];
        badgeLabel.centerY_mn = self.imgView.centerY_mn;
        badgeLabel.userInteractionEnabled = NO;
        badgeLabel.backgroundColor = BADGE_COLOR;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.textColor = [UIColor whiteColor];
        badgeLabel.font = font;
        badgeLabel.layer.cornerRadius = badgeLabel.height_mn/2.f;
        badgeLabel.clipsToBounds = YES;
        badgeLabel.hidden = YES;
        [self.contentView addSubview:badgeLabel];
        self.badgeLabel = badgeLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.imgView.image = [UIImage imageNamed:model.img];
    self.titleLabel.width_mn = [NSString getStringSize:model.title font:self.titleLabel.font].width;
    self.titleLabel.text = model.title;
    NSString *badge = model.userInfo;
    if (badge.length && badge.integerValue > 0) {
        if (badge.length <= 1) {
            _badgeLabel.width_mn = _badgeLabel.height_mn;
        } else {
            CGFloat width = [NSString getStringSize:badge font:_badgeLabel.font].width + (UITabSafeHeight() > 0.f ? 13.f : 15.f);
            width = MAX(width, _badgeLabel.height_mn);
            _badgeLabel.width_mn = width;
        }
        _badgeLabel.text = badge;
        _badgeLabel.left_mn = self.titleLabel.right_mn + (UITabSafeHeight() > 0.f ? 14.f : 15.f);
        self.badgeLabel.hidden = NO;
    } else {
        self.badgeLabel.hidden = YES;
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
