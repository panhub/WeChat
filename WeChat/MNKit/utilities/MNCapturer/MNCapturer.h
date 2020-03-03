/* @project  __PROJECTNAME__
 *  @header  __FILENAME__
 *  @date  __DATE__
 *  @copyright  __COPYRIGHT__
 *  @author  小斯
 *  @brief  视频录制/拍照
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MNCaptureResizeMode) {
    MNCaptureResizeModeResize = 0,
    MNCaptureResizeModeResizeAspect,
    MNCaptureResizeModeResizeAspectFill
};

typedef NS_ENUM(NSInteger, MNCaptureCameraPosition) {
    MNCaptureCameraPositionBack = 0,
    MNCaptureCameraPositionFront
};

@class MNCapturer;
@protocol MNCapturerDelegate <NSObject>
@optional
- (void)capturer:(MNCapturer *)capturer didStartCapturingWithContentsOfFile:(NSString *)filePath;
- (void)capturer:(MNCapturer *)capturer didFinishCapturingWithContentsOfFile:(NSString *)filePath;
- (void)capturer:(MNCapturer *)capturer didCapturingFailure:(NSString *)message;
@end

@interface MNCapturer : NSObject
/**视频拉伸方式*/
@property (nonatomic) MNCaptureResizeMode resizeMode;
/**摄像头*/
@property (nonatomic, readonly) MNCaptureCameraPosition capturePosition;
/**录制时长时长*/
@property (nonatomic, readonly) Float64 duration;
/**文件地址*/
@property (nonatomic, copy) NSString *filePath;
/**图像输入*/
@property (nonatomic, weak) UIView *outputView;
/**事件回调*/
@property (nonatomic, weak) id<MNCapturerDelegate> delegate;
/**是否在录制*/
@property (nonatomic, readonly, getter=isRecording) BOOL recording;
/**是否在获取*/
@property (nonatomic, readonly, getter=isRunning) BOOL running;

- (instancetype)initWithContentsOfFile:(NSString *)filePath;

#pragma mark - Instance
+ (instancetype)recorder;

#pragma mark - 捕获
- (void)startRunning;
- (void)stopRunning;

#pragma mark - 开始/停止/删除
- (void)startCapturing;
- (void)stopCapturing;
- (BOOL)deleteCapturing;

#pragma mark - 手电筒控制
- (BOOL)openLighting;
- (BOOL)closeLighting;

#pragma mark - 转换镜头方向
- (BOOL)convertCapturePosition;
- (BOOL)setDeviceCapturePosition:(MNCaptureCameraPosition)capturePosition;

#pragma mark - 对焦
- (BOOL)setFocusPoint:(CGPoint)point;

#pragma mark - 拍照
- (void)captureStillImageAsynchronously:(void(^)(UIImage *image))completion;

@end

