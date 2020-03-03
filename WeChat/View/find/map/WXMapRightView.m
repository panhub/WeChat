//
//  WXMapRightView.m
//  MNChat
//
//  Created by Vincent on 2019/5/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMapRightView.h"

@implementation WXMapRightView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.f;
        self.layer.shadowOpacity = 1.f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowColor = [UIColorWithAlpha([UIColor grayColor], .3f) CGColor];
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.layer.bounds] CGPath];
        
        
        
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectMake(SCREEN_WIDTH - 50.f, TOP_BAR_HEIGHT + 15.f, 40.f, 170.f);
    [super setFrame:frame];
}

@end
