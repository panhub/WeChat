//
//  MNLaunchImage.m
//  MNKit
//
//  Created by Vicent on 2020/8/4.
//

#import "MNLaunchImage.h"
#import "MNFileManager.h"
#import "MNFileHandle.h"
#import "UIImage+MNHelper.h"
#import "MNUtilities.h"
#import "UIView+MNLayout.h"

@implementation MNLaunchImage

+ (void)exportWithCompletionHandler:(void(^)(NSString *, NSArray <UIImage *>*, NSError *))completionHandler {
    MNLaunchImage *image = MNLaunchImage.new;
    image.backgroundColor = UIColor.whiteColor;
    image.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    image.textColor = UIColor.darkTextColor;
    image.font = [UIFont systemFontOfSize:150.f];
    [image exportWithCompletionHandler:completionHandler];
}

- (void)exportWithCompletionHandler:(void(^)(NSString *, NSArray <UIImage *>*, NSError *))completionHandler {
    NSString *directoryPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LaunchImage"];
    [self exportAtDirectory:directoryPath completionHandler:completionHandler];
}

- (void)exportAtDirectory:(NSString *)directoryPath completionHandler:(void(^)(NSString *, NSArray <UIImage *>*, NSError *))completionHandler {
    
    NSError *error;
    if (![NSFileManager.defaultManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error] || error) {
        if (completionHandler) completionHandler(directoryPath, nil, error);
        return;
    }
    
    if (![MNFileManager removeAllItemsAtPath:directoryPath error:&error] || error) {
        if (completionHandler) completionHandler(directoryPath, nil, error);
        return;
    }
    
    NSMutableArray <UIImage *>*images = @[].mutableCopy;
    NSArray <NSValue *>*sizes = @[[NSValue valueWithCGSize:CGSizeMake(320.f, 480.f)], [NSValue valueWithCGSize:CGSizeMake(640.f, 960.f)], [NSValue valueWithCGSize:CGSizeMake(640.f, 1136.f)], [NSValue valueWithCGSize:CGSizeMake(750.f, 1334.f)], [NSValue valueWithCGSize:CGSizeMake(828.f, 1792.f)], [NSValue valueWithCGSize:CGSizeMake(1125.f, 2436.f)], [NSValue valueWithCGSize:CGSizeMake(1242.f, 2208.f)], [NSValue valueWithCGSize:CGSizeMake(1242.f, 2688.f)]];
    for (NSValue *obj in sizes) {
        CGSize size = obj.CGSizeValue;
        NSString *name = [NSString stringWithFormat:@"%@x%@", @(size.width), @(size.height)];
        NSString *path = [[directoryPath stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"png"];
        
        if ([NSFileManager.defaultManager fileExistsAtPath:path] && (![NSFileManager.defaultManager removeItemAtPath:path error:&error] || error)) break;
        
        UIView *backgroundView = UIView.new;
        backgroundView.frame = (CGRect){CGPointZero, size};
        backgroundView.backgroundColor = self.backgroundColor ? : UIColor.whiteColor;
        
        UILabel *label = [UILabel labelWithFrame:CGRectZero text:self.text ? : @"MNKit" textColor:self.textColor ? : UIColor.darkTextColor font:self.font ? : [UIFont systemFontOfSize:150.f]];
        [label sizeToFit];
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageWithLayer:label.layer]];
        imageView.size_mn = CGSizeMultiplyToWidth(imageView.image.size, backgroundView.width_mn/2.f);
        imageView.center_mn = backgroundView.bounds_center;
        imageView.bottom_mn = backgroundView.height_mn/2.f;
        [backgroundView addSubview:imageView];
        
        UIGraphicsBeginImageContextWithOptions(backgroundView.layer.bounds.size, NO, 1.f);
        [backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (image && [MNFileHandle writeImage:image toFile:path error:&error] && !error) {
            [images addObject:image];
        } else break;
    }
    
    if (images.count != sizes.count || error) {
        [images removeAllObjects];
        [MNFileManager removeAllItemsAtPath:directoryPath error:nil];
        images = nil;
    }
    
    if (completionHandler) {
        completionHandler(directoryPath, images.copy, error);
    }
}

@end
