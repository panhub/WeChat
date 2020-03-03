//
//  WXMomentWebpage.m
//  MNChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//  

#import "WXMomentWebpage.h"

@interface WXMomentWebpage ()
{
    WXMomentPicture *_picture;
}
@end

@implementation WXMomentWebpage
- (instancetype)init{
    self = [super init];
    if (self) {
        self.identifier = MNFileHandle.fileName;
    }
    return self;
}
#pragma mark - Getter
- (WXMomentPicture *)picture {
    if (!_picture && _img.length) {
        _picture = [MNChatHelper.helper.cache objectForKey:_img];
    }
    return _picture;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    WXMomentWebpage *item = [WXMomentWebpage allocWithZone:zone];
    item.identifier = self.identifier;
    item.title = self.title;
    item.img = self.img;
    item.video = self.isVideo;
    item->_picture = _picture.copy;
    return item;
}

@end
