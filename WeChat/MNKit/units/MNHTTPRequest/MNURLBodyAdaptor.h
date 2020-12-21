//
//  MNURLBodyAdaptor.h
//  MNKit
//
//  Created by Vicent on 2020/8/20.
//  文件上传数据体适配 不保证线程安全

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**定义边界分隔符*/
FOUNDATION_EXTERN NSString * _Nonnull const MNURLBodyBoundaryName;

/**依据后缀获取ContentType*/
FOUNDATION_EXTERN NSString *_Nonnull MNContentTypeFromPathExtension(NSString *);

@interface MNURLBodyAdaptor : NSObject
/**字符串编码格式*/
@property (nonatomic) NSStringEncoding stringEncoding;
/**获取数据*/
@property (nonatomic, readonly, nullable) NSData *data;
/**边界分隔符*/
@property (nonatomic, copy, null_resettable) NSString *boundary;

/**
 携带边界定义实例化
 @param boundaryName 边界定义
 @return 适配器实例
 */
- (instancetype)initWithBoundary:(NSString *_Nullable)boundaryName;

/**
 追加字符串
 @param string 字符串
 @param key 关键字
 @return 是否追加成功
 */
- (BOOL)appendString:(NSString *)string forKey:(NSString *)key;

/**
 追加图片
 @param image 图片
 @param key 关键字
 @param filename 文件名<携带文件后缀>
 @return 是否追加成功
 */
- (BOOL)appendImage:(UIImage *)image forKey:(NSString *)key filename:(NSString *)filename;

/**
 追加文件<内部解析文件名>
 @param filePath 指定路径
 @param key 关键字
 @return 是否追加成功
 */
- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key;
/**
 追加文件
 @param filePath 指定路径
 @param key 关键字
 @param filename 文件名<携带文件后缀, nil则自行分析路径lastPathComponent>
 @return 是否追加成功
 */
- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key filename:(NSString *_Nullable)filename;
/**
 追加文件
 @param filePath 指定路径
 @param key 关键字
 @param filename 文件名<携带文件后缀>
 @param mimeType 文件类型<nil则内部依据文件后缀自行判断>
 @return 是否追加成功
 */
- (BOOL)appendFileAtPath:(NSString *)filePath forKey:(NSString *)key filename:(NSString *_Nullable)filename type:(NSString *_Nullable)mimeType;

/**
 追加文件
 @param fileURL 指定路径
 @param key 关键字
 @param filename 文件名<携带文件后缀>
 @param mimeType 文件类型<nil则内部依据文件后缀自行判断>
 @return 是否追加成功
 */
- (BOOL)appendFileWithURL:(NSURL *)fileURL forKey:(NSString *)key filename:(NSString *_Nullable)filename type:(NSString *_Nullable)mimeType;

/**
 追加数据流
 @param key 关键字
 @param filename 文件名<携带文件后缀>
 @return 是否追加成功
 */
- (BOOL)appendData:(NSData *)data forKey:(NSString *)key filename:(NSString *)filename;
/**
 追加数据流
 @param key 关键字
 @param filename 文件名<携带文件后缀>
 @param mimeType 文件类型<nil则内部依据文件后缀自行判断>
 @return 是否追加成功
 */
- (BOOL)appendData:(NSData *)data forKey:(NSString *)key filename:(NSString *)filename type:(NSString *_Nullable)mimeType;

/**
 拼接数据
 @param dictionary <key:name, value:字符串数据或文件路径>
 @return 是否全部拼接完成
 */
- (BOOL)appendDataUsingDictionary:(NSDictionary <NSString *, id>*)dictionary;

/**
 追加数据体 重置数据
 */
- (void)beginAdapting;

/**
 结束拼接数据
 */
- (void)endAdapting;

@end

NS_ASSUME_NONNULL_END
