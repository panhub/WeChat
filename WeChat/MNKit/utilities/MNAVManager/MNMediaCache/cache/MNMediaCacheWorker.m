//
//  MNMediaCacheWorker.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMediaCacheWorker.h"
#import "MNMediaCacheManager.h"

@interface MNMediaCacheWorker ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) NSFileHandle *readFileHandle;
@property (nonatomic, strong) NSFileHandle *writeFileHandle;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) MNMediaCacheConfiguration *configuration;
@property (nonatomic) long long currentOffset;
@property (nonatomic, strong) NSDate *startWriteDate;
@property (nonatomic) float writeBytes;
@property (nonatomic) BOOL writting;
@end

static NSInteger const kMNMediaPackageLength = 204800; // 200kb per package

@implementation MNMediaCacheWorker
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self save];
    [_readFileHandle closeFile];
    [_writeFileHandle closeFile];
}

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    if (!self) return nil;
    NSString *filePath = [MNMediaCacheManager cacheFilePathForURL:URL];
    self.filePath = filePath;
    NSError *error;
    NSString *cacheFolder = [filePath stringByDeletingLastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
        [fileManager createDirectoryAtPath:cacheFolder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    if (!error) {
        if (![fileManager fileExistsAtPath:filePath]) {
            [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        _readFileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
        if (!error) {
            _writeFileHandle = [NSFileHandle fileHandleForWritingToURL:fileURL error:&error];
            _configuration = [MNMediaCacheConfiguration configurationWithFilePath:filePath];
            _configuration.URL = URL;
        }
    }
    self.error = error;
    return self;
}

- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error {
    @synchronized(self.writeFileHandle) {
        @try {
            [self.writeFileHandle seekToFileOffset:range.location];
            [self.writeFileHandle writeData:data];
            self.writeBytes += data.length;
            [self.configuration addCacheFragment:range];
        } @catch (NSException *exception) {
            NSLog(@"write to file error");
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
    }
}

- (NSData *)cacheDataForRange:(NSRange)range error:(NSError **)error {
    @synchronized(self.readFileHandle) {
        @try {
            [self.readFileHandle seekToFileOffset:range.location];
            NSData *data = [self.readFileHandle readDataOfLength:range.length];
            return data;
        } @catch (NSException *exception) {
            NSLog(@"read cached data error %@",exception);
            *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
        }
    }
    return nil;
}

- (NSArray<MNMediaSeekAction *> *)cacheDataActionForRange:(NSRange)range {
    NSArray <NSValue *>*cacheFragments = [self.configuration cacheFragments];
    NSMutableArray <MNMediaSeekAction *>*actions = [NSMutableArray array];
    if (range.location == NSNotFound) return [actions copy];
    
    NSInteger endOffset = range.location + range.length;
    
    [cacheFragments enumerateObjectsUsingBlock:^(NSValue * _Nonnull value, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange fragmentRange = value.rangeValue;
        NSRange intersectionRange = NSIntersectionRange(range, fragmentRange);
        if (intersectionRange.length > 0) {
            NSInteger package = intersectionRange.length/kMNMediaPackageLength;
            for (NSInteger i = 0; i <= package; i++) {
                MNMediaSeekAction *action = [MNMediaSeekAction new];
                action.type = MNMediaSeekActionLocal;
                
                NSInteger offset = i * kMNMediaPackageLength;
                NSInteger offsetLocation = intersectionRange.location + offset;
                NSInteger maxLocation = intersectionRange.location + intersectionRange.length;
                NSInteger length = (offsetLocation + kMNMediaPackageLength) > maxLocation ? (maxLocation - offsetLocation) : kMNMediaPackageLength;
                action.range = NSMakeRange(offsetLocation, length);
                
                [actions addObject:action];
            }
        } else if (fragmentRange.location >= endOffset) {
            *stop = YES;
        }
    }];
    
    if (actions.count == 0) {
        MNMediaSeekAction *action = [MNMediaSeekAction new];
        action.type = MNMediaSeekActionRemote;
        action.range = range;
        [actions addObject:action];
    } else {
        NSMutableArray <MNMediaSeekAction *>*localRemoteActions = [NSMutableArray array];
        [actions enumerateObjectsUsingBlock:^(MNMediaSeekAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange actionRange = obj.range;
            if (idx == 0) {
                if (range.location < actionRange.location) {
                    MNMediaSeekAction *action = [MNMediaSeekAction new];
                    action.type = MNMediaSeekActionRemote;
                    action.range = NSMakeRange(range.location, actionRange.location - range.location);
                    [localRemoteActions addObject:action];
                }
                [localRemoteActions addObject:obj];
            } else {
                MNMediaSeekAction *lastAction = [localRemoteActions lastObject];
                NSInteger lastOffset = lastAction.range.location + lastAction.range.length;
                if (actionRange.location > lastOffset) {
                    MNMediaSeekAction *action = [MNMediaSeekAction new];
                    action.type = MNMediaSeekActionRemote;
                    action.range = NSMakeRange(lastOffset, actionRange.location - lastOffset);
                    [localRemoteActions addObject:action];
                }
                [localRemoteActions addObject:obj];
            }
            
            if (idx == actions.count - 1) {
                NSInteger localEndOffset = actionRange.location + actionRange.length;
                if (endOffset > localEndOffset) {
                    MNMediaSeekAction *action = [MNMediaSeekAction new];
                    action.type = MNMediaSeekActionRemote;
                    action.range = NSMakeRange(localEndOffset, endOffset - localEndOffset);
                    [localRemoteActions addObject:action];
                }
            }
        }];
        
        actions = localRemoteActions;
    }
    return [actions copy];
}

- (void)setMediaInfo:(MNMediaInfo *)mediaInfo error:(NSError **)error {
    self.configuration.mediaInfo = mediaInfo;
    @try {
        [self.writeFileHandle truncateFileAtOffset:mediaInfo.contentLength];
        [self.writeFileHandle synchronizeFile];
    } @catch (NSException *exception) {
        NSLog(@"read cached data error %@", exception);
        *error = [NSError errorWithDomain:exception.name code:123 userInfo:@{NSLocalizedDescriptionKey: exception.reason, @"exception": exception}];
    }
}

- (void)save {
    @synchronized (self.writeFileHandle) {
        [self.writeFileHandle synchronizeFile];
        [self.configuration save];
    }
}

- (void)startWritting {
    if (!self.writting) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    self.writting = YES;
    self.startWriteDate = [NSDate date];
    self.writeBytes = 0;
}

- (void)finishWritting {
    if (self.writting) {
        self.writting = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:self.startWriteDate];
        [self.configuration addDownloadBytes:self.writeBytes spent:time];
    }
}

#pragma mark - Notification

- (void)didEnterBackground:(NSNotification *)notification {
    [self save];
}


@end
