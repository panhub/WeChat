//
//  MNURLRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLRequest.h"

@interface MNURLRequest ()
@property (nonatomic) BOOL firstLoading;
@property (nonatomic, strong) MNURLResponse *response;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

@implementation MNURLRequest
- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self initialized];
    return self;
}

- (instancetype)initWithUrl:(NSString *)url {
    self = [self init];
    if (!self) return nil;
    self.url = url;
    return self;
}

- (void)initialized {
    self.firstLoading = YES;
    self.timeoutInterval = 15.f;
    self.allowsCancelCallback = NO;
    self.allowsCellularAccess = YES;
    self.allowsNetworkActivity = YES;
    self.JSONReadingOptions = kNilOptions;
    self.stringWritingEncoding = NSUTF8StringEncoding;
    self.stringReadingEncoding = NSUTF8StringEncoding;
    self.serializationType = MNURLRequestSerializationTypeJSON;
    self.acceptableStatus = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
}

- (BOOL)resume {
    if (self.isLoading) return YES;
    return [[MNURLSessionManager defaultManager] resumeRequest:self];
}

- (void)cancel {
    if (!self.isLoading) return;
    [[MNURLSessionManager defaultManager] cancelRequest:self];
}

- (void)cleanCallback {
    self.startCallback = nil;
    self.finishCallback = nil;
    self.progressCallback = nil;
}

#pragma mark - MNHTTPProtocol
- (void)didFinishWithResponseObject:(id)responseObject error:(NSError *)error {}
- (void)didFinishWithSupposedResponse:(MNURLResponse *)response {}
- (void)didSucceedWithResponseObject:(id)responseObject {}

#pragma mark - Setter
- (void)setUrl:(NSString *)url {
    if (url) {
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    _url = url.copy;
}

- (void)setValue:(NSString *)value forQuery:(NSString *)query {
    if (self.isLoading || !query || query.length <= 0) return;
    if (!self.query) {
        if (value) self.query = @{query:value};
    } else if ([self.query isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *dic = ((NSDictionary *)self.query).mutableCopy;
        if (value) {
            [dic setObject:value forKey:query];
        } else {
            [dic removeObjectForKey:query];
        }
        self.query = dic.copy;
    }
}

- (void)setValue:(NSString *)value forBody:(NSString *)body {
    if (self.isLoading || !body || body.length <= 0) return;
    if (!self.body) {
        if (value) self.body = @{body:value};
    } else if ([self.body isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *dic = ((NSDictionary *)self.body).mutableCopy;
        if (value) {
            [dic setObject:value forKey:body];
        } else {
            [dic removeObjectForKey:body];
        }
        self.body = dic.copy;
    }
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (self.isLoading || !field || field.length <= 0) return;
    if (!self.headerFields) {
        if (value) self.headerFields = @{field:value};
    } else {
        NSMutableDictionary *dic = self.headerFields.mutableCopy;
        if (value) {
            [dic setObject:value forKey:field];
        } else {
            [dic removeObjectForKey:field];
        }
        self.headerFields = dic.copy;
    }
}

- (void)setAuthorizedUsername:(nullable NSString *)username password:(nullable NSString *)password {
    if (!username || username.length <= 0 || !password || password.length <= 0) {
        if (self.authHeader) self.authHeader = nil;
    } else {
        self.authHeader = @{username:password};
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"⚠️⚠️⚠️⚠️ %@ undefined key:%@ ⚠️⚠️⚠️⚠️", NSStringFromClass(self.class), key);
}

#pragma mark - Getter
- (BOOL)isLoading {
    return (_task && _task.state == NSURLSessionTaskStateRunning);
}

- (BOOL)isSucceed {
    return (_response &&_response.code == MNURLResponseCodeSucceed);
}

- (NSString *)debugDescription {
    return self.url ? : [super debugDescription];
}

#pragma mark - dealloc
- (void)dealloc {
    self.task = nil;
    self.response = nil;
    self.startCallback = nil;
    self.finishCallback = nil;
    self.progressCallback = nil;
    NSLog(@"===dealloc===%@", NSStringFromClass(self.class));
}

@end
