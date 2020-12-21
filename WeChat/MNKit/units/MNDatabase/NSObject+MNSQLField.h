//
//  NSObject+MNSQLField.h
//  MNKit
//
//  Created by Vicent on 2020/6/24.
//  Copyright © 2020 Vincent. All rights reserved.
//  表字段定制

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MNSQLField)

/**
 定制数据库表字段
 @return 数据库表字段<字段名,对应类型>
 */
+ (NSDictionary <NSString *, NSString *>*_Nullable)sqliteTableFields;

@end

NS_ASSUME_NONNULL_END
