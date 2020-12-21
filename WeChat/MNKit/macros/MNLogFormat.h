//
//  MNLogFormat.h
//  MNKit
//
//  Created by Vincent on 2018/11/27.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSDate+MNHelper.h"
#ifndef MNLogFormat_h
#define MNLogFormat_h

#ifdef __OBJC__

#if DEBUG

#ifndef NSLog
/*
#define NSLog(args, ...) printf("\n时间: %s\n文件: %s\n方法: %s\n行数: %d\n输出: %s\n", [[[NSDate date] dateString] UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], [[[[[NSString stringWithUTF8String:__FUNCTION__] componentsSeparatedByString:@" "] lastObject] stringByReplacingOccurrencesOfString:@"]" withString:@""] UTF8String], __LINE__, [[NSString stringWithFormat:args, ## __VA_ARGS__] UTF8String])
*/
#define NSLog(args, ...) printf("\n%s\n", [[MNLoger asyncLog:[NSString stringWithFormat:@"时间: %@\n文件: %@\n方法: %@\n行数: %d\n输出: %@", NSDate.date.stringValue, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], [[[[NSString stringWithUTF8String:__FUNCTION__] componentsSeparatedByString:@" "] lastObject] stringByReplacingOccurrencesOfString:@"]" withString:@""], __LINE__, [NSString stringWithFormat:args, ## __VA_ARGS__]]] UTF8String])
#endif

#ifndef MNLog
/*
#define MNLog(args, ...) printf("\n时间: %s\n文件: %s\n方法: %s\n行数: %d\n输出: %s\n", [[[NSDate date] dateString] UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], [[[[[NSString stringWithUTF8String:__FUNCTION__] componentsSeparatedByString:@" "] lastObject] stringByReplacingOccurrencesOfString:@"]" withString:@""] UTF8String], __LINE__, [[NSString stringWithFormat:args, ## __VA_ARGS__] UTF8String])
*/
#define MNLog(args, ...) printf("\n%s\n", [[MNLoger asyncLog:[NSString stringWithFormat:@"时间: %@\n文件: %@\n方法: %@\n行数: %d\n输出: %@", [[NSDate date] dateString], [[NSString stringWithUTF8String:__FILE__] lastPathComponent], [[[[NSString stringWithUTF8String:__FUNCTION__] componentsSeparatedByString:@" "] lastObject] stringByReplacingOccurrencesOfString:@"]" withString:@""], __LINE__, [NSString stringWithFormat:args, ## __VA_ARGS__]]] UTF8String])
#endif

#else

#ifndef NSLog
#define NSLog(...)
#endif

#ifndef MNLog
#define MNLog(...)
#endif

#endif


#ifndef MNDeallocLog
#define MNDeallocLog NSLog(@"***%@ dealloc***",NSStringFromClass([self class]));
#endif

#ifndef CGRectLog
#define CGRectLog(rect) NSLog(@"<%s> x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, (rect).origin.x, (rect).origin.y, (rect).size.width, (rect).size.height)
#endif

#ifndef CGSizeLog
#define CGSizeLog(size) NSLog(@"<%s> w:%.4f, h:%.4f", #size, (size).width, (size).height)
#endif

#ifndef CGPointLog
#define CGPointLog(point) NSLog(@"<%s> x:%.4f, y:%.4f", #point, (point).x, (point).y)
#endif

#ifndef NSStringLog
#define NSStringLog(string) NSLog(@"<%s> %@", #string, string)
#endif

#ifndef RetainCountLog
#define RetainCountLog(obj) NSLog(@"%s retain count = %ld", #obj, CFGetRetainCount((__bridge CFTypeRef)(obj)))
#endif

#endif

#endif /* MNLogFormat_h */
