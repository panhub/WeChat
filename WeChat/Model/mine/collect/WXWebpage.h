//
//  WXWebpage.h
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  收藏网页模型

#import <Foundation/Foundation.h>

@interface WXWebpage : NSObject <NSSecureCoding>
/**链接*/
@property (nonatomic, copy) NSString *url;
/**标题*/
@property (nonatomic, copy) NSString *title;
/**时间*/
@property (nonatomic, copy) NSString *date;
/**图片数据*/
@property (nonatomic, strong) NSData *thumbnailData;
/**缩略图*/
@property (nonatomic, readonly, strong) UIImage *thumbnail;

/**
 根据公共沙盒区数据实例化
 @param dic 沙盒数据
 @return 网页模型
 */
+ (instancetype)webpageWithSandbox:(NSDictionary *)dic;

@end
