//
//  WXContactsPageCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsPageCell.h"

@interface WXContactsPageCell ()
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WXContactsPageCell
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:self.bounds image:[UIImage imageNamed:@"wx_contacts_search"]];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *textLabel = [UILabel labelWithFrame:self.bounds
                                            text:nil
                                   alignment:NSTextAlignmentCenter
                                       textColor:[UIColor.darkTextColor colorWithAlphaComponent:.75f]
                                            font:UIFontWithNameSize(MNFontNameMedium, 10.f)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        textLabel.backgroundColor = UIColor.clearColor;
        textLabel.userInteractionEnabled = NO;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (!self.imageView.isHidden) return;
    self.backgroundColor = highlighted ? THEME_COLOR : UIColor.clearColor;
    self.textLabel.textColor = highlighted ? UIColor.whiteColor : [UIColor.darkTextColor colorWithAlphaComponent:.75f];
}

/*
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    self.imageView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetWith(2.f));
}
*/

@end
