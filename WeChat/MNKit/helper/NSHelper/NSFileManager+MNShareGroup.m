//
//  NSFileManager+MNShareGroup.m
//  MNKit
//
//  Created by Vicent on 2020/11/19.
//

#import "NSFileManager+MNShareGroup.h"

@implementation NSFileManager (MNShareGroup)

+ (NSString *)directoryWithGroup:(NSString *)suitename {
    if (!suitename || suitename.length <= 0) return nil;
    NSURL *URL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:suitename];
    return URL.absoluteString;
}

+ (NSString *)libraryWithGroup:(NSString *)suitename {
    return [[self directoryWithGroup:suitename] stringByAppendingPathComponent:@"Library"];
}

+ (NSString *)cacheWithGroup:(NSString *)suitename {
    return [[self directoryWithGroup:suitename] stringByAppendingPathComponent:@"Library/Caches"];
}

+ (BOOL)writeObject:(id)value fileName:(NSString *)filename withGroup:(NSString *)suitename {
    if (!value || !filename || filename.length <= 0) return NO;
    NSString *filePath = [self cacheWithGroup:suitename];
    if (!filePath || filePath.length <= 0) return NO;
    filePath = [filePath stringByAppendingPathComponent:filename];
    return [value writeToFile:filePath options:NSDataWritingAtomic error:nil];
}

+ (NSData *)dataWithFileName:(NSString *)filename withGroup:(NSString *)suitename {
    if (!filename || filename.length <= 0) return nil;
    NSString *filePath = [self cacheWithGroup:suitename];
    if (!filePath || filePath.length <= 0) return nil;
    filePath = [filePath stringByAppendingPathComponent:filename];
    return [NSData dataWithContentsOfFile:filePath];
}

+ (NSString *)stringWithFileName:(NSString *)filename withGroup:(NSString *)suitename {
    return [self stringWithFileName:filename withGroup:suitename encoding:NSUTF8StringEncoding];
}

+ (NSString *)stringWithFileName:(NSString *)filename withGroup:(NSString *)suitename encoding:(NSStringEncoding)encoding {
    NSData *data = [self dataWithFileName:filename withGroup:suitename];
    if (!data || data.length <= 0) return nil;
    return [[NSString alloc] initWithData:data encoding:encoding];
}

//+ (BOOL)createDirectoryAtPath:(NSString *)path withGroup:(NSString *)suitename error:(NSError **)error {
//    
//}

@end
