//
//  WXMomentRemind.m
//  MNChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXMomentRemind.h"
#import "WXMoment.h"

@implementation WXMomentRemind
- (instancetype)init {
    if (self = [super init]) {
        self.identifier = [NSDate shortTimestamps];
    }
    return self;
}

+ (instancetype)remindWithUid:(NSString *)uid withMoment:(WXMoment *)moment {
    WXMomentRemind *model = WXMomentRemind.new;
    model.from_uid = uid;
    model.moment = moment.identifier;
    model.date = NSDate.timestamps;
    return model;
}

+ (instancetype)remindWithComment:(WXMomentComment *)comment withMoment:(WXMoment *)moment {
    WXMomentRemind *model = WXMomentRemind.new;
    model.from_uid = comment.from_uid;
    model.to_uid = comment.to_uid;
    model.content = comment.content;
    model.moment = moment.identifier;
    model.date = comment.date;
    return model;
}

@end
