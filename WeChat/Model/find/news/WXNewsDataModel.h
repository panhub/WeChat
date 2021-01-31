//
//  WXNewsDataModel.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsDataModel : NSObject

/**标题*/
@property (nonatomic, copy) NSString *title;

/**时间*/
@property (nonatomic, copy) NSString *date;

/**类型*/
@property (nonatomic, copy) NSString *category;

/**作者*/
@property (nonatomic, copy) NSString *author;

/**链接*/
@property (nonatomic, copy) NSString *url;

/**图片*/
@property (nonatomic, copy) NSArray <NSString *>*imgs;

/**
 依据字典创建新闻数据模型
 */
+ (WXNewsDataModel *)modelWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
