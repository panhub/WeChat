//
//  MNLoger.h
//  MNKit
//
//  Created by Vincent on 2019/9/21.
//  Copyright © 2019 Vincent. All rights reserved.
//  调试输出管理者

#import <Foundation/Foundation.h>
@class MNLogModel, MNLoger;

NS_ASSUME_NONNULL_BEGIN

@protocol MNLogerDelegate <NSObject>
@required;
- (void)logerDidChageLog:(MNLoger *)logger;
- (void)logerDidCleanLog:(MNLoger *)logger;
@end

@interface MNLoger : NSObject

@property (nonatomic, weak) id<MNLogerDelegate> delegate;

@property (nonatomic, readonly, strong) NSArray <MNLogModel *>*dataSource;

+ (instancetype)logger;

+ (void)startLog;

+ (void)endLog;

+ (void)clearLog;

+ (NSString *)asyncLog:(NSString *)outputString;

- (void)log:(NSString *)outputString;

@end

NS_ASSUME_NONNULL_END
