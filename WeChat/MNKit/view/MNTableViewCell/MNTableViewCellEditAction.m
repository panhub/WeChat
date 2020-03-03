//
//  MNTableViewCellEditAction.m
//  MNKit
//
//  Created by Vincent on 2019/4/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNTableViewCellEditAction.h"

@interface MNTableViewCellEditAction ()

@end

@implementation MNTableViewCellEditAction
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"";
        self.width = 60.f;
        self.inset = UIEdgeInsetsMake(0.f, 15.f, 0.f, 15.f);
        self.titleFont = [UIFont systemFontOfSize:18.f];
        self.titleColor = [UIColor whiteColor];
        self.style = MNTableViewCellEditingStyleNormal;
    }
    return self;
}

+ (instancetype)actionWithStyle:(MNTableViewCellEditingStyle)style {
    MNTableViewCellEditAction *action = [MNTableViewCellEditAction new];
    action.style = style;
    return action;
}

- (void)setStyle:(MNTableViewCellEditingStyle)style {
    _style = style;
    self.backgroundColor = style ? R_G_B(253.f, 61.f, 48.f) : R_G_B(199.f, 198.f, 203.f);
}

@end
