//
//  MNVideoGenerator.h
//  MNKit
//
//  Created by Vicent on 2020/8/6.
//  视频生成者

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)

NS_ASSUME_NONNULL_BEGIN

/**
 输出状态
 - MNVideoGenerateStatusUnknown: 未知(默认未操作状态)
 - MNVideoGenerateStatusExporting: 输出中
 - MNVideoGenerateStatusCompleted: 输出完成
 - MNVideoGenerateStatusFailed: 操作失败
 - MNVideoGenerateStatusCancelled: 取消
 */
typedef NS_ENUM(NSInteger, MNVideoGenerateStatus) {
    MNVideoGenerateStatusUnknown = 0,
    MNVideoGenerateStatusExporting = 2,
    MNVideoGenerateStatusCompleted = 3,
    MNVideoGenerateStatusFailed = 4,
    MNVideoGenerateStatusCancelled = 5
};

/**
进度回调
@param progress 进度信息
*/
typedef void(^MNVideoGenerateProgressHandler)(float progress);
/**
 输出回调
 @param status 状态
 @param error 错误信息(nullable)
 */
typedef void(^MNVideoGenerateCompletionHandler)(MNVideoGenerateStatus status, NSError *_Nullable error);

@interface MNVideoGenerator : NSObject
/**视频帧率<15-60>*/
@property (nonatomic) int frameRate;
/**视频持续时长*/
@property (nonatomic) NSTimeInterval duration;
/**进度*/
@property (nonatomic, readonly) float progress;
/**视频分辨率*/
@property (nonatomic) CGSize renderSize;
/**补充颜色*/
@property (nonatomic, copy) UIColor *fillColor;
/**视频输出路径*/
@property (nonatomic, copy) NSString *outputPath;
/**错误信息*/
@property (nonatomic, copy, readonly) NSError *error;
/**生成视频的图片源*/
@property (nonatomic, copy) NSArray <UIImage *>*images;
/**当前状态*/
@property (nonatomic, readonly) MNVideoGenerateStatus status;

/**
 视频生成实例化
 @param images 图片源
 @return 视频生成者
 */
- (instancetype)initWithImages:(NSArray <UIImage *>*)images;

/**
 视频生成实例化
 @param images 图片源
 @param duration 视频持续时长
 @return 视频生成者
 */
- (instancetype)initWithImages:(NSArray <UIImage *>*)images duration:(NSTimeInterval)duration;

/**
 追加图片到每一帧<水印>
 @param image 图片
 @param imageRect 图片位置
 */
- (void)appendImage:(UIImage *)image atRect:(CGRect)imageRect;

/**
 追加图片到每一帧<水印>
 @param image 图片
 @param imagePoint 图片位置
 */
- (void)appendImage:(UIImage *)image atPoint:(CGPoint)imagePoint;

/**
 异步输出操作
 @param completionHandler 结束回调
 */
- (void)exportAsynchronouslyWithCompletionHandler:(nullable MNVideoGenerateCompletionHandler)completionHandler;

/**
 异步输出
 @param progressHandler 进度回调
 @param completionHandler 完成回调
 */
- (void)exportAsynchronouslyWithProgressHandler:(nullable MNVideoGenerateProgressHandler)progressHandler
                              completionHandler:(nullable MNVideoGenerateCompletionHandler)completionHandler;

/**
 取消
 */
- (void)cancel;

@end
NS_ASSUME_NONNULL_END
#endif
