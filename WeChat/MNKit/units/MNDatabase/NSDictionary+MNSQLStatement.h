//
//  NSDictionary+MNSQLStatement.h
//  MNKit
//
//  Created by Vicent on 2020/6/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (MNSQLStatement)

/**以SQL语句输出*/
@property (nonatomic, readonly) NSString *sqliteStatement;

@end

NS_ASSUME_NONNULL_END
