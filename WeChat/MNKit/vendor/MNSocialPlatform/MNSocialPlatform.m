//
//  MNSocialPlatform.m
//  MNKit
//
//  Created by Vincent on 2019/2/16.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNSocialPlatform.h"
#if __has_include(<UMShare/UMShare.h>)

@implementation MNSocialPlatform
#pragma mark - 分享网页
+ (void)shareWebPageWithUrl:(NSString *)url
                      title:(NSString *)title
                         desc:(NSString *)desc
                    thumbnailImage:(id)thumbnailImage
                     platform:(UMSocialPlatformType)platform
                      completion:(UMSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:thumbnailImage];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:platform
                                        messageObject:messageObject
                                currentViewController:nil
                                           completion:handler];
}

#pragma mark - 分享视频
+ (void)shareVideoWithUrl:(NSString *)url
                    title:(NSString *)title
                     desc:(NSString *)desc
                thumbnailImage:(id)thumbnailImage
                 platform:(UMSocialPlatformType)platform
               completion:(UMSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建视频内容对象
    UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:desc thumImage:thumbnailImage];
    //设置视频网页播放地址
    shareObject.videoUrl = url;
    //shareObject.videoStreamUrl = @"这里设置视频数据流地址(如果有的话，而且也要看所分享的平台支不支持)";
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:platform
                                        messageObject:messageObject
                                currentViewController:nil
                                           completion:handler];
}

#pragma mark - 分享音乐
+ (void)shareMusicWithUrl:(NSString *)url
                    title:(NSString *)title
                     desc:(NSString *)desc
                thumbnailImage:(id)thumbnailImage
                 platform:(UMSocialPlatformType)platform
               completion:(UMSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //创建音乐内容对象
    UMShareMusicObject *shareObject = [UMShareMusicObject shareObjectWithTitle:title descr:desc thumImage:thumbnailImage];
    //设置音乐网页播放地址
    shareObject.musicUrl = url;
    // shareObject.musicDataUrl = @"这里设置音乐数据流地址(如果有的话，而且也要看所分享的平台支不支持)";
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:platform
                                        messageObject:messageObject
                                currentViewController:nil
                                           completion:handler];
}

#pragma mark - 分享图片
+ (void)shareImages:(NSArray <id>*)images
          thumbnailImage:(id)thumbnailImage
           platform:(UMSocialPlatformType)platform
         completion:(UMSocialShareHandler)handler
{
    if (images.count <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSUInteger count = 1;
        switch (platform) {
            case UMSocialPlatformType_Sina:
            {
                count = 9;
            } break;
            case UMSocialPlatformType_Qzone:
            {
                count = 20;
            } break;
            default:
                break;
        }
        NSArray *array = images;
        if (array.count > count) {
            array = [array subarrayWithRange:NSMakeRange(0, count)];
        }
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UIImage.class]) {
                [imgs addObject:obj];
            } else if ([obj isKindOfClass:NSData.class]) {
                NSData *data = (NSData *)obj;
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    [imgs addObject:image];
                }
            } else if ([obj isKindOfClass:NSString.class]) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj] options:NSDataReadingUncached error:nil];
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    [imgs addObject:image];
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (imgs.count <= 0) {
                if (handler) {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
                    handler(nil, error);
                }
                return;
            }
            id info = imgs.count == 1 ? imgs.firstObject : imgs;
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            //创建图片内容对象
            UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
            //如果有缩略图，则设置缩略图
            shareObject.thumbImage = thumbnailImage;
            //设置图片或图片数组
            if (imgs.count == 1) {
                shareObject.shareImage = imgs.firstObject;
            } else {
                shareObject.shareImageArray = imgs;
            }
            //图片
            shareObject.shareImage = info;
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager] shareToPlatform:platform
                                                messageObject:messageObject
                                        currentViewController:nil
                                                   completion:handler];
        });
    });
}

#pragma mark - 授权并获取用户信息
+ (void)handAuthInfoWithPlatform:(UMSocialPlatformType)platform completion:(UMSocialShareHandler)handler {
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platform currentViewController:nil completion:^(id result, NSError *error) {
        if (result && [result isKindOfClass:[UMSocialUserInfoResponse class]]) {
            if (handler) handler(result, nil);
        } else {
            if (handler) handler(nil, error);
        }
    }];
}

@end
#endif
