//
//  WXPhotoContentView.m
//  WeChat
//
//  Created by Vicent on 2021/4/23.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXPhotoContentView.h"
#import "WXMoment.h"

@interface WXPhotoContentView ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation WXPhotoContentView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.width = MN_SCREEN_MIN;
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.45f];
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:UIColor.whiteColor font:[UIFont systemFontOfSizes:13.f weights:MNFontWeightMedium]];
        textLabel.top_mn = 5.f;
        textLabel.left_mn = 12.f;
        textLabel.numberOfLines = 0;
        textLabel.userInteractionEnabled = NO;
        textLabel.backgroundColor = UIColor.clearColor;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}

- (void)setProfile:(WXProfile *)profile {
    
    if (profile == _profile) return;
    _profile = profile;
    
    NSArray <WXMoment *>*rows = [MNDatabase.database selectRowsModelFromTable:WXMomentTableName where:@{sql_field(profile.identifier):sql_pair(profile.moment)}.sqlQueryValue limit:NSRangeZero class:WXMoment.class];
    if (rows.count <= 0) {
        self.hidden = YES;
        return;
    }
    
    WXMoment *moment = rows.lastObject;
    //moment.content ? : @""
    //NSString *s = @"啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊";
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moment.content ? : @""];
    [string matchingEmojiWithFont:self.textLabel.font];
    [string addAttribute:NSFontAttributeName value:self.textLabel.font range:string.rangeOfAll];
    [string addAttribute:NSForegroundColorAttributeName value:self.textLabel.textColor range:string.rangeOfAll];
    
    CGFloat bottom = self.bottom_mn;
    
    CGSize textSize = [string sizeOfLimitWidth:self.width_mn - self.textLabel.left_mn*2.f];
    textSize.height = MIN(textSize.height, 110.f);
    self.textLabel.size_mn = textSize;
    self.textLabel.attributedText = string.copy;
    self.height_mn = self.textLabel.bottom_mn + (MN_TAB_SAFE_HEIGHT > 0.f ? 15.f : self.textLabel.top_mn);
    
    self.bottom_mn = bottom;
    self.hidden = moment.content.length <= 0;
}

@end
