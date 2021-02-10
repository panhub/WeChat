/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制/拍照
 */

#import <Foundation/Foundation.h>

/**
 视频预览模式
 */
typedef NS_ENUM(NSInteger, MNCaptureResizeMode) {
    MNCaptureResizeModeResize = 0,
    MNCaptureResizeModeResizeAspect,
    MNCaptureResizeModeResizeAspectFill
};

/**
 视频输入摄像头
 - MNCapturePositionBack: 后置摄像头
 - MNCapturePositionFront: 前置摄像头
 */
typedef NS_ENUM(NSInteger, MNCapturePosition) {
    MNCapturePositionBack = 1,
    MNCapturePositionFront
};

/**
 视频播放方向
 - MNMovieOrientationPortrait: 竖向
 - MNMovieOrientationLandscape: 横向
 */
typedef NS_ENUM(NSInteger, MNMovieOrientation) {
    MNMovieOrientationPortrait = 1,
    MNMovieOrientationPortraitUpsideDown = 2,
    MNMovieOrientationLandscapeRight = 3,
    MNMovieOrientationLandscapeLeft = 4
};

/**
 录制状态
 - MNCaptureStatusIdle: 未知, 闲置状态
 - MNCaptureStatusPreparing: 即将写入进文件
 - MNCaptureStatusRecording: 正在录制视频
 - MNCaptureStatusFinish: 录制完成
 - MNCaptureStatusFailed: 录制出错
 */
typedef NS_ENUM(NSInteger, MNCaptureStatus) {
    MNCaptureStatusIdle = 0,
    MNCaptureStatusPreparing,
    MNCaptureStatusRecording,
    MNCaptureStatusFinish
};

NS_ASSUME_NONNULL_BEGIN

typedef NSString * MNCapturePresetName;
FOUNDATION_EXTERN MNCapturePresetName const MNCapturePresetLowQuality;
FOUNDATION_EXTERN MNCapturePresetName const MNCapturePresetMediumQuality;
FOUNDATION_EXTERN MNCapturePresetName const MNCapturePresetHighQuality;
FOUNDATION_EXTERN MNCapturePresetName const MNCapturePreset1280x720;
FOUNDATION_EXTERN MNCapturePresetName const MNCapturePreset1920x1080;

@class MNCaptureSession;
@protocol MNCaptureSessionDelegate <NSObject>
@optional
- (void)captureSessionDidStartRecording:(MNCaptureSession *)captureSession;
- (void)captureSessionDidFinishRecording:(MNCaptureSession *)captureSession;
- (void)captureSession:(MNCaptureSession *)captureSession didFailWithError:(NSError *)error;
@end

@interface MNCaptureSession : NSObject
/**视频拉伸方式*/
@property (nonatomic) MNCaptureResizeMode resizeMode;
/**摄像头*/
@property (nonatomic, readonly) MNCapturePosition capturePosition;
/**视频方向*/
@property (nonatomic) MNMovieOrientation movieOrientation;
/**录制时长时长*/
@property (nonatomic, readonly) Float64 duration;
/**视频帧率, 默认30*/
@property (nonatomic) int frameRate;
/**图像展示视图*/
@property (nonatomic, weak) UIView *outputView;
/**图像输出尺寸*/
@property (nonatomic) CGSize outputSize;
/**捕获质量*/
@property (nonatomic, copy) MNCapturePresetName presetName;
/**事件回调*/
@property (nonatomic, weak, nullable) id<MNCaptureSessionDelegate> delegate;
/**状态*/
@property (nonatomic, readonly) MNCaptureStatus status;
/**是否在录制*/
@property (nonatomic, readonly) BOOL isRecording;
/**是否在获取*/
@property (nonatomic, readonly) BOOL isRunning;
/**视频文件地址*/
@property (nonatomic, copy) NSURL *URL;
/**错误信息*/
@property (nonatomic, strong, readonly, nullable) NSError *error;

/**
 实例化视频录制实例
 @param URL 视频输出路径
 @return 视频录制实例
 */
- (instancetype)initWithURL:(NSURL *_Nullable)URL;

/**
 配置视频录制/图片捕获
 */
- (void)prepareCapturing;

/**
 配置视频录制
 */
- (void)prepareRecording;

/**
 配置图片捕获
 */
- (void)prepareSnapping;

#pragma mark - 捕获
- (void)startRunning;
- (void)stopRunning;

#pragma mark - 开始/停止/删除
- (void)startRecording;
- (void)stopRecording;
- (BOOL)deleteRecording;

#pragma mark - 手电筒控制
- (BOOL)openLighting;
- (BOOL)closeLighting;

#pragma mark - 转换镜头方向
- (BOOL)convertCapturePosition;
- (BOOL)setDeviceCapturePosition:(MNCapturePosition)capturePosition;

#pragma mark - 对焦
- (BOOL)setFocusPoint:(CGPoint)point;

#pragma mark - 拍照
- (void)captureStillImageAsynchronously:(void(^)(UIImage *image))completion;

@end

NS_ASSUME_NONNULL_END
