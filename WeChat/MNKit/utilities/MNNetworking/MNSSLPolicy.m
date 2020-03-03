//
//  MNSSLPolicy.m
//  MNKit
//
//  Created by Vincent on 2018/11/16.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNSSLPolicy.h"
#import <AssertMacros.h>

/**存放自建证书公钥*/
NSMutableArray *MNCertificatePublicKeyArray (void) {
    static NSMutableArray *certificatePublicKeys;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        certificatePublicKeys = [NSMutableArray arrayWithCapacity:0];
    });
    return certificatePublicKeys;
}

/**存放自建证书*/
NSMutableDictionary *MNCertificateDataDictionary (void) {
    static NSMutableDictionary *certificateDataDictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        certificateDataDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return certificateDataDictionary;
}

/// 获取证书里的公钥
static id MNPublicKeyForCertificate(NSData *certificate) {
    id allowedPublicKey = nil;
    SecCertificateRef allowedCertificate;
    SecPolicyRef policy = nil;
    SecTrustRef allowedTrust = nil;
    SecTrustResultType result;
    
    allowedCertificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificate);
    __Require_Quiet(allowedCertificate != NULL, _out);
    
    policy = SecPolicyCreateBasicX509();
    __Require_noErr_Quiet(SecTrustCreateWithCertificates(allowedCertificate, policy, &allowedTrust), _out);
    __Require_noErr_Quiet(SecTrustEvaluate(allowedTrust, &result), _out);
    
    allowedPublicKey = (__bridge_transfer id)SecTrustCopyPublicKey(allowedTrust);
    
_out:
    if (allowedTrust) {
        CFRelease(allowedTrust);
    }
    
    if (policy) {
        CFRelease(policy);
    }
    
    if (allowedCertificate) {
        CFRelease(allowedCertificate);
    }
    
    return allowedPublicKey;
}

/// 验证证书
static BOOL MNServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
_out:
    return isValid;
}

/// 获取服务端证书链
static NSArray * MNCertificateTrustChainForServerTrust(SecTrustRef serverTrust) {
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableArray *trustChain = [NSMutableArray arrayWithCapacity:(NSUInteger)certificateCount];
    for (CFIndex i = 0; i < certificateCount; i++) {
        SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        [trustChain addObject:(__bridge_transfer NSData *)SecCertificateCopyData(certificate)];
    }
    return [NSArray arrayWithArray:trustChain];
}

/// 获取服务端证书链公钥
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
    
    return [NSArray arrayWithArray:trustChain];
}

/// 判断公钥是否相同
static BOOL MNSecKeyIsEqualToKey(SecKeyRef key1, SecKeyRef key2) {
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
    return [(__bridge id)key1 isEqual:(__bridge id)key2];
#else
    return [AFSecKeyGetData(key1) isEqual:AFSecKeyGetData(key2)];
#endif
}

@implementation MNSSLPolicy
- (instancetype)initWithPinningMode:(MNSSLPinningMode)mode {
    self = [super init];
    if (!self) return nil;
    self.mode = mode;
    return self;
}
+ (MNSSLPolicy *)defaultPolicy {
    return [[MNSSLPolicy alloc] initWithPinningMode:MNSSLPinningModeNone];
}

#pragma mark - 添加证书
- (void)addCertificatePath:(NSArray <NSString *>*)paths {
    if (paths.count <= 0) return;
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[path pathExtension] isEqualToString:@"cer"]) {
            NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
            if ([MNCertificateDataDictionary().allKeys containsObject:name]) return;
            NSData *certificate = [NSData dataWithContentsOfFile:path];
            if (certificate) {
                [MNCertificateDataDictionary() setObject:certificate forKey:name];
                id publicKey = MNPublicKeyForCertificate(certificate);
                if (publicKey) {
                    [MNCertificatePublicKeyArray() addObject:publicKey];
                }
            }
        }
    }];
}

#pragma mark - 验证服务器证书信息
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    //判断矛盾的条件;
    //判断有域名, 且允许自建证书, 需要验证域名;
    //因为要验证域名, 所以必须不能是MNSSLPinningModeNone或者添加到项目里的证书为0个;
    if (domain && self.allowInvalidCertificate && self.validateDomainName && (self.mode == MNSSLPinningModeNone || MNCertificateDataDictionary().allKeys <= 0)) {
        NSLog(@"In order to validate a domain name for self signed certificates, you MUST use pinning.");
        return NO;
    }
    //用来装验证策略
    NSMutableArray *policies = [NSMutableArray array];
    //添加验证策略
    if (self.validateDomainName) {
        //如果需要验证domain, 那么就使用SecPolicyCreateSSL函数创建验证策略,其中第一个参数为true表示验证整个SSL证书链, 第二个参数传入domain, 用于判断整个证书链上叶子节点表示的那个domain是否和此处传入domain一致
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    } else {
        //如果不需要验证domain, 就使用默认的BasicX509验证策略
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    //serverTrust: X 509服务器的证书信任
    //为serverTrust设置验证策略, 即告诉客户端如何验证serverTrust
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    //有验证策略了, 可以去验证了, 如果是MNSSLPinningModeNone, 是自签名, 直接返回可信任, 否则不是自签名的就去系统根证书里去找是否有匹配的证书;
    if (self.mode == MNSSLPinningModeNone) {
        //如果支持自签名, 直接返回YES, 不允许才去判断第二个条件, 判断serverTrust是否有效
        return self.allowInvalidCertificate || MNServerTrustIsValid(serverTrust);
    } else if (!MNServerTrustIsValid(serverTrust) && !self.allowInvalidCertificate) {
        //如果验证无效AFServerTrustIsValid，而且allowInvalidCertificates不允许自签，返回NO
        return NO;
    }
    //根据类型验证
    switch (self.mode) {
        // 理论上, 上面那个部分已经解决了AFSSLPinningModeNone情况, 所以此处直接返回NO
        case MNSSLPinningModeNone:
        default:
            return NO;
        //验证证书类型
        case MNSSLPinningModeCertificate:
        {
            //把证书data,用系统api转成 SecCertificateRef类型的数据;
            //SecCertificateCreateWithData函数对原先的pinnedCertificates做一些处理, 保证返回的证书都是DER编码的X.509证书
            NSMutableArray *pinnedCertificates = [NSMutableArray array];
            for (NSData *certificateData in MNCertificateDataDictionary().allValues) {
                [pinnedCertificates addObject:(__bridge_transfer id)SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData)];
            }
            // 将pinnedCertificates设置成需要参与验证的Anchor Certificate（锚点证书，通过SecTrustSetAnchorCertificates设置了参与校验锚点证书之后，假如验证的数字证书是这个锚点证书的子节点，即验证的数字证书是由锚点证书对应CA或子CA签发的，或是该证书本身，则信任该证书），具体就是调用SecTrustEvaluate来验证。
            //serverTrust是服务器来的验证，有需要被验证的证书。
            SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)pinnedCertificates);
            //再去调用之前的serverTrust去验证该证书是否有效, 有可能,经过这个方法过滤后, serverTrust里面的pinnedCertificates被筛选到只有信任的那一个证书
            if (!MNServerTrustIsValid(serverTrust)) return NO;
            //注意, 这个方法和我们之前的锚点证书没关系了, 是去从我们需要被验证的服务端证书,去拿证书链;
            //服务器端的证书链, 注意此处返回的证书链顺序是从叶节点到根节点;
            NSArray *serverCertificates = MNCertificateTrustChainForServerTrust(serverTrust);
            //reverseObjectEnumerator逆序
            for (NSData *trustChainCertificate in [serverCertificates reverseObjectEnumerator]) {
                //如果我们的证书中，有一个和它证书链中的证书匹配的，就返回YES
                if ([MNCertificatePublicKeyArray() containsObject:trustChainCertificate]) {
                    return YES;
                }
            }
            return NO;
        }
        case MNSSLPinningModePublicKey: {
            NSUInteger trustedPublicKeyCount = 0;
            // 从serverTrust中取出服务器端传过来的所有可用的证书，并依次得到相应的公钥
            NSArray *publicKeys = MNPublicKeyTrustChainForServerTrust(serverTrust);
            //遍历服务端公钥
            for (id trustChainPublicKey in publicKeys) {
                //遍历本地公钥
                for (id pinnedPublicKey in MNCertificatePublicKeyArray()) {
                    //判断如果相同 trustedPublicKeyCount+1
                    if (MNSecKeyIsEqualToKey((__bridge SecKeyRef)trustChainPublicKey, (__bridge SecKeyRef)pinnedPublicKey)) {
                        trustedPublicKeyCount += 1;
                    }
                }
            }
            return trustedPublicKeyCount > 0;
        }
    }
}

@end
