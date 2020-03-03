//
//  MNEmojiKeyboardConfiguration.m
//  MNChat
//
//  Created by Vincent on 2020/2/16.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNEmojiKeyboardConfiguration.h"

@implementation MNEmojiKeyboardConfiguration
- (instancetype)init {
    self = [super init];
    if (self) {
        self.style = MNEmojiKeyboardStyleLight;
        self.allowsUseEmojiPackets = YES;
        self.returnKeyColor = UIColor.whiteColor;
        self.returnKeyType = UIReturnKeySend;
        self.returnKeyTitleColor = UIColor.darkTextColor;
        self.returnKeyTitleFont = [UIFont systemFontOfSize:15.5f];
        self.separatorColor = [UIColor.darkGrayColor colorWithAlphaComponent:.2f];
        self.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1.f];
        self.tintColor = [UIColor colorWithRed:246.f/255.f green:246.f/255.f blue:246.f/255.f alpha:1.f];
        self.selectedColor = UIColor.whiteColor;
        self.pageIndicatorHeight = 15.f;
        self.pageIndicatorColor = [UIColor.grayColor colorWithAlphaComponent:.37f];
        self.currentPageIndicatorColor = [UIColor.grayColor colorWithAlphaComponent:.95f];
    }
    return self;
}

@end
