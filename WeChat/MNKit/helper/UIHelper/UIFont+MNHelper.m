//
//  UIFont+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/12/12.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UIFont+MNHelper.h"
#import "MNExtern.h"
#import "NSObject+MNSwizzle.h"
#import "NSBundle+MNHelper.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

@implementation UIFont (MNHelper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MNSwizzleClassMethod(self, @selector(fontWithName:size:), @selector(mn_fontWithName:size:));
    });
}

+ (UIFont *)mn_fontWithName:(NSString *)fontName size:(CGFloat)fontSize {
    UIFont *font = [self mn_fontWithName:fontName size:fontSize];
    if (font) return font;
    NSString *path = [[MNBundle mainBundle] pathForResource:fontName
                                                     ofType:@"ttf"
                                                inDirectory:MNResourceDirectoryName];
    NSString *fontFullName = [UIFont registFontWithPath:path];
    if (!fontFullName) return [UIFont systemFontOfSize:fontSize];
    return [UIFont mn_fontWithName:(fontFullName.length > 0 ? fontFullName : fontName) size:fontSize];
}

UIFont * UIFontWithNameSize (NSString *fontName, CGFloat fontSize) {
    return [UIFont fontWithName:fontName size:fontSize];
}

#pragma mark - 向系统注册字体
+ (NSString *)registFontWithPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path]);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CFErrorRef errorRef;
    NSString *fontName = nil;
    if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef)) {
        fontName = (__bridge_transfer NSString *)CGFontCopyFullName(fontRef);
        if (!fontName) fontName = @"";
        NSLog(@"regist font \"%@\" done!", fontName);
    } else if (errorRef != NULL) {
        NSError *error = (__bridge_transfer NSError *)errorRef;
        NSLog(@"regist font failed!\n---path: %@ \n---error: %@", path, error.userInfo);
    }
    CGFontRelease(fontRef);
    return fontName;
}

NSString * UIFontRegistAtPath (NSString *path) {
    return [UIFont registFontWithPath:path];
}

#pragma mark - 解决版本限制问题
+ (UIFont *)systemFontOfSizes:(CGFloat)fontSize weights:(UIFontWeight)weight {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 82000
    if (@available(iOS 8.2, *)) {
        return [UIFont systemFontOfSize:fontSize weight:weight];
    }
    return [UIFont systemFontOfSize:fontSize];
#endif
    return [UIFont systemFontOfSize:fontSize];
}

#pragma mark - Equal
- (BOOL)isEqualFont:(UIFont *)font {
    if (!font) return NO;
    if (self.familyName && ![font.familyName isEqualToString:self.familyName]) return NO;
    return (self.pointSize == font.pointSize && [self.fontName isEqualToString:font.fontName]);
}

#pragma mark - Font
UIFont * UIFontSystem (CGFloat fontSize) {
    return [UIFont systemFontOfSize:fontSize];
}

UIFont * UIFontSystemMedium (CGFloat fontSize) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 82000
    if (@available(iOS 8.2, *)) {
        return [UIFont systemFontOfSize:fontSize weight:UIFontWeightMedium];
    }
    return UIFontMedium(fontSize);
#endif
    return UIFontMedium(fontSize);
}

UIFont * UIFontLight (CGFloat fontSize) {
    return [UIFont fontWithName:MNFontNameLight size:fontSize];
}

UIFont * UIFontRegular (CGFloat fontSize) {
    return [UIFont fontWithName:MNFontNameRegular size:fontSize];
}

UIFont * UIFontMedium (CGFloat fontSize) {
    return [UIFont fontWithName:MNFontNameMedium size:fontSize];
}

UIFont * UIFontSemibold (CGFloat fontSize) {
    return [UIFont fontWithName:MNFontNameSemibold size:fontSize];
}

@end
