//
//  WXExtendViewModel.h
//  WeChat
//
//  Created by Vincent on 2019/6/18.
//  Copyright © 2019 Vincent. All rights reserved.
//  ViewModel扩展模型

#import <Foundation/Foundation.h>

@interface WXExtendViewModel : NSObject
/**
 位置
 */
@property (nonatomic) CGRect frame;
/**
 内容
 */
@property (nonatomic, strong) id content;
/**
 扩展
 */
@property (nonatomic, strong) id extend;
/**
 标记视图
 */
@property (nonatomic, weak) UIView *containerView;

@end

