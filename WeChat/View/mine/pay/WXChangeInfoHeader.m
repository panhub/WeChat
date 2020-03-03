//
//  WXChangeInfoHeader.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeInfoHeader.h"
#import "WXChangeModel.h"

@interface WXChangeInfoHeader ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@end

@implementation WXChangeInfoHeader
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, 40.f, self.width_mn, 17.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:UIFontRegular(17.f)];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *moneyLabel = [UILabel labelWithFrame:CGRectMake(0.f, titleLabel.bottom_mn + 17.f, titleLabel.width_mn, 30.f) text:@"" textAlignment:NSTextAlignmentCenter textColor:[UIColor blackColor] font:UIFontMedium(30.f)];
        [self addSubview:moneyLabel];
        self.moneyLabel = moneyLabel;
        
        UIImageView *shadow = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        shadow.frame = CGRectMake(25.f, moneyLabel.bottom_mn + 45.f, self.width_mn - 50.f, 1.f);
        [self addSubview:shadow];
        
        self.height_mn = shadow.bottom_mn + 17.f;
    }
    return self;
}

- (void)setModel:(WXChangeModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    NSString *money = [NSString stringWithFormat:@"%.2f", model.money];
    if (model.money > 0.f) money = [@"+" stringByAppendingString:money];
    self.moneyLabel.text = money;
}

@end
