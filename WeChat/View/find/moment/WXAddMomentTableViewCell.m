//
//  WXAddMomentTableViewCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentTableViewCell.h"
#import "WXDataValueModel.h"

@interface WXAddMomentTableViewCell ()
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UIImageView *arrowView;
@end

#define WXAddMomentTableViewCellTextColor   UIColorWithAlpha([UIColor darkTextColor], .85f)

@implementation WXAddMomentTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(5.f, 15.f, self.contentView.height_mn - 30.f, self.contentView.height_mn - 30.f);
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 15.f, MEAN(self.contentView.height_mn - 17.f), 70.f, 17.f);
        self.titleLabel.font = UIFontRegular(17.f);
        self.titleLabel.textColor = WXAddMomentTableViewCellTextColor;
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - 15.f, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn + 10.f, self.titleLabel.top_mn, arrowView.left_mn - self.titleLabel.right_mn - 10.f, self.titleLabel.height_mn);
        self.detailLabel.font = UIFontRegular(17.f);
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        
        UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(arrowView.left_mn - (self.contentView.height_mn - 20.f), 10.f, self.contentView.height_mn - 20.f, self.contentView.height_mn - 20.f) image:nil];
        [self.contentView addSubview:headView];
        self.headView = headView;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.imgView.image = [UIImage imageNamed:model.img];
    if (kTransform(NSNumber *, model.userInfo).integerValue == WXAddMomentTableViewCellTypeNormal) {
        self.headView.hidden = YES;
        self.detailLabel.hidden = NO;
        self.titleLabel.width_mn = 70.f;
        self.titleLabel.textColor = WXAddMomentTableViewCellTextColor;
        self.titleLabel.text = model.title;
        self.detailLabel.text = model.desc;
    } else if (kTransform(NSNumber *, model.userInfo).integerValue == WXAddMomentTableViewCellTypeLocation) {
        self.headView.hidden = YES;
        self.detailLabel.hidden = YES;
        self.titleLabel.width_mn = self.arrowView.left_mn - self.titleLabel.left_mn;
        if (model.desc.length > 0) {
            self.titleLabel.textColor = MN_R_G_B(26.f, 173.f, 25.f);
            self.titleLabel.text = model.desc;
        } else {
            self.titleLabel.textColor = WXAddMomentTableViewCellTextColor;
            self.titleLabel.text = model.title;
        }
    } else {
        self.headView.hidden = NO;
        self.detailLabel.hidden = YES;
        self.titleLabel.width_mn = 70.f;
        self.titleLabel.textColor = WXAddMomentTableViewCellTextColor;
        self.titleLabel.text = model.title;
        self.headView.image = model.value;
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
