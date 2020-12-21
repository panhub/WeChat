//
//  MNLaunchImage.h
//  MNKit
//
//  Created by Vicent on 2020/8/4.
//  启动图生成

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNLaunchImage : NSObject
/**背景颜色*/
@property (nonatomic, copy, nullable) UIColor *backgroundColor;
/**文字*/
@property (nonatomic, copy, nullable) NSString *text;
/**字体*/
@property (nonatomic, copy, nullable) UIFont *font;
/**文字颜色*/
@property (nonatomic, copy, nullable) UIColor *textColor;

/**
 使用默认值导出图片
 @param completionHandler 完成回调
 */
+ (void)exportWithCompletionHandler:(void(^_Nullable)(NSString *, NSArray <UIImage *>*_Nullable, NSError *_Nullable))completionHandler;

/**
 导出图片使用默认路径
 @param completionHandler 完成回调
 */
- (void)exportWithCompletionHandler:(void(^_Nullable)(NSString *, NSArray <UIImage *>*_Nullable, NSError *_Nullable))completionHandler;

/**
 导出图片到指定路径
 @param directoryPath 指定路径
 @param completionHandler 完成回调
 */
- (void)exportAtDirectory:(NSString *)directoryPath completionHandler:(void(^_Nullable)(NSString *, NSArray <UIImage *>*_Nullable, NSError *_Nullable))completionHandler;

@end

NS_ASSUME_NONNULL_END
