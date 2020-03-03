//
//  WXWebpage.m
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWebpage.h"

@implementation WXWebpage
@synthesize thumbnail = _thumbnail;

+ (instancetype)webpageWithSandbox:(NSDictionary *)dic {
    if (!dic) return nil;
    WXWebpage *webpage = [WXWebpage new];
    webpage.url = dic[WXShareWebpageUrl];
    webpage.title = dic[WXShareWebpageTitle];
    webpage.thumbnailData = dic[WXShareWebpageThumbnail];
    webpage.date = [NSDate dateStringWithTimestamp:dic[WXShareWebpageDate] format:@"yyyy/MM/dd"];
    if (webpage.url <= 0 || webpage.title.length <= 0 || webpage.thumbnailData.length <= 0) return nil;
    return webpage;
}

- (UIImage *)thumbnail {
    if (!_thumbnail && _thumbnailData.length > 0) {
        _thumbnail = [UIImage imageWithData:_thumbnailData];
    }
    return _thumbnail;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.url forKey:sql_field(self.url)];
    [aCoder encodeObject:self.title forKey:sql_field(self.title)];
    [aCoder encodeObject:self.date forKey:sql_field(self.date)];
    [aCoder encodeObject:self.thumbnailData forKey:sql_field(self.thumbnailData)];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:sql_field(self.url)];
        self.title = [aDecoder decodeObjectForKey:sql_field(self.title)];
        self.date = [aDecoder decodeObjectForKey:sql_field(self.date)];
        self.thumbnailData = [aDecoder decodeObjectForKey:sql_field(self.thumbnailData)];
    }
    return self;
}

@end
