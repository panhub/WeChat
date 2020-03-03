//
//  MNMediaSeekAction.h
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//  跳转操作

#import <Foundation/Foundation.h>

/**
 跳转的位置
 - MNMediaSeekActionLocal: 本地缓存位置
 - MNMediaSeekActionRemote: 网络资源位置
 */
typedef NS_ENUM(NSUInteger, MNMediaSeekActionType) {
    MNMediaSeekActionLocal = 0,
    MNMediaSeekActionRemote
};

@interface MNMediaSeekAction : NSObject

@property (nonatomic) MNMediaSeekActionType type;
@property (nonatomic) NSRange range;

- (instancetype)initWithType:(MNMediaSeekActionType)type range:(NSRange)range;

- (BOOL)isEqualToAction:(MNMediaSeekAction *)action;

@end
