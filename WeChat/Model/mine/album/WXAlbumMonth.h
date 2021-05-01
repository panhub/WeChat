//
//  WXAlbumMonth.h
//  WeChat
//
//  Created by Vicent on 2021/4/9.
//  Copyright © 2021 Vincent. All rights reserved.
//  月

#import <Foundation/Foundation.h>
#import "WXProfile.h"

NS_ASSUME_NONNULL_BEGIN

@interface WXAlbumMonth : NSObject

/**标题*/
@property (nonatomic, copy) NSString *title;

/**月份*/
@property (nonatomic, copy) NSString *month;

/**图片集合*/
@property (nonatomic, strong) NSMutableArray <WXProfile *>*pictures;

@end

NS_ASSUME_NONNULL_END
