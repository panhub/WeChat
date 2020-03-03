//
//  WXVideoCropView.m
//  KPoint
//
//  Created by 小斯 on 2019/8/19.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "WXVideoCropView.h"

@interface WXVideoCropView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
/// 最大时长
@property (nonatomic) NSTimeInterval duration;
/// 播放指针
@property (nonatomic, strong) UIView *pointer;
/// 上分割线
@property (nonatomic, strong) UIView *topSeparator;
/// 下分割线
@property (nonatomic, strong) UIView *bottomSeparator;
/// 左阴影
@property (nonatomic, strong) UIView *leftShadowView;
/// 右阴影
@property (nonatomic, strong) UIView *rightShadowView;
/// 左滑手
@property (nonatomic, strong) UIImageView *leftHandler;
/// 右滑手
@property (nonatomic, strong) UIImageView *rightHandler;
/// 帧预览
@property (nonatomic, strong) UIScrollView *scrollView;
/// 缩略图
@property (nonatomic, strong) UIImageView *imageView;
/// 标记是否在拖拽
@property (nonatomic) BOOL dragging;
/// 左后滑手间隔
@property (nonatomic) CGFloat margin;
/// 最大裁剪时长
@property (nonatomic) NSTimeInterval maxTimeInterval;
@end

/// 视频最小裁剪时长
#define ZMVideoCropMinDuration  3.f

@implementation WXVideoCropView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.maxTimeInterval = 15.f;
        self.backgroundColor = UIColor.clearColor;
        [self createView];
    }
    return self;
}

- (void)createView {
    /// 缩略图
    UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:self.bounds delegate:self];
    scrollView.scrollEnabled = NO;
    scrollView.backgroundColor = UIColor.clearColor;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
    imageView.height_mn = scrollView.height_mn;
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = UIColor.clearColor;
    [scrollView addSubview:imageView];
    self.imageView = imageView;
    
    /// 左右滑手
    UIImage *image = [UIImage imageNamed:@"wx_video_cut_left_handler"];
    CGSize size = CGSizeMultiplyToHeight(image.size, self.height_mn);
    size.width = round(size.width);
    UIImageView *leftHandler = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:image];
    leftHandler.contentMode = UIViewContentModeScaleAspectFill;
    [leftHandler.layer setMaskRadius:8.f/image.size.height*leftHandler.height_mn byCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft];
    [self addSubview:leftHandler];
    self.leftHandler = leftHandler;
    UIImageView *rightHandler = leftHandler.viewCopy;
    rightHandler.right_mn = self.width_mn;
    rightHandler.image = [UIImage imageNamed:@"wx_video_cut_right_handler"];
    [rightHandler.layer setMaskRadius:8.f/image.size.height*rightHandler.height_mn byCorners:UIRectCornerTopRight|UIRectCornerBottomRight];
    [self addSubview:rightHandler];
    self.rightHandler = rightHandler;
    [leftHandler addGestureRecognizer:UIPanGestureRecognizerCreate(self, @selector(handPanGestureEvent:), self)];
    [rightHandler addGestureRecognizer:UIPanGestureRecognizerCreate(self, @selector(handPanGestureEvent:), self)];
    
    scrollView.contentInset = UIEdgeInsetsMake(0.f, leftHandler.width_mn, 0.f, rightHandler.width_mn);
    
    UIView *leftMaskView = [[UIView alloc] initWithFrame:leftHandler.frame];
    leftMaskView.backgroundColor = UIColor.whiteColor;
    [self insertSubview:leftMaskView belowSubview:leftHandler];
    
    UIView *rightMaskView = [[UIView alloc] initWithFrame:rightHandler.frame];
    rightMaskView.backgroundColor = UIColor.whiteColor;
    [self insertSubview:rightMaskView belowSubview:rightHandler];
    
    /// 左右阴影
    UIView *leftShadowView = [[UIView alloc] initWithFrame:CGRectMake(leftHandler.width_mn, 0.f, 0.f, self.height_mn)];
    leftShadowView.userInteractionEnabled = NO;
    leftShadowView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.45f];
    [self insertSubview:leftShadowView belowSubview:leftHandler];
    self.leftShadowView = leftShadowView;
    UIView *rightShadowView = leftShadowView.viewCopy;
    rightShadowView.right_mn = rightHandler.left_mn;
    [self insertSubview:rightShadowView belowSubview:leftHandler];
    self.rightShadowView = rightShadowView;
    
    /// 上下分割线
    UIView *topSeparator = [[UIView alloc] initWithFrame:CGRectMake(leftHandler.right_mn, 0.f, rightHandler.left_mn - leftHandler.right_mn, 2.f)];
    topSeparator.backgroundColor = THEME_COLOR;
    [self addSubview:topSeparator];
    self.topSeparator = topSeparator;
    UIView *bottomSeparator = topSeparator.viewCopy;
    bottomSeparator.bottom_mn = self.height_mn;
    [self addSubview:bottomSeparator];
    self.bottomSeparator = bottomSeparator;
    
    /// 进度指针
    UIView *pointer = [[UIView alloc] initWithFrame:CGRectMake(leftHandler.right_mn, 0.f, 3.f, bottomSeparator.top_mn - topSeparator.bottom_mn - 1.f)];
    pointer.centerY_mn = self.height_mn/2.f;
    pointer.backgroundColor = THEME_COLOR;
    //UIViewSetCornerRadius(pointer, pointer.width_mn/2.f);
    UIViewSetBorderRadius(pointer, pointer.width_mn/2.f, .5f, UIColor.darkTextColor);
    [self insertSubview:pointer belowSubview:leftHandler];
    self.pointer = pointer;
}

- (void)resetSubviews {
    self.leftHandler.left_mn = 0.f;
    self.rightHandler.right_mn = self.width_mn;
    self.pointer.centerX_mn = self.leftHandler.right_mn;
    self.scrollView.contentOffset = CGPointMake(-self.scrollView.contentInset.left, 0.f);
    self.leftShadowView.width_mn = self.rightShadowView.width_mn = 0.f;
    self.leftShadowView.left_mn = self.scrollView.contentInset.left;
    self.rightShadowView.right_mn = self.width_mn - self.scrollView.contentInset.right;
    self.topSeparator.left_mn = self.bottomSeparator.left_mn = self.leftHandler.right_mn;
    self.topSeparator.width_mn = self.bottomSeparator.width_mn = self.rightHandler.left_mn - self.leftHandler.right_mn;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragging = YES;
    self.pointer.centerX_mn = self.leftHandler.right_mn;
    if ([self.delegate respondsToSelector:@selector(videoCropViewWillBeginDragging:)]) {
        [self.delegate videoCropViewWillBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(videoCropViewLeftHandlerDidDragging:)]) {
        [self.delegate videoCropViewLeftHandlerDidDragging:self];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    /// 减速未停止又滑动不做操作
    if (scrollView.isDragging) return;
    self.dragging = NO;
    if ([self.delegate respondsToSelector:@selector(videoCropViewLeftHandlerDidEndDragging:)]) {
        [self.delegate videoCropViewLeftHandlerDidEndDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(videoCropViewShouldBeginDragging:)]) {
        return [self.delegate videoCropViewShouldBeginDragging:self];
    }
    return self.scrollView.scrollEnabled;
}

#pragma mark - Event
- (void)handPanGestureEvent:(UIPanGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    UIGestureRecognizerState state = recognizer.state;
    if (state == UIGestureRecognizerStateBegan) {
        [self scrollViewWillBeginDragging:self.scrollView];
    } else if (state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer translationInView:view];
        [recognizer setTranslation:CGPointZero inView:view];
        view.left_mn += point.x;
        if (view == self.leftHandler) {
            if (view.left_mn <= 0.f) {
                view.left_mn = 0.f;
            } else if (view.right_mn >= (self.rightHandler.left_mn - _margin)) {
                view.right_mn = (self.rightHandler.left_mn - _margin);
            }
            self.leftShadowView.width_mn = view.right_mn - self.leftShadowView.left_mn;
            self.pointer.centerX_mn = view.right_mn;
        } else {
            if (view.left_mn <= (self.leftHandler.right_mn + _margin)) {
                view.left_mn = (self.leftHandler.right_mn + _margin);
            } else if (view.right_mn >= self.width_mn) {
                view.right_mn = self.width_mn;
            }
            self.rightShadowView.left_mn = view.left_mn;
            self.rightShadowView.width_mn = self.width_mn - view.left_mn - view.width_mn;
            self.pointer.centerX_mn = view.left_mn;
        }
        self.topSeparator.left_mn = self.bottomSeparator.left_mn = self.leftHandler.right_mn;
        self.topSeparator.width_mn = self.bottomSeparator.width_mn = self.rightHandler.left_mn - self.leftHandler.right_mn;
        if (view == self.leftHandler && [self.delegate respondsToSelector:@selector(videoCropViewLeftHandlerDidDragging:)]) {
            [self.delegate videoCropViewLeftHandlerDidDragging:self];
        } else if (view == self.rightHandler && [self.delegate respondsToSelector:@selector(videoCropViewRightHandlerDidDragging:)]) {
            [self.delegate videoCropViewRightHandlerDidDragging:self];
        }
    } else if (state == UIGestureRecognizerStateEnded) {
        self.dragging = NO;
        if (view == self.leftHandler && [self.delegate respondsToSelector:@selector(videoCropViewLeftHandlerDidEndDragging:)]) {
            [self.delegate videoCropViewLeftHandlerDidEndDragging:self];
        } else if (view == self.rightHandler && [self.delegate respondsToSelector:@selector(videoCropViewRightHandlerDidEndDragging:)]) {
            [self.delegate videoCropViewRightHandlerDidEndDragging:self];
        }
    } else if (state == UIGestureRecognizerStateChanged) {
        self.dragging = NO;
    }
}

- (void)resizingCropFragmentToDuration:(CGFloat)duration {
    if (self.duration < duration || self.alpha < 1.f) return;
    [self scrollViewWillBeginDragging:self.scrollView];
    [self resetSubviews];
    CGFloat x = duration/self.duration*self.imageView.width_mn;
    self.rightHandler.left_mn = self.leftHandler.right_mn + x;
    self.rightShadowView.left_mn = self.rightHandler.left_mn;
    self.rightShadowView.width_mn = self.width_mn - self.scrollView.contentInset.right - self.rightShadowView.left_mn;
    self.topSeparator.width_mn = self.bottomSeparator.width_mn = self.rightHandler.left_mn - self.leftHandler.right_mn;
    [self scrollViewDidEndDecelerating:self.scrollView];
}

#pragma mark - Setter
- (void)setVideoPath:(NSString *)videoPath {
    _videoPath = videoPath.copy;
    if ([self.delegate respondsToSelector:@selector(videoCropViewWillLoadThumbnails:)]) {
        [self.delegate videoCropViewWillLoadThumbnails:self];
    }
    self.alpha = 0.f;
    [self resetSubviews];
    // 计算视频长度, 截图个数
    CGSize size = [MNAssetExporter exportNaturalSizeOfVideoAtPath:videoPath];
    CGFloat duration = [MNAssetExporter exportMediaDurationWithContentsOfPath:videoPath];
    self.duration = duration;
    CGFloat width = self.scrollView.width_mn - self.scrollView.contentInset.left - self.scrollView.contentInset.right;
    CGFloat multiply = width/self.maxTimeInterval;
    self.margin = MIN(ZMVideoCropMinDuration*multiply, width);
    width = MAX(width, multiply*duration);
    self.imageView.width_mn = width;
    self.scrollView.contentSize = self.imageView.size_mn;
    size = CGSizeMultiplyToHeight(size, self.imageView.height_mn);
    NSUInteger count = ceil(width/size.width);
    size = CGSizeMultiplyByRatio(size, UIScreen.mainScreen.scale);
    // 制作截图
    @weakify(self);
    dispatch_async_default(^{
        NSMutableArray <UIImage *>*thumbnailArray = NSMutableArray.new;
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath]
                                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        AVAssetImageGenerator *thumbnailGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
        thumbnailGenerator.appliesPreferredTrackTransform = YES;
        thumbnailGenerator.maximumSize = size;
        for (NSInteger i = 0; i < count; i ++) {
            CGFloat progress = i*1.f/count;
            CGImageRef imageRef = [thumbnailGenerator copyCGImageAtTime:CMTimeMultiplyByFloat64(videoAsset.duration, progress) actualTime:NULL error:NULL];
            if (imageRef) [thumbnailArray addObject:[UIImage imageWithCGImage:imageRef]];
        }
        if (thumbnailArray.count <= 0) {
            dispatch_async_main(^{
                if ([self.delegate respondsToSelector:@selector(videoCropViewLoadThumbnailsFailure:)]) {
                    [self.delegate videoCropViewLoadThumbnailsFailure:self];
                }
            });
            return;
        }
        // 合成图片
        UIImage *image = thumbnailArray.firstObject;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width*thumbnailArray.count, image.size.height), NO, 1.f);
        for (NSInteger i = 0; i < thumbnailArray.count; i++) {
            image = thumbnailArray[i];
            [image drawInRect:CGRectMake(image.size.width*i, 0.f, image.size.width, image.size.height)];
        }
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async_main(^{
            @strongify(self);
            if (image) {
                self.imageView.image = image;
                self.scrollView.scrollEnabled = YES;
                [UIView animateWithDuration:.25f animations:^{
                    self.alpha = 1.f;
                } completion:^(BOOL finished) {
                    if ([self.delegate respondsToSelector:@selector(videoCropViewLoadThumbnailsFinish:)]) {
                        [self.delegate videoCropViewLoadThumbnailsFinish:self];
                    }
                }];
            } else {
                if ([self.delegate respondsToSelector:@selector(videoCropViewLoadThumbnailsFailure:)]) {
                    [self.delegate videoCropViewLoadThumbnailsFailure:self];
                }
            }
        });
    });
}

- (void)setProgress:(float)progress {
    if (self.isDragging) return;
    CGFloat leftProgress = self.leftProgress;
    if (progress <= leftProgress) {
        self.pointer.centerX_mn = self.leftHandler.right_mn;
        return;
    }
    CGFloat w = self.imageView.width_mn;
    CGFloat x = (progress - leftProgress)*w;
    self.pointer.centerX_mn = self.leftHandler.right_mn + x;
    if (self.pointer.centerX_mn >= self.rightHandler.left_mn) {
        self.pointer.centerX_mn = self.rightHandler.left_mn;
        if ([self.delegate respondsToSelector:@selector(videoCropViewDidEndLimiting:)]) {
            [self.delegate videoCropViewDidEndLimiting:self];
        }
    }
}

#pragma mark - Getter
- (float)leftProgress {
    CGFloat x = self.leftHandler.right_mn + self.scrollView.contentOffset.x;
    CGFloat w = self.imageView.width_mn;
    CGFloat progress = x/w;
    if (isnan(progress)) return 0.f;
    return MAX(progress, 0.f);
}

- (float)rightProgress {
    CGFloat x = self.scrollView.contentOffset.x + self.rightHandler.left_mn;
    CGFloat w = self.imageView.width_mn;
    CGFloat progress = x/w;
    if (isnan(progress)) return 1.f;
    return MIN(progress, 1.f);
}

- (MNRange)cropRange {
    return MNRangeMake(self.leftProgress, self.rightProgress - self.leftProgress);
}

@end
