//
//  MNURLRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/18.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLRequest.h"

@interface MNURLRequest ()
@property (nonatomic, assign) BOOL firstLoading;
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
    self.timeoutInterval = 10.f;
    self.allowsCellularAccess = YES;
    self.allowsNetworkActivity = YES;
    self.serializationType = MNURLRequestSerializationJSON;
}

- (void)setUrl:(NSString *)url {
    _url = [url.copy stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSURLSessionTaskState)state {
    return _task.state;
}

- (BOOL)isLoading {
    return (_task && _task.state == NSURLSessionTaskStateRunning);
}

- (BOOL)isSucceed {
    return (_response &&_response.code == MNURLResponseCodeSucceed);
}

- (void)didLoadFinishWithResponseObject:(id)responseObject error:(NSError *)error {}

- (void)didLoadFinishWithResponse:(MNURLResponse *)response {}

- (void)didLoadSucceedWithResponseObject:(id)responseObject {}

- (void)suspend {}

- (void)resume {}

- (void)cancel {}

- (void)cleanCallback {
    self.startCallback = nil;
    self.finishCallback = nil;
    self.progressCallback = nil;
    self.didLoadSucceedCallback = nil;
    self.didLoadFinishCallback = nil;
    self.confirmResponseCallback = nil;
}

- (void)dealloc {
    self.task = nil;
    self.response = nil;
    self.startCallback = nil;
    self.finishCallback = nil;
    self.progressCallback = nil;
    self.didLoadFinishCallback = nil;
    self.didLoadSucceedCallback = nil;
    self.confirmResponseCallback = nil;
    MNDeallocLog;
}

@end
