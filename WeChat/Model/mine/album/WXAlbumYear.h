//
//  WXAlbumYear.h
//  WeChat
//
//  Created by Vicent on 2021/4/9.
//  Copyright © 2021 Vincent. All rights reserved.
//  年

#import <Foundation/Foundation.h>
#import "WXAlbumMonth.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXAlbumYear : NSObject

/**标题*/
@property (nonatomic, copy) NSString *title;

/**年份*/
@property (nonatomic, copy) NSString *year;

/**月模型集合*/
@property (nonatomic, strong) NSMutableArray <WXAlbumMonth *>*month;

/**
 依据年实例化模型
 */
- (instancetype)initWithYear:(NSString *)year;

@end

NS_ASSUME_NONNULL_END
