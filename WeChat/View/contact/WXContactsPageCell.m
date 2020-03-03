//
//  WXContactsPageCell.m
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXContactsPageCell.h"

@implementation WXContactsPageCell
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //UIImageWithUnicode(MNFontUnicodeSearch, UIColorWithAlpha([UIColor darkTextColor], .75f), 10.f)
        UIImageView *imageView = [UIImageView imageViewWithFrame:self.bounds
                                                           image:UIImageNamed(@"wx_contacts_search")];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *textLabel = [UILabel labelWithFrame:self.bounds
                                            text:nil
                                   textAlignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkTextColor], .75f)
                                            font:UIFontWithNameSize(MNFontNameMedium, 10.f)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (self.index == 0) return;
    [super setBackgroundColor:backgroundColor];
}

/*
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (CGRectEqualToRect(frame, CGRectZero)) return;
    self.imageView.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetWith(2.f));
}
*/

@end
