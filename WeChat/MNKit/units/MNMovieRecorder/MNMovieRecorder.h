/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制/拍照
 */

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)

/**
 视频预览模式
 */
typedef NS_ENUM(NSInteger, MNMovieResizeMode) {
    MNMovieResizeModeResize = 0,
    MNMovieResizeModeResizeAspect,
    MNMovieResizeModeResizeAspectFill
};

/**
 视频宽高比率
 - MNMovieSizeRatioUnknown: 未知
 - MNMovieSizeRatio9x16: 9/16
 - MNMovieSizeRatio16x9: 16/9
 - MNMovieSizeRatio3x4: 3/4
 - MNMovieSizeRatio4x3: 4/3
 */
typedef NS_ENUM(NSInteger, MNMovieSizeRatio) {
    MNMovieSizeRatioUnknown = 0,
    MNMovieSizeRatio9x16,
    MNMovieSizeRatio16x9,
    MNMovieSizeRatio3x4,
    MNMovieSizeRatio4x3,
};

/**
 视频输入摄像头
 - MNMovieDevicePositionBack: 后置摄像头
 - MNMovieDevicePositionFront: 前置摄像头
 */
typedef NS_ENUM(NSInteger, MNMovieDevicePosition) {
    MNMovieDevicePositionBack = 1,
    MNMovieDevicePositionFront
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

NS_ASSUME_NONNULL_BEGIN

@class MNMovieRecorder;
@protocol MNMovieRecordDelegate <NSObject>
@optional
- (void)movieRecorderDidStartRecording:(MNMovieRecorder *)recorder;
- (void)movieRecorderDidFinishRecording:(MNMovieRecorder *)recorder;
- (void)movieRecorderDidCancelRecording:(MNMovieRecorder *)recorder;
- (void)movieRecorder:(MNMovieRecorder *)recorder didFailWithError:(NSError *)error;
@end

@interface MNMovieRecorder : NSObject
/**视频文件地址*/
@property (nonatomic, copy) NSURL *URL;
/**视频拉伸方式*/
@property (nonatomic) MNMovieResizeMode resizeMode;
/**摄像头方向*/
@property (nonatomic) MNMovieDevicePosition devicePosition;
/**视频方向*/
@property (nonatomic) MNMovieOrientation movieOrientation;
/**录制时长时长*/
@property (nonatomic, readonly) Float64 duration;
/**视频帧率, 默认30*/
@property (nonatomic) int frameRate;
/**图像展示视图*/
@property (nonatomic, weak) UIView *outputView;
/**捕获质量*/
@property (nonatomic, copy) AVCaptureSessionPreset sessionPreset;
/**捕获尺寸比例*/
@property (nonatomic, readonly) MNMovieSizeRatio presetSizeRatio;
/**事件回调*/
@property (nonatomic, weak, nullable) id<MNMovieRecordDelegate> delegate;
/**是否在录制*/
@property (nonatomic, readonly) BOOL isRecording;
/**是否在获取*/
@property (nonatomic, readonly) BOOL isRunning;
/**是否打开了手电筒*/
@property (nonatomic, readonly) BOOL isOnTorch;
/**是否打开了闪光灯*/
@property (nonatomic, readonly) BOOL isOnFlash;

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
- (void)cancelRecording;
- (BOOL)deleteRecording;

#pragma mark - 拍照
- (void)takeStillImageAsynchronously:(void(^)(UIImage *_Nullable))completion;

#pragma mark - 手电筒
- (NSError *_Nullable)openTorch;
- (NSError *_Nullable)closeTorch;

#pragma mark - 闪光灯
- (NSError *_Nullable)openFlash;
- (NSError *_Nullable)closeFlash;

#pragma mark - 摄像头
- (BOOL)convertCapturePosition;
- (BOOL)convertCapturePosition:(MNMovieDevicePosition)capturePosition error:(NSError *_Nullable*_Nullable)error;

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)point;

#pragma mark - 曝光
- (BOOL)setExposure:(CGPoint)point;

#pragma mark - -缩放
- (BOOL)setZoomFactor:(CGFloat)factor withRate:(float)rate;

@end

NS_ASSUME_NONNULL_END
#endif
