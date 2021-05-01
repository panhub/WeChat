//
//  WXUserPhotoCell.m
//  WeChat
//
//  Created by Vicent on 2021/4/29.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXUserPhotoCell.h"
#import "WXMomentPicture.h"
#import "WXProfile.h"

@interface WXUserPhotoCell ()
@property (nonatomic, strong) NSMutableArray <WXMomentPicture *>*pictures;
@end

@implementation WXUserPhotoCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.left_mn = WXUserCellTitleMargin;
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = UIColor.darkTextColor;
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        self.imgView.image = [UIImage imageNamed:@"wx_common_list_arrow"];
        self.imgView.height_mn = 25.f;
        [self.imgView sizeFitToHeight];
        self.imgView.right_mn = self.contentView.width_mn - 10.f;
        self.imgView.centerY_mn = self.contentView.height_mn/2.f;
        
        //CGFloat m = 7.f;
        //CGFloat wh = (self.imgView.left_mn - 5.f - WXUserCellSubtitleMargin)/
        
        self.pictures = @[].mutableCopy;
        [UIView gridLayoutWithInitial:CGRectMake(WXUserCellSubtitleMargin, 0.f, WXUserCellPhotoWH, WXUserCellPhotoWH) offset:UIOffsetMake(6.f, 0.f) count:WXUserCellPhotoMaxCount rows:WXUserCellPhotoMaxCount handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            WXMomentPicture *p = [[WXMomentPicture alloc] initWithFrame:rect];
            p.hidden = YES;
            p.centerY_mn = self.contentView.height_mn/2.f;
            p.badgeView.size_mn = CGSizeMake(15.f, 15.f);
            p.badgeView.image = [UIImage imageNamed:@"album_list_play"];
            [self.contentView addSubview:p];
            [self.pictures addObject:p];
        }];
    }
    return self;
}

- (void)setModel:(WXUserInfo *)model {
    [super setModel:model];
    
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
    
    [self.pictures setValue:@(YES) forKey:@"hidden"];
    [model.photos enumerateObjectsUsingBlock:^(WXProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXMomentPicture *picture = self.pictures[idx];
        picture.picture = obj;
        picture.hidden = NO;
    }];
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
