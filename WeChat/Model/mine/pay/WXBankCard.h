//
//  WXBankCard.h
//  WeChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信银行卡

#import <Foundation/Foundation.h>

/**
 银行卡类型
 - WXBankCardTypeDeposit: 储蓄卡
 - WXBankCardTypeCredit: 信用卡
 */
typedef NS_ENUM(NSInteger, WXBankCardType) {
    WXBankCardTypeDeposit = 0,
    WXBankCardTypeCredit
};

@interface WXBankCard : NSObject
/**
 卡名
 */
@property (nonatomic, copy) NSString *name;
/**
 卡号
 */
@property (nonatomic, copy) NSString *number;
/**
 余额
 */
@property (nonatomic, assign) CGFloat money;
/**
 银行图标
 */
@property (nonatomic, copy) NSString *img;
/**
 水印
 */
@property (nonatomic, copy) NSString *watermark;
/**
 银行卡类型
 */
@property (nonatomic, assign) WXBankCardType type;

#pragma mark - Getter
/**
 信用卡/储蓄卡
 */
@property (nonatomic, readonly, copy) NSString *desc;
/**
 银行图标
 */
@property (nonatomic, readonly, strong) UIImage *icon;

#pragma mark - Method
/**
 判断银行卡是否有效
 @return 银行卡是否有效
 */
- (BOOL)isValid;

@end

