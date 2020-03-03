//
//  WXShakeHistory.m
//  MNChat
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
    UIImage *_thumbnailImage;
}

- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.type = WXShakeHistoryPerson;
        self.title = user.nickname;
        self.subtitle = [NSString stringWithFormat:@"相距%@公里", @(arc4random()%1000 + 30)];
        self.signature = user.signature;
        self.date = [NSDate timestamps];
        self.gender = user.gender;
        self.thumbnailData = user.avatarData;
        NSMutableDictionary *dic = kTransform(NSDictionary *, user.JsonValue).mutableCopy;
        [dic removeObjectForKey:kPath(user.avatarData)];
        self.extend = dic.JsonData;
    }
    return self;
}

- (instancetype)initWithSong:(WXSong *)song {
    if (self = [super init]) {
        self.type = WXShakeHistoryMusic;
        self.title = song.title;
        self.subtitle = song.artist;
        self.date = [NSDate timestamps];
        self.gender = MNGenderUnknown;
        self.thumbnailData = song.artwork.PNGData;
        self.extend = song.title.JsonData;
    }
    return self;
}

+ (instancetype)fetchTVHistory {
    WXShakeHistory *history = WXShakeHistory.new;
    history.type = WXShakeHistoryTV;
    history.gender = MNGenderUnknown;
    history.date = [NSDate timestamps];
    history.title = @"看电视，玩微信摇电视";
    history.thumbnailData = [UIImage imageNamed:@"shake_tv"].PNGData;
    return history;
}

#pragma mark - Getter
- (UIImage *)thumbnailImage {
    if (!_thumbnailImage && _thumbnailData.length) {
        _thumbnailImage = [UIImage imageWithData:_thumbnailData];
    }
    return _thumbnailImage;
}

@end
