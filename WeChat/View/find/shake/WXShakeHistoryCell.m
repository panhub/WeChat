//
//  WXShakeHistoryCell.m
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeHistoryCell.h"
#import "WXShakeHistory.h"

@interface WXShakeHistoryCell ()
 /**签名*/
@property (nonatomic, strong) UIView *signatureView;
@property (nonatomic, strong) UILabel *signatureLabel;
/**性别*/
@property (nonatomic, strong) UIImageView *genderView;
@end

@implementation WXShakeHistoryCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(10.f, 9.f, self.contentView.height_mn - 18.f, self.contentView.height_mn - 18.f);
        UIViewSetCornerRadius(self.imgView, 5.f);
        
        self.titleLabel.left_mn = self.imgView.right_mn + 10.f;
        self.titleLabel.font = UIFontMedium(16.f);
        self.titleLabel.textColor = UIColor.blackColor;
        self.titleLabel.numberOfLines = 1;
        
        self.detailLabel.left_mn = self.titleLabel.left_mn;
        self.detailLabel.textColor = [UIColor.darkGrayColor colorWithAlphaComponent:.65f];
        self.detailLabel.numberOfLines = 1;
        
        UIImageView *genderView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        genderView.size_mn = CGSizeMake(self.titleLabel.font.pointSize, self.titleLabel.font.pointSize);
        [self.contentView addSubview:genderView];
        self.genderView = genderView;
        
        UIView *signatureView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 24.f)];
        signatureView.hidden = YES;
        signatureView.right_mn = self.contentView.width_mn - self.imgView.left_mn;
        signatureView.centerY_mn = self.contentView.height_mn/2.f;
        signatureView.backgroundColor = VIEW_COLOR;
        UIViewSetCornerRadius(signatureView, 4.f);
        [self.contentView addSubview:signatureView];
        self.signatureView = signatureView;
        
        UILabel *signatureLabel = [UILabel labelWithFrame:UIEdgeInsetsInsetRect(signatureView.bounds, UIEdgeInsetsMake(0.f, 5.f, 0.f, 5.f)) text:nil textAlignment:NSTextAlignmentCenter textColor:self.detailLabel.textColor font:UIFontRegular(12.f)];
        signatureLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [signatureView addSubview:signatureLabel];
        self.signatureLabel = signatureLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.imgView.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setHistory:(WXShakeHistory *)history {
    _history = history;
    self.imgView.image = history.thumbnailImage;
    self.titleLabel.text = history.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = MIN(self.titleLabel.width_mn, self.signatureView.right_mn - self.titleLabel.left_mn);
    if (history.subtitle.length) {
        self.titleLabel.top_mn = self.imgView.top_mn;
        self.detailLabel.font = history.type == WXShakeHistoryPerson ? UIFontRegular(12.f) : UIFontRegular(self.titleLabel.font.pointSize - 1.f);
        self.detailLabel.text = history.subtitle;
        [self.detailLabel sizeToFit];
        self.detailLabel.width_mn = MIN(self.detailLabel.width_mn, self.signatureView.right_mn - self.detailLabel.left_mn);
        self.detailLabel.bottom_mn = self.imgView.bottom_mn;
        self.detailLabel.hidden = NO;
    } else {
        self.detailLabel.hidden = YES;
        self.titleLabel.centerY_mn = self.imgView.centerY_mn;
    }
    if (history.gender == MNGenderUnknown) {
        self.genderView.hidden = YES;
    } else {
        self.genderView.left_mn = self.titleLabel.right_mn + 5.f;
        self.genderView.centerY_mn = self.titleLabel.centerY_mn;
        self.genderView.image = [UIImage imageNamed:(history.gender == MNGenderMale ? @"wx_contacts_gender_male" : @"wx_contacts_gender_female")];
        self.genderView.hidden = NO;
    }
    if (history.signature.length) {
        CGFloat width = MIN([NSString getStringSize:history.signature font:self.signatureLabel.font].width, 90.f);
        self.signatureView.width_mn = width + 10.f;
        self.signatureLabel.text = history.signature;
        self.signatureView.right_mn = self.contentView.width_mn - self.imgView.left_mn;
        self.signatureView.hidden = NO;
    } else {
        self.signatureView.hidden = YES;
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
