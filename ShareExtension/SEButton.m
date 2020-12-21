//
//  SEButton.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SEButton.h"
#import "UIView+MNLayout.h"
#import "SEInline.h"

@interface SEButton ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SEButton
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.whiteColor;
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.size_mn = CGSizeMake(25.f, 25.f);
        imageView.centerY_mn = self.height_mn/2.f;
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ext_share_arrow"]];
        arrowView.size_mn = CGSizeMultiplyToHeight(arrowView.image.size, 13.f);
        arrowView.centerY_mn = self.height_mn/2.f;
        arrowView.right_mn = self.width_mn;
        arrowView.userInteractionEnabled = NO;
        [self addSubview:arrowView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:17.f];
        titleLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.9f];
        titleLabel.height_mn = titleLabel.font.pointSize;
        titleLabel.left_mn = imageView.right_mn + 15.f;
        titleLabel.width_mn = arrowView.left_mn - titleLabel.left_mn;
        titleLabel.centerY_mn = self.height_mn/2.f;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, .5f)];
        separator.bottom_mn = self.height_mn;
        separator.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.25f];
        [self addSubview:separator];
    }
    return self;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setDisablemage:(UIImage *)disablemage {
    self.imageView.highlightedImage = disablemage;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (self.enabled) {
        if (self.imageView.highlightedImage) {
            self.imageView.highlighted = NO;
        } else {
            self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            self.imageView.tintColor = nil;
        }
    } else {
        if (self.imageView.highlightedImage) {
            self.imageView.highlighted = YES;
        } else {
            self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.imageView.tintColor = [UIColor colorWithRed:153.f/255.f green:153.f/255.f blue:153.f/255.f alpha:1.f];
        }
    }
    self.titleLabel.textColor = self.enabled ? [UIColor.darkTextColor colorWithAlphaComponent:.9f] : [UIColor colorWithRed:153.f/255.f green:153.f/255.f blue:153.f/255.f alpha:1.f];
}

#pragma mark - Getter
- (UIImage *)image {
    return self.imageView.image;
}

- (NSString *)title {
    return self.titleLabel.text;
}

@end
