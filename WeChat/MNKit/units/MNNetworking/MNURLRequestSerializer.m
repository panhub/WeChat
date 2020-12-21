//
//  MNURLRequestSerializer.m
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLRequestSerializer.h"
@class MNStringPair;

MNURLRequestMethodName MNURLRequestMethodGET = @"GET";
MNURLRequestMethodName MNURLRequestMethodPOST = @"POST";
MNURLRequestMethodName MNURLRequestMethodHEAD = @"HEAD";
MNURLRequestMethodName MNURLRequestMethodDELETE = @"DELETE";

NSString *const MNURLRequestUploadBoundaryName = @"mn.upload.boundary.name";

@interface MNStringPair : NSObject
@property (readwrite, nonatomic, copy) NSString *field;
@property (readwrite, nonatomic, copy) NSString *value;

- (NSString *)stringValue;

@end

@implementation MNStringPair

- (NSString *)stringValue {
    if (!self.field || self.field.length <= 0) return @"";
    return [NSString stringWithFormat:@"%@=%@",MNPercentEscapedStringFromString(self.field),MNPercentEscapedStringFromString(self.value)];
}

static NSString * MNPercentEscapedStringFromString(NSString *string) {
    if (!string || string.length <= 0) return @"";
    // does not include "?" or "/" due to RFC 3986 - Section 3.4
    /**需要避开的字符*/
    static NSString * const MNCharactersGeneralDelimitersToEncode = @":#[]@";
    static NSString * const MNCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    /**删除需要避开的字符*/
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[MNCharactersGeneralDelimitersToEncode stringByAppendingString:MNCharactersSubDelimitersToEncode]];
    
    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    
    /**避免分裂字符, 比如表情*/
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *result = [@"" mutableCopy];
    
    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [result appendString:encoded];
        
        index += range.length;
    }
    
    return result;
}

@end


@interface MNURLRequestSerializer ()
@end

@implementation MNURLRequestSerializer
+ (instancetype)serializer {
    return [[MNURLRequestSerializer alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.timeoutInterval = 10.f;
    self.allowsCellularAccess = YES;
    self.stringEncoding = NSUTF8StringEncoding;
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    return self;
}

- (NSURLRequest *_Nullable)requestWithUrl:(NSString *)url
                                            method:(MNURLRequestMethodName)method
                                        error:(NSError *__autoreleasing *_Nullable)error
{
    if (!url || url.length <= 0) {
        if (error) *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:@{NSLocalizedDescriptionKey:@"未知请求地址", NSLocalizedFailureReasonErrorKey:@"请求地址为空", NSURLErrorKey:@"url is empty"}];
        return nil;
    }
    
    if (!method || method.length <= 0) {
        if (error) *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:@{NSLocalizedDescriptionKey:@"未知请求方式", NSLocalizedFailureReasonErrorKey:@"请求方式为空", NSURLErrorKey:@"method is empty"}];
        return nil;
    }
    
    NSError *queryError;
    url = [self query:url error:&queryError];
    if (queryError) {
        if (error) *error = queryError;
        return nil;
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    if (!request) {
        if (error) *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"请求体初始化失败", NSLocalizedFailureReasonErrorKey:@"请求体初始化失败", NSURLErrorKey:@"NSMutableURLRequest initWithURL return nil"}];
        return nil;
    }
    
    /**设置请求*/
    request.HTTPMethod = method;
    request.timeoutInterval = self.timeoutInterval;
    request.cachePolicy = self.cachePolicy;
    request.allowsCellularAccess = self.allowsCellularAccess;
    if (self.headerFields) request.allHTTPHeaderFields = self.headerFields;
    
    /**设置服务端验证信息*/
    if (self.authHeader && self.authHeader.count) {
        NSString *username = [self.authHeader.allKeys firstObject];
        NSString *password = [self.authHeader objectForKey:username];
        NSData *authData = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:self.stringEncoding];
        NSString *authString = [authData base64EncodedStringWithOptions:kNilOptions];
        if (authString && authString.length) [request setValue:authString forHTTPHeaderField:@"Authorization"];
    }
    
    /**POST*/
    if ([method isEqualToString:MNURLRequestMethodPOST] && self.body) {
        /**追加数据体*/
        NSData *httpBody;
        if ([self.body isKindOfClass:NSData.class]) {
            httpBody = (NSData *)self.body;
        } else {
            NSString *body = MNQueryStringExtract(self.body, @"&");
            if (body && body.length) httpBody = [body dataUsingEncoding:self.stringEncoding];
        }
        if (httpBody && httpBody.length) {
            [request setHTTPBody:httpBody];
            if (![request valueForHTTPHeaderField:@"Content-Type"]) {
                [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            }
        } else {
            if (error) *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"请求体追加失败", NSLocalizedFailureReasonErrorKey:@"请求体类型不匹配", NSURLErrorKey:@"add body failed"}];
            return nil;
        }
        /**设置上传格式*/
        if (![request valueForHTTPHeaderField:@"Content-Type"]) {
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@", self.boundary] forHTTPHeaderField:@"Content-Type"];
        }
    }
    
    return request.copy;
}

- (NSString *)query:(NSString *)url error:(NSError *__autoreleasing *)error {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    /**将链接编码*/
    if ([url respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEncodingWithAllowedCharacters:")]) {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    } else if ([url respondsToSelector:NSSelectorFromString(@"stringByAddingPercentEscapesUsingEncoding:")]) {
        url = [url stringByAddingPercentEscapesUsingEncoding:self.stringEncoding];
    }
#pragma clang diagnostic pop
    
    /**解析参数*/
    NSString *query = nil;
    if (self.queryStringSerializationCallback) {
        NSError *serializationError;
        query = self.queryStringSerializationCallback(self.query, &serializationError);
        if (serializationError) {
            if (error) *error = serializationError;
            return nil;
        }
    } else if (self.query && (([self.query respondsToSelector:NSSelectorFromString(@"count")] && [self.query count] > 0) || ([self.query respondsToSelector:NSSelectorFromString(@"length")] && [self.query length] > 0))) {
        query = MNQueryStringExtract(self.query, @"&");
    }
    
    /**往链接里拼接参数*/
    if (query && query.length > 0) {
        url = [url stringByAppendingFormat:[url containsString:@"?"] ? @"&%@" : @"?%@", query];
    }
    
    return url;
}

#pragma mark - Getter
- (NSString *)boundary {
    if (!_boundary) return MNURLRequestUploadBoundaryName;
    return _boundary;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    MNURLRequestSerializer *serializer = [MNURLRequestSerializer allocWithZone:zone];
    serializer.body = self.body;
    serializer.query = self.query;
    serializer.boundary = self.boundary;
    serializer.cachePolicy = self.cachePolicy;
    serializer.headerFields = self.headerFields;
    serializer.timeoutInterval = self.timeoutInterval;
    serializer.stringEncoding = self.stringEncoding;
    serializer.authHeader = self.authHeader;
    serializer.allowsCellularAccess = self.allowsCellularAccess;
    serializer.queryStringSerializationCallback = [self.queryStringSerializationCallback copy];
    return serializer;
}

#pragma mark - 解析参数
NSString * MNQueryStringExtract (id obj, NSString *split) {
    if (!obj) return nil;
    if ([obj isKindOfClass:NSString.class]) return MNPercentEscapedStringFromString((NSString *)obj);
    if (!split) return nil;
    NSMutableArray *result = [NSMutableArray array];
    for (MNStringPair *pair in MNQueryPairEncrypt(obj)) {
        NSString *stringValue = pair.stringValue;
        if (stringValue.length) [result addObject:stringValue];
    }
    return [result componentsJoinedByString:split];
}

static NSArray <MNStringPair *>* MNQueryPairEncrypt (id obj) {
    return MNQueryPairFromKeyAndValue(nil, obj);
}

static NSArray <MNStringPair *>* MNQueryPairFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *components = [NSMutableArray array];
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)value;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
        for (id obj in [[dic allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id v = [dic objectForKey:obj];
            NSString *k = [obj isKindOfClass:NSNumber.class] ? ((NSNumber *)obj).stringValue : obj;
            [components addObjectsFromArray:MNQueryPairFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, k] : k), v)];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)value;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [components addObjectsFromArray:MNQueryPairFromKeyAndValue([NSString stringWithFormat:@"%@[]",key], obj)];
        }];
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = (NSSet *)value;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
        for (id obj in [set sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            [components addObjectsFromArray:MNQueryPairFromKeyAndValue(key, obj)];
        }
    } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        MNStringPair *pair = [[MNStringPair alloc] init];
        if (!pair) return components;
        pair.field = key;
        pair.value = [value isKindOfClass:NSNumber.class] ? ((NSNumber *)value).stringValue : value;
        [components addObject:pair];
    }
    return components;
}

@end
