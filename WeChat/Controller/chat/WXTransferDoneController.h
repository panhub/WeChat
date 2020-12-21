//
//  WXTransferDoneController.h
//  MNChat
//
//  Created by Vincent on 2019/6/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  转账完成

#import "MNExtendViewController.h"
@class WXRedpacket;

NS_ASSUME_NONNULL_BEGIN

@interface WXTransferDoneController : MNExtendViewController
/**
 网络交互
 */
@property (nonatomic) BOOL networking;
/**
 出栈到指定控制器
*/
@property (nonatomic, copy) NSString *cls;


- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket;

@end

NS_ASSUME_NONNULL_END
