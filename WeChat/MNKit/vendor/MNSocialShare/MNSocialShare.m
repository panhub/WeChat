//
//  MNSocialShare.m
//  MNKit
//
//  Created by Vincent on 2019/2/16.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNSocialShare.h"
#if __has_include(<UMShare/UMShare.h>)

@implementation MNSocialShare
#pragma mark - 分享网页
+ (void)shareWebPageWithUrl:(NSString *)url
                      title:(NSString *)title
                         desc:(NSString *)desc
                        thumbnailImage:(id)thumbnail
                     platform:(UMSocialPlatformType)platform
                      completion:(MNSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    [self showDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block UIImage *thumbnailImage;
        dispatch_group_t grop = dispatch_group_create();
        if (thumbnail) {
            if ([thumbnail isKindOfClass:UIImage.class]) {
                thumbnailImage = thumbnail;
            } else if ([thumbnail isKindOfClass:NSData.class]) {
                NSData *imageData = (NSData *)thumbnail;
                if (imageData.length) thumbnailImage = [UIImage imageWithData:imageData];
            } else if ([thumbnail isKindOfClass:NSString.class]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
                dispatch_group_enter(grop);
                [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:(NSString *)thumbnail] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!finished) return;
                    if (image) thumbnailImage = image;
                    dispatch_group_leave(grop);
                }];
#else
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail] options:NSDataReadingUncached error:nil];
                if (imageData.length) thumbnailImage = [UIImage imageWithData:imageData];
#endif
            }
        }
        dispatch_group_notify(grop, dispatch_get_main_queue(), ^{
            [self closeDialog];
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
        });
    });
}

#pragma mark - 分享视频
+ (void)shareVideoWithUrl:(NSString *)url
                    title:(NSString *)title
                     desc:(NSString *)desc
                thumbnailImage:(id)thumbnail
                 platform:(UMSocialPlatformType)platform
               completion:(MNSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    [self showDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block UIImage *thumbnailImage;
        dispatch_group_t grop = dispatch_group_create();
        if (thumbnail) {
            if ([thumbnail isKindOfClass:UIImage.class]) {
                thumbnailImage = thumbnail;
            } else if ([thumbnail isKindOfClass:NSData.class]) {
                NSData *imageData = (NSData *)thumbnail;
                if (imageData.length) thumbnailImage = [UIImage imageWithData:imageData];
            } else if ([thumbnail isKindOfClass:NSString.class]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
                dispatch_group_enter(grop);
                [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:(NSString *)thumbnail] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!finished) return;
                    if (image) thumbnailImage = image;
                    dispatch_group_leave(grop);
                }];
#else
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:(NSString *)thumbnail] options:NSDataReadingUncached error:nil];
                if (imageData.length) thumbnailImage = [UIImage imageWithData:imageData];
#endif
            }
        }
        dispatch_group_notify(grop, dispatch_get_main_queue(), ^{
            [self closeDialog];
            //创建视频内容对象
            UMShareVideoObject *shareObject = [UMShareVideoObject shareObjectWithTitle:title descr:desc thumImage:thumbnailImage];
            //设置视频网页播放地址
            shareObject.videoUrl = url;
            //shareObject.videoStreamUrl = @"这里设置视频数据流地址(如果有的话，而且也要看所分享的平台支不支持)";
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager] shareToPlatform:platform
                                                messageObject:messageObject
                                        currentViewController:nil
                                                   completion:handler];
        });
    });
}

#pragma mark - 分享音乐
+ (void)shareMusicWithUrl:(NSString *)url
                    title:(NSString *)title
                     desc:(NSString *)desc
                 thumbnailImage:(id)thumbnail
                 platform:(UMSocialPlatformType)platform
               completion:(MNSocialShareHandler)handler
{
    if (url.length <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    [self showDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        __block UIImage *thumbnailImage;
        dispatch_group_t grop = dispatch_group_create();
        if (thumbnail) {
            if ([thumbnail isKindOfClass:UIImage.class]) {
                thumbnailImage = thumbnail;
            } else if ([thumbnail isKindOfClass:NSData.class]) {
                NSData *imageData = (NSData *)thumbnail;
                if (imageData.length) thumbnailImage = [UIImage imageWithData:imageData];
            } else if ([thumbnail isKindOfClass:NSString.class]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
                dispatch_group_enter(grop);
                [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:(NSString *)thumbnail] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!finished) return;
                    if (image) thumbnailImage = image;
                    dispatch_group_leave(grop);
                }];
#else
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail] options:NSDataReadingUncached error:nil];
                if (imageData) thumbnailImage = [UIImage imageWithData:imageData];
#endif
            }
        }
        dispatch_group_notify(grop, dispatch_get_main_queue(), ^{
            [self closeDialog];
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
        });
    });
}

#pragma mark - 分享图片
+ (void)shareImages:(NSArray <id>*)images
           platform:(UMSocialPlatformType)platform
         completion:(MNSocialShareHandler)handler
{
    if (images.count <= 0) {
        if (handler) {
            NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"数据错误"}];
            handler(nil, error);
        }
        return;
    }
    [self showDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t grop = dispatch_group_create();
        NSUInteger count = platform == UMSocialPlatformType_Sina ? 9 : (platform == UMSocialPlatformType_Qzone ? 20 : 1);
        NSArray *array = images.count > count ? [images subarrayWithRange:NSMakeRange(0, count)] : images.copy;
        NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:array.count];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UIImage.class]) {
                [imgs addObject:obj];
            } else if ([obj isKindOfClass:NSData.class]) {
                NSData *imageData = (NSData *)obj;
                if (imageData.length) [imgs addObject:imageData];
            } else if ([obj isKindOfClass:NSString.class]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
                dispatch_group_enter(grop);
                [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:(NSString *)obj] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    if (!finished) return;
                    if (image) [imgs addObject:image];
                    dispatch_group_leave(grop);
                }];
#else
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:obj] options:NSDataReadingUncached error:nil];
                if (imageData) [imgs addObject:imageData];
#endif
            }
        }];
        dispatch_group_notify(grop, dispatch_get_main_queue(), ^{
            [self closeDialog];
            if (imgs.count <= 0) {
                if (handler) {
                    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"获取图片失败"}];
                    handler(nil, error);
                }
                return;
            }
            //创建图片内容对象
            UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
            //设置图片或图片数组
            if (imgs.count == 1) {
                shareObject.shareImage = imgs.firstObject;
            } else {
                shareObject.shareImageArray = imgs;
            }
            //创建分享消息对象
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
            [[UMSocialManager defaultManager] shareToPlatform:platform
                                                messageObject:messageObject
                                        currentViewController:nil
                                                   completion:handler];
        });
    });
}

#pragma mark - 分享小程序
+ (void)shareMiniProgramTitle:(NSString *)title
                         desc:(NSString *)desc
               thumbnailImage:(id _Nullable)thumbnailImage
                   webpageUrl:(NSString *)webpageUrl
                     userName:(NSString *)userName
                         path:(NSString *)path
                     platform:(UMSocialPlatformType)platform
                   completion:(MNSocialShareHandler)handler
{
    [self showDialog];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        dispatch_group_t grop = dispatch_group_create();
        __block UIImage *thumbImage = nil;
        if ([thumbnailImage isKindOfClass:UIImage.class]) {
            thumbImage = thumbnailImage;
        } else if ([thumbnailImage isKindOfClass:NSData.class]) {
            NSData *imageData = (NSData *)thumbnailImage;
            if (imageData.length) thumbImage = [UIImage imageWithData:imageData];
        } else if ([thumbnailImage isKindOfClass:NSString.class]) {
#if __has_include("SDWebImageManager.h") || __has_include(<SDWebImage/SDWebImageManager.h>)
            dispatch_group_enter(grop);
            [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:(NSString *)thumbnailImage] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (!finished) return;
                if (image) thumbImage = image;
                dispatch_group_leave(grop);
            }];
#else
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnailImage] options:NSDataReadingUncached error:nil];
            if (imageData) thumbImage = [UIImage imageWithData:imageData];
#endif
        }
        dispatch_group_notify(grop, dispatch_get_main_queue(), ^{
            [self closeDialog];
            UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
            UMShareMiniProgramObject *shareObject = [UMShareMiniProgramObject shareObjectWithTitle:title descr:desc thumImage:thumbImage];
            shareObject.webpageUrl = webpageUrl;
            shareObject.userName = userName;
            shareObject.path = path;
            messageObject.shareObject = shareObject;
            shareObject.miniProgramType = UShareWXMiniProgramTypeRelease;
            [[UMSocialManager defaultManager] shareToPlatform:platform messageObject:messageObject currentViewController:nil completion:handler];
        });
    });
}

#pragma mark - 授权并获取用户信息
+ (void)handAuthInfoWithPlatform:(UMSocialPlatformType)platform completion:(MNSocialShareHandler)handler {
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platform currentViewController:nil completion:^(id result, NSError *error) {
        if (result && [result isKindOfClass:UMSocialUserInfoResponse.class]) {
            if (handler) handler(result, nil);
        } else {
            if (handler) handler(nil, error);
        }
    }];
}
//#import "UIWindow+MNHelper.h"
#pragma mark - 用户界面提示
+ (void)showDialog {
#if __has_include("UIView+MNLoadDialog.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.delegate.window showLoadDialog:@"请稍后"];
    });
#endif
}

+ (void)closeDialog {
#if __has_include("UIView+MNLoadDialog.h")
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.delegate.window closeDialog];
    });
#endif
}

@end
#endif
