//
//  MNVideoTailorController.h
//  MNKit
//
//  Created by Vicent on 2020/7/29.
//  视频裁剪 

#import "MNBaseViewController.h"
@class MNVideoTailorController;

@protocol MNVideoTailorDelegate <NSObject>
@optional;
/**关闭事件回调*/
- (void)videoTailorControllerDidCancel:(MNVideoTailorController *_Nonnull)tailorController;
/**裁剪结束回调*/
- (void)videoTailorController:(MNVideoTailorController *_Nonnull)tailorController didTailoringVideoAtPath:(NSString *_Nonnull)videoPath;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MNVideoTailorController : MNBaseViewController

/**指定视频路径*/
@property (nonatomic, copy) NSString *videoPath;

/**截图*/
@property (nonatomic, copy) UIImage *thumbnail;

/**指定视频时长*/
@property (nonatomic) NSTimeInterval duration;

/**指定视频尺寸*/
@property (nonatomic) CGSize naturalSize;

/**指定视频裁剪后保存位置*/
@property (nonatomic, copy, nullable) NSString *outputPath;

/**导出视频的最小时长<视频裁剪选项>*/
@property (nonatomic) NSTimeInterval minTailorDuration;

/**导出视频的最大时长<视频裁剪选项>*/
@property (nonatomic) NSTimeInterval maxTailorDuration;

/**是否允许调整视频尺寸<视频裁剪选项>*/
@property (nonatomic, getter=isAllowsResizeSize) BOOL allowsResizeSize;

/**导出后是否删除原视频*/
@property (nonatomic, getter=isDeleteVideoWhenFinish) BOOL deleteVideoWhenFinish;

/**裁剪结束代理*/
@property (nonatomic, weak, nullable) id<MNVideoTailorDelegate> delegate;

/**关闭按钮回调*/
@property (nonatomic, copy, nullable) void(^didCancelHandler) (MNVideoTailorController *vc);

/**裁剪完成回调*/
@property (nonatomic, copy, nullable) void(^didTailoringVideoHandler) (MNVideoTailorController *vc, NSString *videoPath);

/**
 依据视频路径实例化
 @param videoPath 视频路径
 @return 视频裁剪控制器
 */
- (instancetype)initWithVideoPath:(NSString *)videoPath;

@end

NS_ASSUME_NONNULL_END
