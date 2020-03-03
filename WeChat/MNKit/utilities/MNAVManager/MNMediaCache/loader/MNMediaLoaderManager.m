//
//  MNMediaLoaderManager.m
//  MNKit
//
//  Created by Vincent on 2018/11/30.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaLoaderManager.h"
#import "MNMediaResourceLoader.h"

static NSString * MNMediaResourceLoadRequestErrorScheme = @"mn.media.load.request.error.scheme";

@interface MNMediaLoaderManager ()<AVAssetResourceLoaderDelegate, MNMediaResourceLoaderDatagate>

@property (nonatomic, strong) NSMutableDictionary<NSString *, MNMediaResourceLoader *> *loaderCache;

@end

@implementation MNMediaLoaderManager
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.loaderCache = [NSMutableDictionary dictionaryWithCapacity:0];
    return self;
}

- (void)cleanCache {
    [self.loaderCache removeAllObjects];
}

- (void)cancelAllLoader {
    [self.loaderCache enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MNMediaResourceLoader * _Nonnull loader, BOOL * _Nonnull stop) {
        [loader cancel];
    }];
    [self.loaderCache removeAllObjects];
}

#pragma mark -
- (NSString *)keyForLoaderWithURL:(NSURL *)URL {
    NSString *url = URL.absoluteString;
    if ([url hasPrefix:MNMediaResourceLoadRequestErrorScheme]) {
        return [url stringByReplacingOccurrencesOfString:MNMediaResourceLoadRequestErrorScheme withString:@""];
    }
    return @"";
}

- (MNMediaResourceLoader *)loaderForRequest:(AVAssetResourceLoadingRequest *)request {
    NSString *key = [self keyForLoaderWithURL:request.request.URL];
    MNMediaResourceLoader *loader = self.loaderCache[key];
    return loader;
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    NSString *url = loadingRequest.request.URL.absoluteString;
    if ([url hasPrefix:MNMediaResourceLoadRequestErrorScheme]) {
        MNMediaResourceLoader *loader = [self loaderForRequest:loadingRequest];
        if (!loader) {
            url = [url stringByReplacingOccurrencesOfString:MNMediaResourceLoadRequestErrorScheme withString:@""];
            loader = [[MNMediaResourceLoader alloc] initWithURL:[NSURL URLWithString:url]];
            loader.delegate = self;
            self.loaderCache[url] = loader;
        }
        [loader addRequest:loadingRequest];
        return YES;
    }
    return NO;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(nonnull AVAssetResourceLoadingRequest *)loadingRequest {
    MNMediaResourceLoader *loader = [self loaderForRequest:loadingRequest];
    [loader removeRequest:loadingRequest];
}

#pragma mark - MNMediaResourceLoaderDatagate
- (void)mediaResourceLoader:(MNMediaResourceLoader *)resourceLoader didFailWithError:(NSError *)error {
    [resourceLoader cancel];
    if ([self.delegate respondsToSelector:@selector(mediaLoaderManagerLoadURL:didFailWithError:)]) {
        [self.delegate mediaLoaderManagerLoadURL:resourceLoader.URL didFailWithError:error];
    }
}

@end


@implementation MNMediaLoaderManager (PlayerItem)

- (AVPlayerItem *)playerItemWithURL:(NSURL *)URL {
    NSURL *assetURL = [MNMediaLoaderManager assetURLWithURL:URL];
    if (!assetURL) return nil;
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    [urlAsset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if (@available(iOS 9.0, *)) {
        if ([playerItem respondsToSelector:@selector(setCanUseNetworkResourcesForLiveStreamingWhilePaused:)]) {
            playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = YES;
        }
    }
    #endif
    return playerItem;
}

+ (NSURL *)assetURLWithURL:(NSURL *)URL {
    if (!URL) return nil;
    NSString *url = [URL absoluteString];
    if ([url hasPrefix:@"file://"]) return URL;
    NSURL *assetURL = [NSURL URLWithString:[MNMediaResourceLoadRequestErrorScheme stringByAppendingString:[URL absoluteString]]];
    return assetURL;
}

@end
