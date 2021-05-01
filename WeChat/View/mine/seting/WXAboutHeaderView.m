//
//  WXAboutHeaderView.m
//  WeChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAboutHeaderView.h"

@implementation WXAboutHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.width_mn - 60.f), 40.f, 60.f, 60.f) image:[UIImage logoImage]];
        UIViewSetCornerRadius(imageView, 13.f);
        [self addSubview:imageView];
        
        UILabel *nameLable = [UILabel labelWithFrame:CGRectMake(0.f, imageView.bottom_mn + 35.f, self.width_mn, 22.f) text:[NSBundle displayName] alignment:NSTextAlignmentCenter textColor:[UIColor darkTextColor] font:[UIFont systemFontOfSizes:22.f weights:.3f]];
        [self addSubview:nameLable];
        
        UILabel *versionLabel = [UILabel labelWithFrame:CGRectMake(0.f, nameLable.bottom_mn + 15.f, self.width_mn, 17.f) text:NSStringWithFormat(@"Version %@", [NSBundle bundleVersion]) alignment:NSTextAlignmentCenter textColor:[UIColor darkTextColor] font:[UIFont systemFontOfSize:17.f]];
        [self addSubview:versionLabel];
        
        self.height_mn = versionLabel.bottom_mn + 35.f;
    }
    return self;
}
@end
