//
//  WXDataValueModel.h
//  MNChat
//
//  Created by Vincent on 2019/3/22.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信用户信息列表模型

#import <Foundation/Foundation.h>

@interface WXDataValueModel : NSObject
/**
 类型标题
 */
@property (nonatomic, copy) NSString *title;
/**
 默认值
 */
@property (nonatomic, strong) id value;
/**
 描述
 */
@property (nonatomic, copy) NSString *desc;
/**
 图片<有的话>
 */
@property (nonatomic, copy) NSString *img;
/**
 预留传值
 */
@property (nonatomic, strong) id userInfo;

@end
