//
//  MNVideoTailorView.m
//  MNKit
//
//  Created by Vicent on 2020/8/10.
//

#import "MNVideoTailorView.h"
#import "MNTailorHandler.h"
#import "UIView+MNLayout.h"
#import "MNAssetExporter+MNExportMetadata.h"

typedef NS_ENUM(NSInteger, MNTailorSeekStatus) {
    MNTailorSeekStatusNone = 0,
    MNTailorSeekStatusScrolling,
    MNTailorSeekStatusTouching
};

#define VTVideoTailorHandlerError  .5f
#define VTVideoTailorHandlerMargin  self.margin

@interface MNVideoTailorView ()<UIScrollViewDelegate, MNTailorHandlerDelegate>
/**拖拽状态*/
@property (nonatomic) MNTailorSeekStatus status;
/**指针*/
@property (nonatomic, strong) UIView *pointer;
/**滑动视图*/
@property (nonatomic, strong) UIScrollView *scrollView;
/**左阴影*/
@property (nonatomic, strong) MNVideoKeyfram *leftMaskView;
/**右阴影*/
@property (nonatomic, strong) MNVideoKeyfram *rightMaskView;
/**截图*/
@property (nonatomic, strong) MNVideoKeyfram *thumbnailView;
/**裁剪滑手*/
@property (nonatomic, strong) MNTailorHandler *tailorHandler;
/**加载中指示图*/
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation MNVideoTailorView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.minTailorDuration = 1.f;
        self.maxTailorDuration = -1.f;
        
        self.backgroundColor = MNVideoTailorBlackColor;
        
        UIEdgeInsets contentInset = UIEdgeInsetsMake(3.3f, 22.f, 3.3f, 22.f);
        
        UIScrollView *scrollView = [UIScrollView scrollViewWithFrame:UIEdgeInsetsInsetRect(self.bounds, contentInset) delegate:nil];
        scrollView.delegate = self;
        scrollView.clipsToBounds = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.backgroundColor = UIColor.blackColor;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
    
        MNVideoKeyfram *thumbnailView = [[MNVideoKeyfram alloc] initWithFrame:scrollView.bounds];
        thumbnailView.alpha = 0.f;
        thumbnailView.clipsToBounds = YES;
        thumbnailView.userInteractionEnabled = NO;
        thumbnailView.backgroundColor = UIColor.clearColor;
        [scrollView addSubview:thumbnailView];
        self.thumbnailView = thumbnailView;
        
        MNVideoKeyfram *leftMaskView = [[MNVideoKeyfram alloc] initWithFrame:scrollView.bounds];
        leftMaskView.width_mn = 0.f;
        leftMaskView.alpha = 0.f;
        leftMaskView.userInteractionEnabled = NO;
        leftMaskView.backgroundColor = UIColor.clearColor;
        [scrollView addSubview:leftMaskView];
        self.leftMaskView = leftMaskView;
        
        MNVideoKeyfram *rightMaskView = [[MNVideoKeyfram alloc] initWithFrame:scrollView.bounds];
        rightMaskView.width_mn = 0.f;
        rightMaskView.right_mn = scrollView.width_mn;
        rightMaskView.alpha = 0.f;
        rightMaskView.userInteractionEnabled = NO;
        rightMaskView.backgroundColor = UIColor.clearColor;
        [scrollView addSubview:rightMaskView];
        self.rightMaskView = rightMaskView;
        
        MNTailorHandler *tailorHandler = [[MNTailorHandler alloc] initWithFrame:self.bounds];
        tailorHandler.lineWidth = 3.f;
        tailorHandler.delegate = self;
        tailorHandler.pathColor = MNVideoTailorWhiteColor;
        tailorHandler.normalColor = MNVideoTailorBlackColor;
        tailorHandler.highlightedColor = MNVideoTailorWhiteColor;
        tailorHandler.backgroundColor = UIColor.clearColor;
        [self addSubview:tailorHandler];
        self.tailorHandler = tailorHandler;
        
        UIView *pointer = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 4.f, scrollView.height_mn)];
        pointer.alpha = 0.f;
        pointer.centerY_mn = self.height_mn/2.f;
        pointer.left_mn = scrollView.left_mn;
        pointer.userInteractionEnabled = NO;
        pointer.layer.cornerRadius = pointer.width_mn/2.f;
        pointer.layer.borderColor = MNVideoTailorBlackColor.CGColor;
        pointer.backgroundColor = MNVideoTailorWhiteColor;
        //pointer.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1.f].CGColor;
        pointer.layer.borderWidth = .8f;
        pointer.clipsToBounds = YES;
        [self addSubview:pointer];
        self.pointer = pointer;
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicatorView.color = MNVideoTailorWhiteColor;//MN_RGB(250.f);
        indicatorView.hidesWhenStopped = YES;
        indicatorView.center_mn = self.bounds_center;
        indicatorView.userInteractionEnabled = NO;
        [self addSubview:indicatorView];
        self.indicatorView = indicatorView;
    }
    return self;
}

- (void)loadThumbnails {
    // 计算时长尺寸
    NSString *videoPath = self.videoPath;
    CGSize naturalSize = [MNAssetExporter exportNaturalSizeOfVideoAtPath:videoPath];
    NSTimeInterval duration = [MNAssetExporter exportDurationWithMediaAtPath:videoPath];
    
    if (duration <= 0.f || CGSizeEqualToSize(naturalSize, CGSizeZero)) {
        // 无法计算
        if ([self.delegate respondsToSelector:@selector(tailorViewLoadThumbnailsFailed:)]) {
            [self.delegate tailorViewLoadThumbnailsFailed:self];
        }
        return;
    }

    // 开始加载截图
    [self.indicatorView startAnimating];
    if ([self.delegate respondsToSelector:@selector(tailorViewBeginLoadThumbnails:)]) {
        [self.delegate tailorViewBeginLoadThumbnails:self];
    }
    
    // 计算截图
    CGSize contentSize = self.scrollView.bounds.size;
    CGFloat minTailorDuration = MAX(1.f, MIN(self.minTailorDuration, duration - 1.f));
    CGFloat maxTailorDuration = self.maxTailorDuration <= 0.f ? duration : MAX(minTailorDuration, MIN(duration, self.maxTailorDuration));
    CGFloat multiply = MAX(1.f, duration/maxTailorDuration);
    contentSize.width = multiply*contentSize.width;
    self.scrollView.contentSize = contentSize;
    self.thumbnailView.contentSize = contentSize;
    self.leftMaskView.contentSize = contentSize;
    self.rightMaskView.contentSize = contentSize;
    self.thumbnailView.width_mn = contentSize.width;
    [self updateRightMask];
    self.thumbnailView.alignment = MNVideoKeyframAlignmentLeft;
    self.leftMaskView.alignment = MNVideoKeyframAlignmentLeft;
    self.rightMaskView.alignment = MNVideoKeyframAlignmentRight;
    if (multiply == 1.f) self.scrollView.userInteractionEnabled = NO;
    CGFloat widthByDuration = contentSize.width/duration;
    NSTimeInterval durationByWidth = duration/contentSize.width;
    self.tailorHandler.minHandlerInterval = ceil(minTailorDuration*widthByDuration);
    naturalSize = CGSizeMultiplyToHeight(naturalSize, contentSize.height);
    NSInteger thumbnailCount = ceil(duration/(durationByWidth*naturalSize.width));
    naturalSize = CGSizeMultiplyByRatio(naturalSize, UIScreen.mainScreen.scale);
    // 获取视频截图
    @weakify(self);
    dispatch_async(dispatch_get_high_queue(), ^{
        NSMutableArray <UIImage *>*thumbnailArray = @[].mutableCopy;
        AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPath]
                                                     options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@YES}];
        AVAssetImageGenerator *thumbnailGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:videoAsset];
        thumbnailGenerator.appliesPreferredTrackTransform = YES;
        thumbnailGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        thumbnailGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        thumbnailGenerator.maximumSize = naturalSize;
        for (NSInteger i = 0; i < thumbnailCount; i ++) {
            CGFloat progress = i*1.f/thumbnailCount;
            CGImageRef imageRef = [thumbnailGenerator copyCGImageAtTime:CMTimeMultiplyByFloat64(videoAsset.duration, progress) actualTime:NULL error:NULL];
            if (!imageRef) continue;
            UIImage *img = [UIImage imageWithCGImage:imageRef];
            if (!img) continue;
            [thumbnailArray addObject:img];
        }
        // 制作截图与灰色图
        UIImage *thumbnail;
        UIImage *maskImage;
        if (thumbnailArray.count > 0) {
            // 拼接截图
            UIImage *image = thumbnailArray.firstObject;
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width*thumbnailArray.count, image.size.height), NO, 1.f);
            for (NSInteger i = 0; i < thumbnailArray.count; i++) {
                image = thumbnailArray[i];
                [image drawInRect:CGRectMake(image.size.width*i, 0.f, image.size.width, image.size.height)];
            }
            thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 裁剪图片
            CGSize thumbnailSize = CGSizeMultiplyToHeight(contentSize, thumbnail.size.height);
            thumbnailSize.width = MIN(thumbnailSize.width, thumbnail.size.width);
            UIGraphicsBeginImageContext(thumbnailSize);
            [thumbnail drawInRect:(CGRect){CGPointZero, thumbnailSize}];
            UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            thumbnail = thumbnailImage;
            maskImage = thumbnailImage.grayImage;
        }
        dispatch_async_main(^{
            @strongify(self);
            if (thumbnail) {
                [self.indicatorView stopAnimating];
                self.leftMaskView.image = maskImage;
                self.rightMaskView.image = maskImage;
                self.thumbnailView.image = thumbnail;
                self.leftMaskView.alpha = self.rightMaskView.alpha = 1.f;
                __weak typeof(self) weakself = self;
                [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
                    weakself.pointer.alpha = 1.f;
                    weakself.thumbnailView.alpha = 1.f;
                    weakself.scrollView.backgroundColor = MNVideoTailorBlackColor;
                } completion:^(BOOL finished) {
                    if ([weakself.delegate respondsToSelector:@selector(tailorViewDidLoadThumbnails:)]) {
                        [weakself.delegate tailorViewDidLoadThumbnails:weakself];
                    }
                }];
            } else {
                UILabel *thumbnailLabel = [UILabel labelWithFrame:self.thumbnailView.frame text:@"无法获取视频截图" alignment:NSTextAlignmentCenter textColor:MNVideoTailorBlackColor font:[UIFont systemFontOfSize:16.f]];
                thumbnailLabel.alpha = 0.f;
                thumbnailLabel.backgroundColor = UIColor.clearColor;
                [self.scrollView addSubview:thumbnailLabel];
                [self.indicatorView stopAnimating];
                [UIView animateWithDuration:MNVideoKeyframAnimationDuration animations:^{
                    thumbnailLabel.alpha = 1.f;
                } completion:^(BOOL finished) {
                    if ([weakself.delegate respondsToSelector:@selector(tailorViewDidLoadThumbnails:)]) {
                        [weakself.delegate tailorViewDidLoadThumbnails:weakself];
                    }
                }];
            }
        });
    });
}

#pragma mark - MNTailorHandlerDelegate
/**左滑手开始拖拽*/
- (void)tailorLeftHandlerBeginDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [tailorHandler setHighlighted:YES animated:YES];
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 0.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewLeftHandlerBeginDragging:)]) {
        [self.delegate tailorViewLeftHandlerBeginDragging:self];
    }
}
/**左滑手拖拽中*/
- (void)tailorLeftHandlerDidDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [self updateLeftMask];
    if ([self.delegate respondsToSelector:@selector(tailorViewLeftHandlerDidDragging:)]) {
        [self.delegate tailorViewLeftHandlerDidDragging:self];
    }
}
/**左滑手停止拖拽*/
- (void)tailorLeftHandlerEndDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [self updateLeftMask];
    [tailorHandler inspectHighlightedAnimated:YES];
    self.pointer.left_mn = tailorHandler.leftHandler.right_mn;
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 1.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewLeftHandlerEndDragging:)]) {
        [self.delegate tailorViewLeftHandlerEndDragging:self];
    }
}
/**右滑手开始拖拽*/
- (void)tailorRightHandlerBeginDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [tailorHandler setHighlighted:YES animated:YES];
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 0.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewRightHandlerBeginDragging:)]) {
        [self.delegate tailorViewRightHandlerBeginDragging:self];
    }
}
/**右滑手拖拽中*/
- (void)tailorRightHandlerDidDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [self updateRightMask];
    if ([self.delegate respondsToSelector:@selector(tailorViewRightHandlerDidDragging:)]) {
        [self.delegate tailorViewRightHandlerDidDragging:self];
    }
}
/**右滑手拖拽中*/
- (void)tailorRightHandlerEndDragging:(MNTailorHandler *_Nonnull)tailorHandler {
    [self updateRightMask];
    [tailorHandler inspectHighlightedAnimated:YES];
    if (self.pointer.left_mn < tailorHandler.leftHandler.right_mn) {
        self.pointer.left_mn = tailorHandler.leftHandler.right_mn;
    } else if (self.pointer.right_mn > tailorHandler.rightHandler.left_mn) {
        self.pointer.right_mn = tailorHandler.rightHandler.left_mn;
    }
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 1.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewRightHandlerEndDragging:)]) {
        [self.delegate tailorViewRightHandlerEndDragging:self];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.status = MNTailorSeekStatusScrolling;
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 0.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewBeginDragging:)]) {
        [self.delegate tailorViewBeginDragging:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateLeftMask];
    [self updateRightMask];
    if (self.status != MNTailorSeekStatusScrolling) return;
    if ([self.delegate respondsToSelector:@selector(tailorViewDidDragging:)]) {
        [self.delegate tailorViewDidDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.isDragging) return;
    self.status = MNTailorSeekStatusNone;
    self.pointer.left_mn = self.tailorHandler.leftHandler.right_mn;
    [UIView animateWithDuration:MNTailorHandlerAnimationDuration animations:^{
        self.pointer.alpha = 1.f;
    }];
    if ([self.delegate respondsToSelector:@selector(tailorViewEndDragging:)]) {
        [self.delegate tailorViewEndDragging:self];
    }
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    UIEdgeInsets contentInset = self.tailorHandler.borderInset;
    contentInset.left = self.tailorHandler.leftHandler.right_mn;
    contentInset.right = self.tailorHandler.width_mn - self.tailorHandler.rightHandler.left_mn;
    if (CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, contentInset), point)) {
        self.status = MNTailorSeekStatusTouching;
        if ([self.delegate respondsToSelector:@selector(tailorViewPointerBeginDragging:)]) {
            [self.delegate tailorViewPointerBeginDragging:self];
        }
    } else {
        self.status = MNTailorSeekStatusNone;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.status == MNTailorSeekStatusNone) return;
    UITouch *touche = touches.anyObject;
    CGPoint location = [touche locationInView:self];
    self.pointer.centerX_mn = location.x;
    self.pointer.left_mn = MAX(self.pointer.left_mn, self.tailorHandler.leftHandler.right_mn);
    self.pointer.right_mn = MIN(self.pointer.right_mn, self.tailorHandler.rightHandler.left_mn);
    if ([self.delegate respondsToSelector:@selector(tailorViewPointerDidDragging:)]) {
        [self.delegate tailorViewPointerDidDragging:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.status == MNTailorSeekStatusNone) return;
    self.status = MNTailorSeekStatusNone;
    if ([self.delegate respondsToSelector:@selector(tailorViewPointerEndDragging:)]) {
        [self.delegate tailorViewPointerEndDragging:self];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.status = MNTailorSeekStatusNone;
}

#pragma mark - 更新阴影
- (void)updateLeftMask {
    CGPoint contentOffset = self.scrollView.contentOffset;
    self.leftMaskView.width_mn = MAX(0.f, (MAX(self.tailorHandler.leftHandler.right_mn - self.scrollView.left_mn, 0.f) + contentOffset.x));
}

- (void)updateRightMask {
    CGSize contentSize = self.scrollView.contentSize;
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat w = MAX(self.scrollView.width_mn, contentSize.width) - (contentOffset.x + self.scrollView.width_mn);
    self.rightMaskView.width_mn = MAX(0.f, MAX(0.f, self.scrollView.right_mn - self.tailorHandler.rightHandler.left_mn) + w);
    self.rightMaskView.right_mn = MAX(self.scrollView.width_mn, self.thumbnailView.right_mn);
}

#pragma mark - 更新指针位置
- (void)movePointerToBegin {
    self.pointer.left_mn = self.tailorHandler.leftHandler.right_mn;
}

- (void)movePointerToEnd {
    self.pointer.right_mn = self.tailorHandler.rightHandler.left_mn;
}

#pragma mark - Setter
- (void)setMaskRadius:(CGFloat)maskRadius {
    [self.tailorHandler setHandlerRadius:maskRadius];
    [self.layer setMaskRadius:maskRadius byCorners:UIRectCornerTopRight|UIRectCornerBottomRight];
}

- (void)setProgress:(float)progress {
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat centerX = self.thumbnailView.width_mn*progress - MAX(contentOffset.x, 0.f) + self.scrollView.left_mn;
    if (centerX <= self.pointer.centerX_mn) return;
    self.pointer.centerX_mn = centerX;
    self.pointer.left_mn = MAX(self.pointer.left_mn, self.tailorHandler.leftHandler.right_mn);
    self.pointer.right_mn = MIN(self.pointer.right_mn, self.tailorHandler.rightHandler.left_mn);
    if (centerX >= self.tailorHandler.rightHandler.left_mn && [self.delegate respondsToSelector:@selector(tailorViewDidEndPlaying:)]) {
        [self.delegate tailorViewDidEndPlaying:self];
    }
}

#pragma mark - Getter
- (float)progress {
    if (fabs(self.pointer.left_mn - self.scrollView.left_mn) <= .1f && fabs(self.scrollView.contentOffset.x) <= .1f) return 0.f;
    if (fabs(self.scrollView.right_mn - self.pointer.right_mn) <= .1f && fabs(self.scrollView.contentSize.width - self.scrollView.width_mn) <= .1f) return 1.f;
    if (fabs(self.pointer.left_mn - self.tailorHandler.leftHandler.right_mn) <= .1f) return self.begin;
    if (fabs(self.pointer.right_mn - self.tailorHandler.rightHandler.left_mn) <= .1f) return self.end;
    float progress = (self.pointer.centerX_mn - self.scrollView.left_mn + MAX(self.scrollView.contentOffset.x, 0.f))/self.scrollView.contentSize.width;
    return MAX(0.f, MIN(progress, 1.f));
}

- (float)begin {
    float progress = (self.tailorHandler.leftHandler.right_mn - self.scrollView.left_mn + MAX(self.scrollView.contentOffset.x, 0.f))/self.scrollView.contentSize.width;
    return MAX(0.f, MIN(progress, 1.f));
}

- (float)end {
    float progress = (self.tailorHandler.rightHandler.left_mn - self.scrollView.left_mn + MAX(self.scrollView.contentOffset.x, 0.f))/self.scrollView.contentSize.width;
    return MAX(0.f, MIN(progress, 1.f));
}

- (BOOL)isDragging {
    return (self.status != MNTailorSeekStatusNone || self.tailorHandler.isDragging);
}

- (BOOL)isEndPlaying {
    return fabs(self.tailorHandler.rightHandler.left_mn - self.pointer.right_mn) <= .1f;
}

@end
