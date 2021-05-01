//
//  WXAddProfile.m
//  WeChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddProfile.h"

@implementation WXAddProfile

+ (WXAddProfile *)addModel {
    WXAddProfile *model = [WXAddProfile new];
    model.type = WXAddProfileTypeAdd;
    model.image = [UIImage imageNamed:@"wx_moment_add_pic"];
    return model;
}

+ (WXAddProfile *)modelWithAsset:(MNAsset *)asset {
    if (asset.type == MNAssetTypePhoto) {
        return [[self alloc] initWithImage:asset.content];
    }
    return [[self alloc] initWithVideo:asset.content thumbnail:asset.thumbnail];
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.image = image;
        self.content = image;
        self.type = WXAddProfileTypeImage;
    }
    return self;
}

- (instancetype)initWithVideo:(NSString *)videoPath thumbnail:(UIImage *)thumbnail {
    if (self = [super init]) {
        self.image = thumbnail;
        self.content = videoPath;
        self.type = WXAddProfileTypeVideo;
    }
    return self;
}

- (BOOL)isAddModel {
    return self.type == WXAddProfileTypeAdd;
}

@end
