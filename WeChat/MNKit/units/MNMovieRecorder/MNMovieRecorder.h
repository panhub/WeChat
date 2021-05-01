/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制/拍照
 */

#import <Foundation/Foundation.h>
#if __has_include(<AVFoundation/AVFoundation.h>)
#import "MNCapturePhoto.h"

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
 - MNMovieSizeRatioUnknown: 默认未知
 - MNMovieSizeRatio9x16: 9/16
 - MNMovieSizeRatio3x4: 3/4
 */
typedef NS_ENUM(NSInteger, MNMovieSizeRatio) {
    MNMovieSizeRatioUnknown = 0,
    MNMovieSizeRatio9x16,
    MNMovieSizeRatio3x4
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
 - MNMovieOrientationAuto: 拍摄方向即预览方向
 - MNMovieOrientationPortrait: 竖向预览 Home键处于下方
 - MNMovieOrientationLandscape: 横向预览 Home键处于右方
 */
typedef NS_ENUM(NSInteger, MNMovieOrientation) {
    MNMovieOrientationAuto = 0,
    MNMovieOrientationPortrait,
    MNMovieOrientationLandscape
};

NS_ASSUME_NONNULL_BEGIN

@class MNMovieRecorder;
@protocol MNMovieRecordDelegate <NSObject>
@optional
/**
 会话开始运行回调
 @param recorder 录制实例
 */
- (void)movieRecorderDidStartRunning:(MNMovieRecorder *)recorder;
/**
 会话结束运行回调
 @param recorder 录制实例
 */
- (void)movieRecorderDidStopRunning:(MNMovieRecorder *)recorder;
/**
 已开始录制回调
 @param recorder 录制实例
 */
- (void)movieRecorderDidStartRecording:(MNMovieRecorder *)recorder;
/**
 已结束录制回调
 @param recorder 录制实例
 */
- (void)movieRecorderDidFinishRecording:(MNMovieRecorder *)recorder;
/**
 已取消录制回调
 @param recorder 录制实例
 */
- (void)movieRecorderDidCancelRecording:(MNMovieRecorder *)recorder;
/**
 改变闪光灯状态回调
 @param recorder 录制实例
 @param error 错误信息
 */
- (void)movieRecorderDidChangeFlashScene:(MNMovieRecorder *)recorder error:(NSError *_Nullable)error;
/**
 改变手电筒状态回调
 @param recorder 录制实例
 @param error 错误信息
 */
- (void)movieRecorderDidChangeTorchScene:(MNMovieRecorder *)recorder error:(NSError *_Nullable)error;
/**
 改变会话预设回调
 @param recorder 录制实例
 @param error 错误信息
 */
- (void)movieRecorderDidChangeSessionPreset:(MNMovieRecorder *)recorder error:(NSError *_Nullable)error;
/**
 拍照前询问是否使用闪光灯
 @param recorder 录制实例
 @return 回答是否使用闪光灯
 */
- (BOOL)movieRecorderTakingPhotoShouldUsingFlash:(MNMovieRecorder *)recorder;
/**
 开始拍照回调
 @param recorder 录制实例
 @param isLivePhoto 是否是LivePhoto拍摄
 */
- (void)movieRecorder:(MNMovieRecorder *)recorder didBeginTakingPhoto:(BOOL)isLivePhoto;
/**
 已获取LivePhoto瞬时照片回调
 @param recorder 录制实例
 @param photo 瞬时照片
 */
- (void)movieRecorder:(MNMovieRecorder *)recorder didTakingLiveStillImage:(MNCapturePhoto *)photo;
/**
 拍照结果回调
 @param photo 照片
 @param error 错误信息
 */
- (void)movieRecorderDidTakingPhoto:(MNCapturePhoto *_Nullable)photo error:(NSError *_Nullable)error;
/**
 错误回调
 @param recorder 录制实例
 @param error 错误信息
 */
- (void)movieRecorder:(MNMovieRecorder *)recorder didFailWithError:(NSError *_Nullable)error;
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
/**图像预览层*/
@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
/**捕获质量*/
@property (nonatomic, copy) AVCaptureSessionPreset sessionPreset;
/**捕获尺寸比例*/
@property (nonatomic, readonly) MNMovieSizeRatio presetSizeRatio;
/**事件回调*/
@property (nonatomic, weak, nullable) id<MNMovieRecordDelegate> delegate;
/**静音拍照*/
@property (nonatomic, getter=isMuteTaking) BOOL muteTaking;
/**是否在录制*/
@property (nonatomic, readonly) BOOL isRecording;
/**是否在获取*/
@property (nonatomic, readonly) BOOL isRunning;
/**是否打开了手电筒*/
@property (nonatomic, readonly) BOOL isTorchScene;
/**是否打开了闪光灯*/
@property (nonatomic, readonly) BOOL isFlashScene;

/**
 实例化视频录制实例
 @param URL 视频输出路径
 @return 视频录制实例
 */
- (instancetype)initWithURL:(NSURL *_Nullable)URL;

/**
 实例化视频录制实例
 @param delegate 事件代理
 @return 视频录制实例
 */
- (instancetype)initWithDelegate:(id<MNMovieRecordDelegate> _Nullable)delegate;

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
- (void)prepareTaking;

#pragma mark - 捕获
- (void)startRunning;
- (void)stopRunning;

#pragma mark - 拍照
- (void)takePhoto;
#ifdef __IPHONE_10_0
/**拍摄LivePhoto前需要对会话单独配置*/
- (void)startTakingLivePhoto;
/**拍摄LivePhoto*/
- (void)takeLivePhoto;
/**恢复会话配置*/
- (void)stopTakingLivePhoto;
#endif

#pragma mark - 开始/停止/删除
- (void)startRecording;
- (void)stopRecording;
- (void)cancelRecording;
- (BOOL)deleteRecording;

#pragma mark - 手电筒
- (void)openTorch;
- (void)closeTorch;

#pragma mark - 闪光灯
- (void)openFlash;
- (void)closeFlash;

#pragma mark - 摄像头
- (void)convertCameraWithCompletionHandler:(void(^_Nullable)(NSError *_Nullable error))completionHandler;
- (void)convertCameraPosition:(MNMovieDevicePosition)capturePosition completionHandler:(void(^_Nullable)(NSError *_Nullable error))completionHandler;

#pragma mark - 对焦
- (BOOL)setFocus:(CGPoint)point;

#pragma mark - 曝光
- (BOOL)setExposure:(CGPoint)point;

#pragma mark - -缩放
- (BOOL)setZoomFactor:(CGFloat)factor withRate:(float)rate;
- (BOOL)cancelZoom;

@end

NS_ASSUME_NONNULL_END
#endif
