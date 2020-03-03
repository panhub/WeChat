//
//  WXMomentReplyViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentReplyViewModel.h"
#import "WXMomentViewModel.h"

@implementation WXMomentReplyViewModel

- (NSString *)placeholder {
    NSMutableString *placeholder = @"".mutableCopy;
    [placeholder appendString:self.from_user.name];
    if (self.to_user) {
        [placeholder appendFormat:@"回复%@:", self.to_user.name];
    } else {
        [placeholder appendString:@"评论:"];
    }
    return placeholder.copy;
}

@end
