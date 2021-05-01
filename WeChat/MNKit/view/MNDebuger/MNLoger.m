//
//  MNLoger.m
//  MNKit
//
//  Created by Vincent on 2019/9/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLoger.h"
#import "MNLogModel.h"

@interface MNLoger ()
@property (nonatomic) BOOL allowsLog;
@property (nonatomic) dispatch_semaphore_t semaphore;
@property (nonatomic) dispatch_queue_t dispatch_logger_queue;
@property (nonatomic, strong) NSMutableArray <MNLogModel *>*dataArray;
@end

#define Lock()      dispatch_semaphore_wait(MNLoger.logger.semaphore, DISPATCH_TIME_FOREVER)
#define Unlock()   dispatch_semaphore_signal(MNLoger.logger.semaphore)

static MNLoger *_logger;
@implementation MNLoger

+ (instancetype)logger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_logger) {
            _logger = [MNLoger new];
        }
    });
    return _logger;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logger = [super allocWithZone:zone];
    });
    return _logger;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logger = [super init];
        if (_logger) {
            _logger.allowsLog = NO;
            _logger.semaphore = dispatch_semaphore_create(1);
            _logger.dispatch_logger_queue = dispatch_queue_create("com.mn.logger.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        }
    });
    return _logger;
}

+ (void)startLog {
    MNLoger.logger.allowsLog = YES;
    NSLog(@"MNLoger: 开启调试输出记录");
}

+ (void)endLog {
    NSLog(@"MNLoger: 关闭调试输出记录");
    MNLoger.logger.allowsLog = NO;
}

+ (void)clearLog {
    Lock();
    [[MNLoger logger]->_dataArray removeAllObjects];
    if ([MNLoger.logger.delegate respondsToSelector:@selector(logerDidCleanLog:)]) {
        [MNLoger.logger.delegate logerDidCleanLog:MNLoger.logger];
    }
    Unlock();
}

+ (NSString *)asyncLog:(NSString *)outputString {
    dispatch_async(MNLoger.logger.dispatch_logger_queue, ^{
        [MNLoger.logger log:outputString];
    });
    return outputString;
}

- (void)log:(NSString *)outputString {
    if (!outputString || !self.allowsLog) return;
    Lock();
    [self.dataArray addObject:[MNLogModel modelWithLog:outputString]];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(logerDidChageLog:)]) {
            [self.delegate logerDidChageLog:self];
        }
    });
    Unlock();
}

#pragma mark - Getter
- (NSArray <MNLogModel *>*)dataSource {
    return _dataArray.copy;
}

- (NSMutableArray <MNLogModel *>*)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}

@end
