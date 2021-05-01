//
//  MNAssetSelectControl.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAssetSelectControl.h"

@interface MNAssetSelectControl ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation MNAssetSelectControl
- (instancetype)init {
    return [self initWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = frame.size.height/2.f;
        
        UIImageView *backgroundView = [UIImageView imageViewWithFrame:self.bounds image:[MNBundle imageForResource:@"icon_checkbox"]];
        backgroundView.hidden = YES;
        backgroundView.userInteractionEnabled = NO;
        backgroundView.highlightedImage = [MNBundle imageForResource:@"icon_checkboxHL"];
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        UILabel *textLabel = [UILabel labelWithFrame:self.bounds text:nil alignment:NSTextAlignmentCenter textColor:UIColorWithSingleRGB(251.f) font:[UIFont systemFontOfSize:12.f]];
        textLabel.userInteractionEnabled = NO;
        textLabel.backgroundColor = UIColorWithRGB(7.f, 192.f, 96.f);
        [self addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        if (self.index == 0) {
            self.textLabel.hidden = YES;
            self.backgroundView.hidden = NO;
            self.backgroundView.highlighted = YES;
        } else {
            self.textLabel.hidden = NO;
            self.textLabel.text = [NSString stringWithFormat:@"%ld", self.index];
            self.backgroundView.hidden = YES;
        }
    } else {
        self.textLabel.hidden = YES;
        self.backgroundView.hidden = NO;
        self.backgroundView.highlighted = NO;
    }
}

@end
