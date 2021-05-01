//
//  WXNewsCategory.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsCategory.h"

@implementation WXNewsCategory
+ (WXNewsCategory *)modelWithTitle:(NSString *)title type:(NSString *)type {
    WXNewsCategory *m = WXNewsCategory.new;
    m.title = title;
    m.type = type;
    return m;
}

@end
