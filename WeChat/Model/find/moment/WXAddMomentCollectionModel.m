//
//  WXAddMomentCollectionModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentCollectionModel.h"

@implementation WXAddMomentCollectionModel

+ (instancetype)lastModel {
    WXAddMomentCollectionModel *model = [WXAddMomentCollectionModel new];
    model.last = YES;
    return model;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        self.last = NO;
        self.image = image;
    }
    return self;
}

@end
