//
//  MNTrustPolicy.h
//  MNKit
//
//  Created by Vincent on 2018/11/16.
//  Copyright © 2018年 小斯. All rights reserved.
//  HTTPS SSL信任评估

#import <Foundation/Foundation.h>

/**
 验证方式
 - MNTrustModeModeNone: 不验证
 - MNTrustModePublicKey: 验证公钥
 - MNTrustModeCertificate: 验证证书
 */
typedef NS_ENUM(NSUInteger, MNTrustMode) {
    MNTrustModeNone,
    MNTrustModePublicKey,
    MNTrustModeCertificate
};

NS_ASSUME_NONNULL_BEGIN

@interface MNTrustPolicy : NSObject<NSCopying>
// 验证方式
@property (nonatomic, readonly) MNTrustMode mode;
// 是否验证域名
@property (nonatomic, getter=isValidatesDomainName) BOOL validatesDomainName;
// 是否支持非法证书 (例如自签名证书) 默认NO, 不建议开启
@property (nonatomic, getter=isAllowsInvalidCertificate) BOOL allowsInvalidCertificate;
// 设置本地锚点证书
@property (nonatomic, copy, nullable) NSSet <NSData *> *certificates;
/**
 提供默认的验证方案
 该方案验证域名, 不针对本地证书校验
 */
@property (nonatomic, readonly, class) MNTrustPolicy *defaultPolicy;

/**
 自定义校验方式
 @param mode 校验方式
 @return SSL校验方案
 */
+ (instancetype)policyWithMode:(MNTrustMode)mode;

/**
 自定义校验方式
 @param mode 校验方式
 @param certificates 证书集合
 @return SSL校验方案
 */
+ (instancetype)policyWithMode:(MNTrustMode)mode certificates:(NSSet <NSData *> *_Nullable)certificates;

/**
 验证服务端证书
 @param serverTrust 服务端证书信息
 @return 验证结果
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust;

/**
 验证服务端证书
 @param serverTrust 服务端证书信息
 @param domain 指定域名
 @return 验证结果
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *_Nullable)domain;

/**
 获取资源束下证书集合
 @param bundle 资源束
 @return 证书集合
 */
+ (NSSet <NSData *> *_Nullable)certificatesInBundle:(NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END
