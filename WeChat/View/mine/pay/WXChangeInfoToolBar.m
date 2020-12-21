//
//  WXChangeInfoToolBar.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeInfoToolBar.h"

@implementation WXChangeInfoToolBar
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *shadow = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        shadow.frame = CGRectMake(0.f, 0.f, self.width_mn, 1.f);
        [self addSubview:shadow];
        
        CGFloat x = (self.width_mn - 25.f*2.f - 60.f)/2.f;
        NSArray <NSString *>*ims = @[@"wx_web_tool_back", @"wx_web_tool_next_disable"];
        [ims enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithFrame:CGRectMake(x + 85.f*idx, (50.f - 25.f)/2.f, 25.f, 25.f) image:[UIImage imageNamed:obj] title:nil titleColor:nil titleFont:nil];
            button.tag = idx;
            [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }];
        
        self.height_mn = 50.f + MN_TAB_SAFE_HEIGHT;
    }
    return self;
}

- (void)buttonClicked:(UIButton *)button {
    if (self.buttonClickedHandler) {
        self.buttonClickedHandler(button.tag);
    }
}

@end
