//
//  PHAsset+MNAssetResource.m
//  MNKit
//
//  Created by Vicent on 2020/11/10.
//

#import "PHAsset+MNAssetResource.h"
#if __has_include(<Photos/PHAssetResource.h>)
#import <Photos/PHAssetResource.h>

@implementation PHAsset (MNAssetResource)
- (CGSize)pixelSize {
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (BOOL)isHEIF {
    __block BOOL isHEIF = NO;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        NSArray <PHAssetResource *>*resources = [PHAssetResource assetResourcesForAsset:self];
        [resources enumerateObjectsUsingBlock:^(PHAssetResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *UTI = obj.uniformTypeIdentifier.lowercaseString;
            if (UTI && ([UTI containsString:@"public.heif"] || [UTI containsString:@"public.heic"])) {
                isHEIF = YES;
                *stop = YES;
            }
        }];
    } else {
        NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
        isHEIF = (UTI && ([UTI containsString:@"public.heif"] || [UTI containsString:@"public.heic"]));
    }
#else
    NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
    isHEIF = (UTI && ([UTI containsString:@"public.heif"] || [UTI containsString:@"public.heic"]));
#endif
    return isHEIF;
}

- (BOOL)isGIF {
    __block BOOL isGIF = NO;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        NSArray <PHAssetResource *>*resources = [PHAssetResource assetResourcesForAsset:self];
        [resources enumerateObjectsUsingBlock:^(PHAssetResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *UTI = obj.uniformTypeIdentifier.lowercaseString;
            if (UTI && [UTI containsString:@"public.gif"]) {
                isGIF = YES;
                *stop = YES;
            }
        }];
    } else {
        NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
        isGIF = (UTI && [UTI containsString:@"public.gif"]);
    }
#else
    NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
    isGIF = (UTI && [UTI containsString:@"public.gif"]);
#endif
    return isGIF;
}

@end
#endif
