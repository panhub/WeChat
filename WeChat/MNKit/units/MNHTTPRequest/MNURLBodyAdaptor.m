//
//  MNURLBodyAdaptor.m
//  MNKit
//
//  Created by Vicent on 2020/8/20.
//

#import "MNURLBodyAdaptor.h"

NSString * const MNURLBodyBoundaryName = @"com.mn.url.data.boundary";

NSString *MNContentTypeFromPathExtension(NSString *extension) {
    if (!extension || extension.length <= 0) return @"application/octet-stream";
#ifdef __UTTYPE__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunicode-whitespace"
    NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
    if (!contentType) contentType = @"application/octet-stream";
    return contentType;
#pragma clang diagnostic pop
#else
    return @"application/octet-stream";
#endif
}

@interface MNURLBodyAdaptor ()
@property (nonatomic, getter=isEnding) BOOL ending;
@property (nonatomic, strong) NSMutableData *mutableData;
@end

@implementation MNURLBodyAdaptor
- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableData = NSMutableData.data;
        self.stringEncoding = NSUTF8StringEncoding;
    }
    return self;
}

- (instancetype)initWithBoundary:(NSString *)boundaryName {
    if (self = [self init]) {
        self.boundary = boundaryName;
    }
    return self;
}

#pragma mark - 拼接数据
- (BOOL)appendString:(NSString *)string forKey:(NSString *)key {
    if (!string || key.length <= 0) return NO;
    NSMutableString *mutableString = NSMutableString.string;
    [mutableString appendFormat:@"--%@\r\n", self.boundary];
    [mutableString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
    [mutableString appendString:@"\r\n"];
    [mutableString appendString:string];
    [mutableString appendString:@"\r\n"];
    [self.mutableData appendData:[mutableString.copy dataUsingEncoding:self.stringEncoding]];
    return YES;
}

- (BOOL)appendImage:(UIImage *)image forKey:(NSString *)key filename:(NSString *)filename {
    if (!image || key.length <= 0 || filename.length <= 0) return NO;
    if (filename.pathExtension.length <= 0) filename = [filename stringByAppendingPathExtension:@"png"];
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData || imageData.length <= 0) {
        imageData = UIImageJPEGRepresentation(image, 1.f);
        if (imageData && imageData.length && [filename hasSuffix:@"png"]) {
            filename = [filename.stringByDeletingPathExtension stringByAppendingPathExtension:@"jpg"];
        }
    }
    if (!imageData || imageData.length <= 0) return NO;
    return [self appendData:imageData forKey:key filename:filename];
}

- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key {
    return [self appendFileAtPath:filePath forKey:key filename:nil];
}

- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key filename:(NSString *)filename {
    return [self appendFileAtPath:filePath forKey:key filename:filename type:nil];
}

- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key filename:(NSString *)filename type:(NSString *)mimeType {
    if (!filePath || ![NSFileManager.defaultManager fileExistsAtPath:filePath]) return NO;
    if (!filename || filename.length <= 0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 没有文件名 则选择 lastPathComponent 并编码避免出现中文;
        if ([@"" respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEncodingWithAllowedCharacters:")]) {
            filename = [filePath.lastPathComponent stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        } else if ([@"" respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEscapesUsingEncoding:")]) {
            filename = [filePath.lastPathComponent stringByAddingPercentEscapesUsingEncoding:self.stringEncoding];
        } else {
            filename = filePath.lastPathComponent;
        }
#pragma clang diagnostic pop
    } else if (filename.pathExtension.length <= 0) {
        filename = [filename stringByAppendingPathExtension:filePath.pathExtension];
    }
    return [self appendData:[NSData dataWithContentsOfFile:filePath] forKey:key filename:filename type:mimeType];
}

- (BOOL)appendFileWithURL:(NSURL *)fileURL forKey:(NSString *)key filename:(NSString *)filename type:(NSString *)mimeType {
    return [self appendFileAtPath:fileURL.path forKey:key filename:filename type:mimeType];
}

- (BOOL)appendData:(NSData *)data forKey:(NSString *)key filename:(NSString *)filename {
    return [self appendData:data forKey:key filename:filename type:nil];
}

- (BOOL)appendData:(NSData *)data forKey:(NSString *)key filename:(NSString *)filename type:(NSString *)mimeType {
    if (!data || data.length <= 0 || key.length <= 0 || filename.length <= 0) return NO;
    if (!mimeType) mimeType = MNContentTypeFromPathExtension(filename.pathExtension);
    NSMutableString *mutableString = NSMutableString.string;
    [mutableString appendFormat:@"--%@\r\n", self.boundary];
    [mutableString appendFormat:@"Content-Disposition:form-data; name=\"%@\"; filename=\"%@\"\r\n", key, filename];
    [mutableString appendFormat:@"Cotent-Type: %@\r\n", mimeType];
    [mutableString appendString:@"\r\n"];
    [self.mutableData appendData:[mutableString.copy dataUsingEncoding:self.stringEncoding]];
    [self.mutableData appendData:data];
    [self.mutableData appendData:[@"\r\n" dataUsingEncoding:self.stringEncoding]];
    return YES;
}

- (BOOL)appendDataUsingDictionary:(NSDictionary <NSString *, id>*)dictionary {
    if (!dictionary || dictionary.count <= 0) return NO;
    __block BOOL result = YES;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        if (result == NO) {
            *stop = YES;
            return;
        }
        if ([obj isKindOfClass:NSURL.class]) {
            if (![self appendFileAtPath:((NSURL *)obj).path forKey:key]) result = NO;
        } else if ([obj isKindOfClass:NSString.class]) {
            if (![self appendString:(NSString *)obj forKey:key]) result = NO;
        }
    }];
    return result;
}

#pragma mark - Method
- (void)beginAdapting {
    self.ending = NO;
    [self.mutableData setData:NSData.data];
}

- (void)endAdapting {
    if (self.isEnding || self.mutableData.length <= 0) return;
    self.ending = YES;
    [self.mutableData appendData:[[NSString stringWithFormat:@"--%@--\r\n", self.boundary] dataUsingEncoding:self.stringEncoding]];
}

#pragma mark - Getter
- (NSString *)boundary {
    if (!_boundary) return MNURLBodyBoundaryName;
    return _boundary;
}

- (NSData *)data {
    return self.mutableData.length > 0 ? self.mutableData.copy : nil;
}

@end
