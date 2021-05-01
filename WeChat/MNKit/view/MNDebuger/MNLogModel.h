//
//  MNLogModel.h
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  打印数据模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNLogModel : NSObject

@property (nonatomic, readonly) CGFloat height;

@property (nonatomic, readonly) CGRect contentRect;

@property (nonatomic, readonly, copy) NSAttributedString *attributedLog;

@property (nonatomic, copy) NSString *log;

+ (instancetype)modelWithLog:(NSString *)log;

@end

NS_ASSUME_NONNULL_END
