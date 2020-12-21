//
//  WXLyric.h
//  MNChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXLyric : NSObject
/**开始时间*/
@property (nonatomic) float begin;
/**结束时间*/
@property (nonatomic) float end;
/**内容*/
@property (nonatomic, copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
