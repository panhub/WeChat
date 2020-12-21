//
//  MNJPEG.m
//  MNKit
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNJPEG.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define MNJPEGMakeNoteIdentifier    @"17"

@implementation MNJPEG
- (instancetype)initWithData:(NSData *)imageData {
    if (!imageData) return nil;
    self = [super init];
    if (!self) return nil;
    self.imageData = imageData;
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithData:UIImageJPEGRepresentation(image, 1.f)];
}

- (instancetype)initWithContentsOfFile:(NSString *)filePath {
    return [self initWithData:[NSData dataWithContentsOfFile:filePath]];
}

- (BOOL)writeToFile:(NSString *)filePath withIdentifier:(NSString *)identifier {
    if (!self.imageData || filePath.length <= 0 || identifier.length <= 0) return NO;
    
    if (![NSFileManager.defaultManager createDirectoryAtPath:filePath.stringByDeletingLastPathComponent withIntermediateDirectories:YES attributes:nil error:nil]) return NO;
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(self.imageData), nil);
    if (!imageSource) return NO;
    
    NSMutableDictionary *metadata = [CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)) mutableCopy];
    if (!metadata) return NO;
    [metadata setObject:@{MNJPEGMakeNoteIdentifier: identifier} forKey:(__bridge NSString *)kCGImagePropertyMakerAppleDictionary];
    
    CGImageDestinationRef ref = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath], kUTTypeJPEG, 1, nil);
    if (!ref) return NO;
    
    CGImageDestinationAddImageFromSource(ref, imageSource, 0, (__bridge CFDictionaryRef)(metadata.copy));
    CFRelease(imageSource);
    CGImageDestinationFinalize(ref);
    return YES;
}

@end
