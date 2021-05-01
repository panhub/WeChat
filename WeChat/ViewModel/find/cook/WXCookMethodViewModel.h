//
//  WXCookMethodViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXCookMethod;

@interface WXCookMethodViewModel : NSObject
/**
 数据模型
 */
@property (nonatomic, strong) WXCookMethod *model;
/**
 图片位置
 */
@property (nonatomic, assign) CGRect imageViewFrame;
/**
 图片网址
 */
@property (nonatomic, copy) NSString *img;
/**
 文字描述位置
 */
@property (nonatomic, assign) CGRect textLabelFrame;
/**
 文字描述富文本
 */
@property (nonatomic, strong) NSAttributedString *attributedString;
/**
 高度
 */
@property (nonatomic, assign) CGFloat height;

/**
 实例化入口
 @param model 数据模型
 @return 视图模型
 */
- (instancetype)initWithMethod:(WXCookMethod *)model;

@end

