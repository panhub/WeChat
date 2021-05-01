//
//  WXMomentReplyViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentReplyViewModel.h"
#import "WXMomentViewModel.h"
#import "WXTimeline.h"

@implementation WXMomentReplyViewModel

- (NSString *)placeholder {
    NSMutableString *placeholder = @"".mutableCopy;
    [placeholder appendString:self.fromUser.name];
    if (self.toUser) {
        [placeholder appendFormat:@"回复%@:", self.toUser.name];
    } else {
        [placeholder appendString:@"评论:"];
    }
    return placeholder.copy;
}

@end
