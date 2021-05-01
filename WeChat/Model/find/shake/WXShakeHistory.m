//
//  WXShakeHistory.m
//  WeChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeHistory.h"
#import "WXSong.h"
#import "WXUser.h"

@interface WXShakeHistory ()

@end

@implementation WXShakeHistory
{
    UIImage *_image;
}

- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.type = WXShakeHistoryPerson;
        self.title = user.nickname;
        self.subtitle = [NSString stringWithFormat:@"相距%@公里", @(arc4random()%1000 + 30)];
        self.signature = user.signature;
        self.date = [NSDate timestamps];
        self.gender = user.gender;
        self.imageData = user.avatar.PNGData;
        self.extend = kTransform(NSDictionary *, user.JsonValue).JsonData;
    }
    return self;
}

- (instancetype)initWithSong:(WXSong *)song {
    if (self = [super init]) {
        self.type = WXShakeHistoryMusic;
        self.title = song.title;
        self.subtitle = song.artist;
        self.date = [NSDate timestamps];
        self.gender = WechatGenderUnknown;
        self.imageData = song.artwork.PNGData;
        self.extend = song.title.JsonData;
    }
    return self;
}

+ (instancetype)fetchTVHistory {
    WXShakeHistory *history = WXShakeHistory.new;
    history.type = WXShakeHistoryTV;
    history.gender = WechatGenderUnknown;
    history.date = [NSDate timestamps];
    history.title = @"看电视，玩微信摇电视";
    history.imageData = [UIImage imageNamed:@"shake_tv"].PNGData;
    return history;
}

#pragma mark - Getter
- (UIImage *)image {
    if (!_image && _imageData.length) {
        _image = [UIImage imageWithData:_imageData];
    }
    return _image;
}

@end
