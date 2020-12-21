//
//  PHAsset+MNAssetResource.m
//  MNKit
//
//  Created by Vicent on 2020/11/10.
//

#import "PHAsset+MNAssetResource.h"

@implementation PHAsset (MNAssetResource)
- (CGSize)pixelSize {
    return CGSizeMake(self.pixelWidth, self.pixelHeight);
}

- (BOOL)isHEIFAsset {
    __block BOOL isHEIF = NO;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        NSArray <PHAssetResource *>*resources = [PHAssetResource assetResourcesForAsset:self];
        [resources enumerateObjectsUsingBlock:^(PHAssetResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *UTI = obj.uniformTypeIdentifier.lowercaseString;
            if (UTI && ([UTI containsString:@"heif"] || [UTI containsString:@"heic"])) {
                isHEIF = YES;
                *stop = YES;
            }
        }];
    } else {
        NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
        isHEIF = (UTI && ([UTI containsString:@"heif"] || [UTI containsString:@"heic"]));
    }
#else
    NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
    isHEIF = (UTI && ([UTI containsString:@"heif"] || [UTI containsString:@"heic"]));
#endif
    return isHEIF;
}

- (BOOL)isGIFAsset {
    __block BOOL isGIF = NO;
#ifdef __IPHONE_9_0
    if (@available(iOS 9.0, *)) {
        NSArray <PHAssetResource *>*resources = [PHAssetResource assetResourcesForAsset:self];
        [resources enumerateObjectsUsingBlock:^(PHAssetResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *UTI = obj.uniformTypeIdentifier.lowercaseString;
            if (UTI && [UTI containsString:@"gif"]) {
                isGIF = YES;
                *stop = YES;
            }
        }];
    } else {
        NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
        isGIF = (UTI && [UTI containsString:@"gif"]);
    }
#else
    NSString *UTI = [(NSString *)[self valueForKey:@"uniformTypeIdentifier"] lowercaseString];
    isGIF = (UTI && [UTI containsString:@"gif"]);
#endif
    return isGIF;
}

@end
