//
//  MNTrustPolicy.m
//  MNKit
//
//  Created by Vincent on 2018/11/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNTrustPolicy.h"
#import <AssertMacros.h>

/**比较秘钥是否相同*/
static BOOL MNSecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
    return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
    return [MNSecKeyGetData(key1) isEqual:MNSecKeyGetData(key2)];
#endif
}

#if !TARGET_OS_IOS && !TARGET_OS_WATCH && !TARGET_OS_TV
static NSData * MNSecKeyGetData(SecKeyRef key) {
    CFDataRef data = NULL;
    __Require_noErr_Quiet(SecItemExport(key, kSecFormatUnknown, kSecItemPemArmour, NULL, &data), _out);
    return (__bridge_transfer NSData *)data;
_out:
    if (data) {
        CFRelease(data);
    }
    return nil;
}
#endif

/**获取证书里的公钥*/
static id MNPublicKeyForCertificate(NSData *certificateData) {
    id publicKey = nil; // 公钥数据
    SecCertificateRef certificate; // 证书对象
    SecPolicyRef policy = nil; // 验证策略
    SecTrustRef trust = nil; // 信任对象
    SecTrustResultType result; // 校验结果
    
    certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
    __Require_Quiet(certificate != NULL, _out);
    
    policy = SecPolicyCreateBasicX509();
    __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificate, policy, &trust), _out);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __Require_noErr_Quiet(SecTrustEvaluate(trust, &result), _out);
#pragma clang diagnostic pop
    
    publicKey = (__bridge_transfer id)SecTrustCopyPublicKey(trust);
    
_out:
    if (trust) {
        CFRelease(trust);
    }
    
    if (policy) {
        CFRelease(policy);
    }
    
    if (certificate) {
        CFRelease(certificate);
    }
    
    return publicKey;
}

/**证书是否被信任*/
static BOOL MNServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
_out:
    return isValid;
}

/**获取服务端证书链*/
static NSArray <NSData *>* MNCertificateTrustChainForServerTrust(SecTrustRef serverTrust) {
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }
    return trustChain.copy;
}

/**获取服务端证书链公钥集合*/
static NSArray * MNPublicKeyTrustChainForServerTrust(SecTrustRef serverTrust) {
    SecPolicyRef policy = SecPolicyCreateBasicX509();
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        
        SecCertificateRef someCertificates[] = {certificate};
        CFArrayRef certificates = CFArrayCreate(NULL, (const void **)someCertificates, 1, NULL);
        
        SecTrustRef trust;
        __Require_noErr_Quiet(SecTrustCreateWithCertificates(certificates, policy, &trust), _out);
        
        SecTrustResultType result;
        __Require_noErr_Quiet(SecTrustEvaluate(trust, &result), _out);
        
        [trustChain addObject:(__bridge_transfer id)SecTrustCopyPublicKey(trust)];
        
    _out:
        if (trust) {
            CFRelease(trust);
        }
        
        if (certificates) {
            CFRelease(certificates);
        }
        
        continue;
    }
    CFRelease(policy);
    
    return trustChain.copy;
}

@interface MNTrustPolicy ()
@property (nonatomic) MNTrustMode mode;
@property (readwrite, copy) NSSet *publicKeys;
@end

@implementation MNTrustPolicy
- (instancetype)init {
    if (self = [super init]) {
        self.validatesDomainName = YES;
    }
    return self;
}

+ (MNTrustPolicy *)defaultPolicy {
    MNTrustPolicy *policy = [[self alloc] init];
    policy.mode = MNTrustModeNone;
    return policy;
}

+ (MNTrustPolicy *)policyWithMode:(MNTrustMode)mode {
    return [MNTrustPolicy policyWithMode:mode certificates:[self certificatesInBundle:NSBundle.mainBundle]];
}

+ (instancetype)policyWithMode:(MNTrustMode)mode certificates:(NSSet <NSData *> *_Nullable)certificates {
    MNTrustPolicy *policy = [[self alloc] init];
    policy.mode = mode;
    policy.certificates = certificates;
    return policy;
}

#pragma mark - 设置证书
- (void)setCertificates:(NSSet<NSData *> *)certificates {
    _certificates = certificates.copy;
    _publicKeys = nil;
    if (_certificates.count) {
        NSMutableSet *publicKeys = [NSMutableSet setWithCapacity:_certificates.count];
        for (NSData *certificate in _certificates) {
            id publicKey = MNPublicKeyForCertificate(certificate);
            if (publicKey) [publicKeys addObject:publicKey];
        }
        _publicKeys = publicKeys.count ? publicKeys.copy : nil;
    }
}

#pragma mark - 验证服务器证书信息
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust {
    return [self evaluateServerTrust:serverTrust forDomain:nil];
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    //判断矛盾的条件;
    //判断有域名, 且允许自建证书, 需要验证域名;
    //因为要验证域名, 所以必须不能是MNTrustModeNone或者添加到项目里的证书为0个;
    if (!self.allowsInvalidCertificate && ((self.mode == MNTrustModePublicKey && self.publicKeys.count <= 0) || (self.mode == MNTrustModeCertificate && self.certificates.count <= 0))) {
        NSLog(@"policy unusable");
        return NO;
    }
    //用来装验证策略
    NSMutableArray *policies = [NSMutableArray array];
    //添加验证策略
    if (self.validatesDomainName) {
        //如果需要验证domain, 那么就使用SecPolicyCreateSSL函数创建验证策略, 其中第一个参数为true表示验证整个SSL证书链, 第二个参数传入domain, 用于判断整个证书链上叶子节点表示的那个domain是否和此处传入domain一致
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        //如果不需要验证domain, 就使用默认的BasicX509验证策略
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    //serverTrust: X509服务器的证书信任
    //为serverTrust设置验证策略, 即告诉客户端如何验证serverTrust
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    //有验证策略了, 可以去验证了, 如果是MNTrustModeNone, 是自签名, 直接返回可信任, 否则不是自签名的就去系统根证书里去找是否有匹配的证书;
    if (self.mode == MNTrustModeNone) {
        //如果支持无效证书, 直接返回YES, 不允许才去判断第二个条件, 判断serverTrust是否有效
        return self.allowsInvalidCertificate || MNServerTrustIsValid(serverTrust);
    } else if (!self.allowsInvalidCertificate && !MNServerTrustIsValid(serverTrust)) {
        //如果验证无效, 而且allowInvalidCertificates不允许无效证书通过
        return NO;
    }
    //根据类型验证
    switch (self.mode) {
        //验证证书类型
        case MNTrustModeCertificate:
        {
            //把证书data,用系统api转成 SecCertificateRef类型的数据;
            //SecCertificateCreateWithData函数对原先的certificates做一些处理, 保证返回的证书都是DER编码的X.509证书
            NSMutableArray *anchorCertificates = [NSMutableArray array];
            for (NSData *certificateData in self.certificates) {
                [anchorCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
            }
            // 将anchorCertificates设置成需要参与验证的Anchor Certificate(锚点证书: 通过SecTrustSetAnchorCertificates设置了参与校验锚点证书之后, 假如验证的数字证书是这个锚点证书的子节点, 即验证的数字证书是由锚点证书对应CA或子CA签发的, 或是该证书本身, 则信任该证书), 具体就是调用SecTrustEvaluate来验证.
            SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)anchorCertificates);
            //SecTrustSetAnchorCertificatesOnly(serverTrust, NO);
            //再去调用之前的serverTrust去验证该证书是否有效, 有可能,经过这个方法过滤后, serverTrust里面的anchorCertificates被筛选到只有信任的那一个证书
            if (!MNServerTrustIsValid(serverTrust)) return NO;
            //注意, 这个方法和我们之前的锚点证书没关系了, 验证证书链;
            //服务器端的证书链, 注意此处返回的证书链顺序是从叶节点到根节点;
            NSArray *serverCertificates = MNCertificateTrustChainForServerTrust(serverTrust);
            for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
                //如果我们的证书中，有一个和它证书链中的证书匹配的，就返回YES
                if ([self.certificates containsObject:trustChainCertificate]) {
                    return YES;
                }
            }
            return NO;
        }
        case MNTrustModePublicKey: {
            NSUInteger trustedPublicKeyCount = 0;
            // 从serverTrust中取出证书链中的公钥
            NSArray *publicKeys = MNPublicKeyTrustChainForServerTrust(serverTrust);
            //遍历本地公钥是否包含该公钥
            for (id trustChainPublicKey in publicKeys) {
                //遍历本地公钥
                for (id pinnedPublicKey in self.publicKeys) {
                    //判断如果相同 trustedPublicKeyCount+1
                    if (MNSecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
                        trustedPublicKeyCount += 1;
                    }
                }
            }
            return trustedPublicKeyCount > 0;
        }
        default:
            return NO;
    }
    
    return NO;
}

+ (NSSet <NSData *> *)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];
    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }
    return certificates.copy;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    MNTrustPolicy *policy = [[MNTrustPolicy allocWithZone:zone] init];
    policy.mode = self.mode;
    policy.validatesDomainName = self.validatesDomainName;
    policy.allowsInvalidCertificate = self.allowsInvalidCertificate;
    policy.certificates = self.certificates;
    policy.publicKeys = self.publicKeys;
    return policy;
}

@end
