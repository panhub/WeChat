//
//  MNURLRequestSerializer.h
//  MNKit
//
//  Created by Vincent on 2018/11/6.
//  Copyright © 2018年 小斯. All rights reserved.
//  请求序列化器

#import <Foundation/Foundation.h>

typedef NSString * (^MNQueryStringSerializationCallback)(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error);

@interface MNURLRequestSerializer : NSObject

NSString * MNQueryStringFromParameters (NSDictionary *parameters, NSString *split);
@property (nonatomic, assign, readwrite) BOOL allowsCellularAccess;
@property (nonatomic, assign, readwrite) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;
@property (nonatomic, assign, readwrite) NSStringEncoding stringEncoding;
@property (nonatomic, copy, readwrite) NSURL *mainDocumentURL;
@property (nonatomic, copy, readwrite) NSDictionary <NSString *, NSString *>*headerField;
@property (nonatomic, copy, readwrite) MNQueryStringSerializationCallback queryStringSerializationCallback;

+ (instancetype)serializer;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                       url:(NSString *)url
                                parameter:(NSDictionary *)parameter
                                     error:(NSError *__autoreleasing *)error;

- (void)setAuthorizationHeaderFieldWithUsername:(NSString *)username password:(NSString *)password;

@end

