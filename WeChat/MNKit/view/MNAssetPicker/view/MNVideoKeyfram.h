//
//  MNVideoKeyfram.h
//  MNKit
//
//  Created by Vicent on 2020/8/1.
//  视频关键帧视图

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNVideoKeyframAlignment) {
    MNVideoKeyframAlignmentLeft = 0, // 保持左对齐
    MNVideoKeyframAlignmentRight // 保持右对齐
};

/**动画视图*/
UIKIT_EXTERN const NSTimeInterval MNVideoKeyframAnimationDuration;

NS_ASSUME_NONNULL_BEGIN

@interface MNVideoKeyfram : UIView

/**内容大小*/
@property (nonatomic) CGSize contentSize;

/**对齐方式*/
@property (nonatomic) MNVideoKeyframAlignment alignment;

/**关键帧视图*/
@property (nonatomic, copy) UIImage *image;

/**
 调整图片宽度
 @param width 宽度
 */
- (void)setImageToWidth:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
