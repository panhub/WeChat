//
//  MNSSLPolicy.h
//  MNKit
//
//  Created by Vincent on 2018/11/16.
//  Copyright © 2018年 小斯. All rights reserved.
//  HTTPS SSL验证

#import <Foundation/Foundation.h>

/**
 验证方式
 - MNSSLPinningModeModeNone: 不验证
 - MNSSLPinningModePublicKey: 验证公钥
 - MNSSLPinningModeCertificate: 验证证书
 */
typedef NS_ENUM(NSUInteger, MNSSLPinningMode) {
    MNSSLPinningModeNone,
    MNSSLPinningModePublicKey,
    MNSSLPinningModeCertificate
};

@interface MNSSLPolicy : NSObject
//验证方式
@property (nonatomic, assign) MNSSLPinningMode mode;
//是否支持非法的证书 (例如自签名证书）
@property (nonatomic, assign) BOOL allowInvalidCertificate;
//是否去验证证书域名是否匹配
@property (nonatomic, assign) BOOL validateDomainName;

+ (MNSSLPolicy *)defaultPolicy;

- (instancetype)initWithPinningMode:(MNSSLPinningMode)mode;

/**
 添加证书
 @param paths 证书路径
 */
- (void)addCertificatePath:(NSArray <NSString *>*)paths;

/**
 验证服务端证书是否值得信任
 @param serverTrust 服务端证书信息
 @param domain 服务端domain
 @return 验证结果
 */
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain;

@end

