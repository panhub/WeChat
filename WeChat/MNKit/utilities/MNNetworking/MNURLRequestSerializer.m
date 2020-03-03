//
//  MNURLRequestSerializer.m
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLRequestSerializer.h"

static NSSet <NSString *>* MNRequestMethodSet (void) {
    static NSSet <NSString *>*methodSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        methodSet = [NSSet setWithObjects:@"GET", @"HEAD", @"DELETE", nil];
    });
    return methodSet;
}

@interface MNStringPair : NSObject
@property (readwrite, nonatomic, copy) NSString *field;
@property (readwrite, nonatomic, copy) NSString *value;

- (NSString *)stringValue;

@end

@implementation MNStringPair

- (NSString *)stringValue {
    if (self.field.length <= 0 || self.value.length <= 0) return self.description;
    return [NSString stringWithFormat:@"%@=%@",MNPercentEscapedStringFromString(self.field),MNPercentEscapedStringFromString(self.value)];
}

static NSString * MNPercentEscapedStringFromString(NSString *string) {
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
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    self.timeoutInterval = 10.f;
    self.allowsCellularAccess = YES;
    self.stringEncoding = NSUTF8StringEncoding;
    return self;
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       url:(NSString *)url
                                parameter:(nullable NSDictionary *)parameter
                                     error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(url);
    NSParameterAssert(method);
    
    url = [url stringByAddingPercentEscapesUsingEncoding:self.stringEncoding];
    NSURL *URL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    NSParameterAssert(request);
    
    request.HTTPMethod = method;
    request.timeoutInterval = self.timeoutInterval;
    request.cachePolicy = self.cachePolicy;
    request.allowsCellularAccess = self.allowsCellularAccess;
    if (self.headerField.count > 0) {
        [self.headerField enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [request setValue:value forHTTPHeaderField:field];
            }
        }];
    }
    
    /**设置服务端验证信息*/
    if (MNURLRequestAuthorizationHeaderField().count > 0) {
        [MNURLRequestAuthorizationHeaderField() enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull field, NSString * _Nonnull value, BOOL * _Nonnull stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [request setValue:value forHTTPHeaderField:field];
            }
        }];
        /**设置完请求, 清空信息, 避免下次请求体初始化出现错误*/
        [MNURLRequestAuthorizationHeaderField() removeAllObjects];
    }
    
    request = [[self requestWithSerializingRequest:request parameters:parameter error:error] mutableCopy];
    
    return request;
}

- (NSURLRequest *)requestWithSerializingRequest:(NSURLRequest *)request
                               parameters:(NSDictionary *)parameters
                                        error:(NSError *__autoreleasing *)error
{
    NSParameterAssert(request);
    if (!parameters) return request;
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSString *query = nil;
    if (self.queryStringSerializationCallback) {
        NSError *serializationError;
        query = self.queryStringSerializationCallback(request, parameters, &serializationError);
        if (serializationError) {
            if (error) {
                *error = serializationError;
            }
            return nil;
        }
    } else {
        query = MNQueryStringFromParameters(parameters, @"&");
    }
    /**判断参数拼接方式*/
    if ([MNRequestMethodSet() containsObject:[[request HTTPMethod] uppercaseString]]) {
        /**往链接内拼接参数*/
        if (query && query.length > 0) {
            mutableRequest.URL = [NSURL URLWithString:[[mutableRequest.URL absoluteString] stringByAppendingFormat:mutableRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    } else {
        /**将参数添加到请求体中*/
        if (!query) query = @"";
        if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
            [mutableRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        [mutableRequest setHTTPBody:[query dataUsingEncoding:self.stringEncoding]];
    }
    return mutableRequest;
}

#pragma mark - 解析参数
NSString * MNQueryStringFromParameters (NSDictionary *parameters, NSString *_Nullable split) {
    if (!parameters) return @"";
    if (split.length <= 0) split = @"&";
    NSMutableArray *result = [NSMutableArray array];
    for (MNStringPair *pair in MNQueryStringFromDictionary(parameters)) {
        [result addObject:[pair stringValue]];
    }
    return [result componentsJoinedByString:split];
}

static NSArray <MNStringPair *>* MNQueryStringFromDictionary (NSDictionary *dictionary) {
    return MNQueryStringFromKeyAndValue(nil, dictionary);
}

static NSArray <MNStringPair *>* MNQueryStringFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *components = [NSMutableArray array];
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = (NSDictionary *)value;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
        for (NSString * _key in [[dic allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id _value = dic[_key];
            [components addObjectsFromArray:MNQueryStringFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]",key,_key] : _key), _value)];
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)value;
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [components addObjectsFromArray:MNQueryStringFromKeyAndValue([NSString stringWithFormat:@"%@[]",key], obj)];
        }];
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = (NSSet *)value;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description"
                                                                         ascending:YES
                                                                          selector:@selector(compare:)];
        for (id obj in [set sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            [components addObjectsFromArray:MNQueryStringFromKeyAndValue(key, obj)];
        }
    } else if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        MNStringPair *pair = [MNStringPair new];
        if (!pair) return components;
        pair.field = key;
        pair.value = (NSString *)value;
        [components addObject:pair];
    }
    return components;
}

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password {
    if (username.length <= 0 || password.length <= 0) return;
    NSData *basicAuthCredentials = [[NSString stringWithFormat:@"%@:%@", username, password] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64AuthCredentials = [basicAuthCredentials base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)0];
    [MNURLRequestAuthorizationHeaderField() setObject:base64AuthCredentials forKey:@"Authorization"];
}

static NSMutableDictionary * MNURLRequestAuthorizationHeaderField (void) {
    static NSMutableDictionary *authorization_header_field;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        authorization_header_field = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return authorization_header_field;
}

@end
