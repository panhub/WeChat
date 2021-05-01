//
//  WXPhotoTitleView.m
//  WeChat
//
//  Created by Vicent on 2021/4/22.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoTitleView.h"
#import "WXMoment.h"

@interface WXPhotoTitleView ()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation WXPhotoTitleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        UILabel *dateLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:MN_RGB(206.f) font:[UIFont systemFontOfSizes:17.f weights:MNFontWeightMedium]];
        dateLabel.numberOfLines = 1;
        dateLabel.userInteractionEnabled = NO;
        [self addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        UILabel *numberLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:MN_RGB(206.f) font:[UIFont systemFontOfSizes:11.f weights:MNFontWeightMedium]];
        numberLabel.hidden = YES;
        numberLabel.numberOfLines = 1;
        numberLabel.userInteractionEnabled = NO;
        [self addSubview:numberLabel];
        self.numberLabel = numberLabel;
    }
    return self;
}

- (void)setProfile:(WXProfile *)profile {
    if (profile == _profile) return;
    _profile = profile;
    NSArray <WXMoment *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName where:@{sql_field(profile.identifier):sql_pair(profile.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) {
        self.numberLabel.hidden = self.dateLabel.hidden = YES;
        return;
    }
    
    WXMoment *moment = rows.lastObject;
    
    self.dateLabel.text = [NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy年M月d日 HH:mm"];
    [self.dateLabel sizeToFit];
    self.dateLabel.hidden = NO;

    __block NSInteger index = -1;
    if (moment.profiles.count > 1) {
        [moment.profiles enumerateObjectsUsingBlock:^(WXProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToProfile:profile]) {
                index = idx;
                *stop = YES;
            }
        }];
    }
    
    if (index >= 0) {
        self.numberLabel.hidden = NO;
        self.numberLabel.text = [NSString stringWithFormat:@"%@/%@", @(index + 1).stringValue, @(moment.profiles.count).stringValue];
        [self.numberLabel sizeToFit];
        self.numberLabel.centerX_mn = self.dateLabel.centerX_mn = self.width_mn/2.f;
        self.dateLabel.top_mn = (self.height_mn - self.dateLabel.height_mn - self.numberLabel.height_mn)/2.f;
        self.numberLabel.top_mn = self.dateLabel.bottom_mn;
    } else {
        self.numberLabel.hidden = YES;
        self.dateLabel.center_mn = self.bounds_center;
    }
}

@end
