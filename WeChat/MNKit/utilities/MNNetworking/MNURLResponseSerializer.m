//
//  MNURLResponseSerializer.m
//  MNKit
//
//  Created by Vincent on 2018/11/7.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNURLResponseSerializer.h"

NSString * const MNURLResponseSerializationErrorDomain = @"com.mn.error.serialization.response";
NSString * const MNNetworkingOperationFailingURLResponseErrorKey = @"com.mn.serialization.response.error.response";
NSString * const MNNetworkingOperationFailingURLResponseDataErrorKey = @"com.mn.serialization.response.error.data";

/**错误的合并,填充*/
static NSError * MNErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

/**判断错误是否是指定的错误类型*/
static BOOL MNErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSString *domain) {
    //判断错误域名和传过来的域名是否一致，错误code是否一致
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        //如果userInfo的NSUnderlyingErrorKey有值, 则再判断一次。
        return MNErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    return NO;
}

@interface MNURLResponseSerializer ()
@property (nonatomic, copy, readwrite) NSIndexSet *acceptableStatusCodes;
@end

@implementation MNURLResponseSerializer

+ (instancetype)serializer {
    return [[MNURLResponseSerializer alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    self.type = MNURLResponseSerializationJSON;
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    return self;
}

#pragma mark - 数据解析
- (id)responseObjectForResponse:(NSURLResponse *)response
                           type:(MNURLResponseSerializationType)type
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    //先判断是不是可接受类型和可接受code
    if (![self validateResponse:(NSHTTPURLResponse *)response type:type data:data error:error]) {
        //error为空, 或者错误为指定类型
        //验证出错的情况下error为空说明数据为nil 或 [response MIMEType] 为nil
        //MNURLResponseSerializationErrorDomain 说明响应码或数据类型不被接受
        if (!error || MNErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MNURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    if (type == MNURLResponseSerializationJSON) {
        return [self JSONObjectWithData:data error:error];
    } else if (type == MNURLResponseSerializationXML) {
        return [self XMLObjectWithData:data];
    } else if (type == MNURLResponseSerializationPlist) {
        return [self PropertyListObjectWithData:data error:error];
    }
    return nil;
}

#pragma mark JSON解析
- (id)JSONObjectWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    id responseObject = nil;
    NSError *serializationError = nil;
    //如果数据为空
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
    //不空则去json解析
    if (data.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&serializationError];
    } else {
        return nil;
    }
    
    if (!responseObject || serializationError) {
        //拿着json解析的error去填充错误信息
        if (error) {
            *error = MNErrorWithUnderlyingError(serializationError, *error);
        }
        return nil;
    }
    return responseObject;
}

#pragma mark XML解析
- (id)XMLObjectWithData:(NSData *)data
{
    if (!data) return nil;
    //返回解析器, 数据根据具体要求自行解析
    return [[NSXMLParser alloc] initWithData:data];
}

#pragma mark PropertyList解析
- (id)PropertyListObjectWithData:(NSData *)data error:(NSError *__autoreleasing *)error
{
    if (!data) return nil;
    
    NSError *serializationError = nil;
    
    id responseObject = [NSPropertyListSerialization propertyListWithData:data
                                                                  options:kNilOptions
                                                                   format:NULL
                                                                    error:&serializationError];
    
    if (!responseObject || serializationError) {
        if (error) {
            *error = MNErrorWithUnderlyingError(serializationError, *error);
        }
        return nil;
    }
    return responseObject;
}

#pragma mark - 验证数据是否匹配
- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    type:(MNURLResponseSerializationType)type
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error
{
    //response是否合法标识
    BOOL responseIsValid = YES;
    //验证的error
    NSError *validationError = nil;
    //如果存在且是NSHTTPURLResponse
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSSet <NSString *>*acceptSet = [self acceptContentSetWithSerializationType:type];
        //判断自己能接受的数据类型和response的数据类型是否匹配，
        //如果不匹配数据类型，如果不匹配response，而且响应类型不为空，数据长度不为0
        if (acceptSet && ![acceptSet containsObject:[response MIMEType]] &&
            !([response MIMEType] == nil && [data length] <= 0)) {
            //说明解析数据肯定是失败的, 这时候要把解析错误信息放到error里。
            //如果数据长度大于0，而且有响应url
            if ([data length] > 0 && [response URL]) {
                NSMutableDictionary *mutableUserInfo = [@{
                                                          NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"request failed: unacceptable content-type: %@", @"MNNetworking", nil), [response MIMEType]],
                                                          NSURLErrorFailingURLErrorKey:[response URL],
                                                          MNNetworkingOperationFailingURLResponseErrorKey: response,
                                                          } mutableCopy];
                if (data) {
                    mutableUserInfo[MNNetworkingOperationFailingURLResponseDataErrorKey] = data;
                }
                
                validationError = MNErrorWithUnderlyingError([NSError errorWithDomain:MNURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:mutableUserInfo], validationError);
            }
            
            responseIsValid = NO;
        }
        //判断自己可接受的状态码
        //如果和response的状态码不匹配，则进入if块
        if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode] && [response URL]) {
            NSMutableDictionary *mutableUserInfo = [@{
                                                      NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"request failed: %@ (%ld)", @"MNNetworking", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (long)response.statusCode],
                                                      NSURLErrorFailingURLErrorKey:[response URL],
                                                      MNNetworkingOperationFailingURLResponseErrorKey: response,
                                                      } mutableCopy];
            
            if (data) {
                mutableUserInfo[MNNetworkingOperationFailingURLResponseDataErrorKey] = data;
            }
            
            validationError = MNErrorWithUnderlyingError([NSError errorWithDomain:MNURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:mutableUserInfo], validationError);
            
            responseIsValid = NO;
        }
    }
    
    /**错误指针存在, 且验证数据错误, 为指针赋值*/
    if (error && !responseIsValid) {
        *error = validationError;
    }
    
    return responseIsValid;
}

#pragma mark - 可接受数据类型
- (NSSet <NSString *>*)acceptContentSetWithSerializationType:(MNURLResponseSerializationType)type
{
    NSSet <NSString *>*acceptSet;
    switch (type) {
        case MNURLResponseSerializationJSON:
        {
            static NSSet <NSString *>*set;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                set = [NSSet setWithObjects:
                       @"text/html",
                       @"application/json",
                       @"text/json",
                       @"text/plain",
                       @"text/javascript", nil];
            });
            acceptSet = set;
        } break;
        case MNURLResponseSerializationXML:
        {
            static NSSet <NSString *>*set;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                set = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
            });
            acceptSet = set;
        } break;
        case MNURLResponseSerializationPlist:
        {
            static NSSet <NSString *>*set;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                set = [[NSSet alloc] initWithObjects:@"application/x-plist", nil];
            });
            acceptSet = set;
        } break;
        default:
            break;
    }
    return acceptSet;
}


@end
