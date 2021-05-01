//
//  WXAlbumYear.m
//  WeChat
//
//  Created by Vicent on 2021/4/9.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXAlbumYear.h"

@implementation WXAlbumYear
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.month = NSMutableArray.new;
    }
    return self;
}

- (instancetype)initWithYear:(NSString *)year {
    if (self = [self init]) {
        self.year = year;
        self.title = [year stringByAppendingString:@"年"];
    }
    return self;
}

@end
