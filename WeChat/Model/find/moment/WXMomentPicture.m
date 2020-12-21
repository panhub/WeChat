//
//  WXMomentPicture.m
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPicture.h"

@interface WXMomentPicture ()
{
    UIImage *_image;
}
@end

@implementation WXMomentPicture
- (instancetype)init {
    if (self = [super init]) {
        self.identifier = MNFileHandle.fileName;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    NSData *data = image.PNGData;
    if (!data) return nil;
    if (self = [self init]) {
        self.data = data;
    }
    return self;
}

#pragma mark - Getter
- (UIImage *)image {
    if (!_image && _data.length) {
        _image = [UIImage imageWithData:_data];
    }
    return _image;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXMomentPicture *picture = [WXMomentPicture allocWithZone:zone];
    picture.identifier = self.identifier;
    picture.data = self.data;
    picture->_image = _image;
    return picture;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.data = [aDecoder decodeObjectForKey:@"data"];
        self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    }
    return self;
}

@end
