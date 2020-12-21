//
//  SEMainView.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SEMainView.h"
#import "UIView+MNLayout.h"

NSString * const SEShareWebpageUrlKey = @"com.ext.share.webpage.url";
NSString * const SEShareWebpageTitleKey = @"com.ext.share.webpage.title";
NSString * const SEShareWebpageDateKey = @"com.ext.share.webpage.date";
NSString * const SEShareWebpageThumbnailKey = @"com.ext.share.webpage.thumbnail";

@interface SEMainView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *linkLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SEMainView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(18.f, 25.f, 115.f, 115.f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"ext_share_link"];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.left_mn = imageView.right_mn + 15.f;
        titleLabel.top_mn = imageView.top_mn;
        titleLabel.width_mn = self.width_mn - titleLabel.left_mn - 18.f;
        titleLabel.numberOfLines = 1;
        titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.9f];
        titleLabel.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *linkLabel = [[UILabel alloc] initWithFrame:titleLabel.frame];
        linkLabel.textColor = [[UIColor darkGrayColor] colorWithAlphaComponent:.7f];
        linkLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        linkLabel.numberOfLines = 3;
        [self addSubview:linkLabel];
        self.linkLabel = linkLabel;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .5f)];
        separator.top_mn = imageView.bottom_mn + imageView.top_mn;
        separator.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.23f];
        [self addSubview:separator];
        
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mn.chat.share"];
        BOOL isLogin = [userDefaults boolForKey:@"com.ext.share.login"];
        
        NSArray <NSDictionary *>*sessions = [userDefaults arrayForKey:@"com.ext.share.session"];
        BOOL isExistSessions = sessions.count > 0;
        
        CGFloat buttonHeight = 55.f;
        NSArray <NSString *>*titles = @[@"发送给朋友", @"分享到朋友圈", @"收藏"];
        NSArray <NSString *>*imgs = @[@"ext_share_friends", @"ext_share_moment", @"ext_share_favorites"];
        NSArray <NSNumber *>*enables = @[@(isExistSessions), @(isLogin), @(YES)];
        [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SEButton *button = [[SEButton alloc] initWithFrame:CGRectMake(13.f, separator.bottom_mn + buttonHeight*idx, self.width_mn - 26.f, buttonHeight)];
            button.type = idx;
            button.title = obj;
            button.image = [UIImage imageNamed:imgs[idx]];
            if (idx == 1) button.disablemage = [UIImage imageNamed:@"ext_share_moment_disable"];
            button.enabled = enables[idx].boolValue;
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }];
    }
    return self;
}

#pragma mark - Event
- (void)buttonClicked:(SEButton *)button {
    if ([self.delegate respondsToSelector:@selector(mainViewButtonClicked:)]) {
        [self.delegate mainViewButtonClicked:button];
    }
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    self.titleLabel.height_mn = [title sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
}

- (void)setUrl:(NSString *)url {
    CGSize size = [url boundingRectWithSize:CGSizeMake(self.linkLabel.width_mn, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.linkLabel.font} context:nil].size;
    size.height = MIN(size.height, self.linkLabel.font.pointSize*3.f + 15.f);
    self.linkLabel.height_mn = size.height;
    self.linkLabel.bottom_mn = self.imageView.bottom_mn;
    self.linkLabel.text = url;
}

#pragma mark - Getter
- (UIImage *)image {
    return self.imageView.image;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (NSString *)url {
    return self.linkLabel.text;
}

- (NSDictionary *)jsonValue {
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    return @{SEShareWebpageUrlKey:self.linkLabel.text,
                 SEShareWebpageTitleKey:self.titleLabel.text,
                 SEShareWebpageDateKey:[NSString stringWithFormat:@"%@", @(timestamp)],
                 SEShareWebpageThumbnailKey:UIImagePNGRepresentation(self.imageView.image)};
}

@end
