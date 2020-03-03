//
//  NSString+MNMediaMD5.m
//  MNKit
//
//  Created by Vincent on 2018/12/1.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "NSString+MNMediaMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MNMediaMD5)

- (NSString *)mediaMD5String {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
