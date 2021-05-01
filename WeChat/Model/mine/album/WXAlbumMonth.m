//
//  WXAlbumMonth.m
//  WeChat
//
//  Created by Vicent on 2021/4/9.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXAlbumMonth.h"

@implementation WXAlbumMonth
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pictures = NSMutableArray.new;
    }
    return self;
}
@end
