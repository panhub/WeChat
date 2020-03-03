//
//  WXMomentRemindView.m
//  MNChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXMomentRemindView.h"

@interface WXMomentRemindView ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXMomentRemindView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size.height = 45.f;
    if (self = [super initWithFrame:CGRectZero]) {
        
        UIViewSetCornerRadius(self, 5.f);
        self.backgroundColor = UIColorWithSingleRGB(57.f);
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(4.f, 4.f, 33.f, 33.f) image:nil];
        imageView.userInteractionEnabled = NO;
        UIViewSetCornerRadius(imageView, 4.f);
        [self addSubview:imageView];
        self.imageView = imageView;
        
        self.height_mn = imageView.bottom_mn + imageView.top_mn;
        
        UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(imageView.right_mn, imageView.top_mn, 0.f, imageView.height_mn) text:nil textAlignment:NSTextAlignmentCenter textColor:[UIColor whiteColor] font:UIFontMedium(15.f)];
        textLabel.userInteractionEnabled = NO;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        UIImage *image = [UIImage imageNamed:@"wx_moment_remind_arrow"];
        CGSize size = CGSizeMultiplyToHeight(image.size, 12.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(textLabel.right_mn, MEAN(self.height_mn - size.height), size.width, size.height) image:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        arrowView.tintColor = UIColorWithRGBA(20.f, 20.f, 20.f, .5f);
        arrowView.userInteractionEnabled = NO;
        [self addSubview:arrowView];
        
        self.width_mn = arrowView.right_mn + 15.f;
        
        arrowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }
    return self;
}

- (void)setUid:(NSString *)uid {
    _uid = uid.copy;
    self.imageView.image = [[[MNChatHelper helper] userForUid:uid] avatar];
}

- (void)setDesc:(NSString *)desc {
    _desc = desc.copy;
    CGFloat w = self.textLabel.width_mn;
    CGFloat c = self.centerX_mn;
    CGSize size = [desc sizeWithFont:self.textLabel.font];
    self.textLabel.width_mn = size.width + 50.f;
    self.textLabel.text = desc;
    self.width_mn += (self.textLabel.width_mn - w);
    self.centerX_mn = c;
}

@end
