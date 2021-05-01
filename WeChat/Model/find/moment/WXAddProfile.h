//
//  WXAddProfile.h
//  WeChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//  新建朋友圈数据模型

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WXAddProfileType) {
    WXAddProfileTypeImage = 0,
    WXAddProfileTypeVideo,
    WXAddProfileTypeAdd
};

@interface WXAddProfile : NSObject

/**实例化最后一个数据模型*/
@property (nonatomic, readonly, class) WXAddProfile *addModel;

/**最后一个*/
@property (nonatomic, readonly) BOOL isAddModel;

/**配图类型*/
@property (nonatomic) WXAddProfileType type;

/**图片*/
@property (nonatomic, strong) UIImage *image;

/**图片/视频地址*/
@property (nonatomic, strong) id content;

/**显示图片的view*/
@property (nonatomic, weak) UIImageView *containerView;


+ (WXAddProfile *)modelWithAsset:(MNAsset *)asset;

- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithVideo:(NSString *)videoPath thumbnail:(UIImage *)thumbnail;

@end
