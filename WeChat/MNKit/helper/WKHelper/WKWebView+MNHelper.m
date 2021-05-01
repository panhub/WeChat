//
//  WKWebView+MNHelper.m
//  MNFoundation
//
//  Created by Vicent on 2020/11/9.
//

#import "WKWebView+MNHelper.h"

@interface UIImage (WKWebViewSnapshot)
@property (nonatomic) CGRect snapshotRect;
@end

@implementation UIImage (WKWebViewSnapshot)
- (void)setSnapshotRect:(CGRect)snapshotRect {
    objc_setAssociatedObject(self, @"com.mn.web.view.snapshot.rect", [NSValue valueWithCGRect:snapshotRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGRect)snapshotRect {
    NSValue *value = objc_getAssociatedObject(self, @"com.mn.web.view.snapshot.rect");
    if (value) return [value CGRectValue];
    return CGRectZero;
}

@end

@implementation WKWebView (MNHelper)

- (void)snapshotImageHierarchyAfterScreenUpdates:(void(^)(UIImage *_Nullable))completionHandler {
    
    UIView *snapshotView = [self snapshotViewAfterScreenUpdates:YES];
    [self.superview insertSubview:snapshotView aboveSubview:self];
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    
    NSMutableArray <UIImage *>*container = @[].mutableCopy;
    
    __weak typeof(self) weakself = self;
    [self snapshotImagesFromOffsetY:0.f container:container completion:^{
        weakself.scrollView.contentOffset = contentOffset;
        [snapshotView removeFromSuperview];
        if (container.count) {
            //生成最终图像
            UIImage *lastImage = container.lastObject;
            CGRect snapshotRect = lastImage.snapshotRect;
            CGSize contextSize = CGSizeMake(snapshotRect.size.width*lastImage.scale, CGRectGetMaxY(snapshotRect)*lastImage.scale);
            UIGraphicsBeginImageContextWithOptions(contextSize, NO, lastImage.scale);
            for (UIImage *image in container) {
                snapshotRect = image.snapshotRect;
                [image drawInRect:CGRectMake(0.f, snapshotRect.origin.y*image.scale, contextSize.width, snapshotRect.size.height*image.scale)];
            }
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (completionHandler) completionHandler(image);
        } else {
            if (completionHandler) completionHandler(nil);
        }
    }];
}

- (void)snapshotImagesFromOffsetY:(CGFloat)offsetY container:(NSMutableArray <UIImage *>*)container completion:(void(^)(void))completion {
    
    CGFloat contentHeight = self.scrollView.contentSize.height;
    
    if (offsetY >= contentHeight) {
        if (completion) completion();
        return;
    }
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    contentOffset.y = offsetY;
    self.scrollView.contentOffset = contentOffset;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
    
    CGRect drawRect = self.bounds;
    drawRect.size.height = MIN(contentHeight - offsetY, drawRect.size.height);
    
    dispatch_after(.5f, dispatch_get_main_queue(), ^{
        
        UIGraphicsBeginImageContextWithOptions(drawRect.size, NO, UIScreen.mainScreen.scale);
        [self drawViewHierarchyInRect:drawRect afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (image) {
            [container addObject:image];
            image.snapshotRect = CGRectMake(0.f, offsetY, drawRect.size.width, drawRect.size.height);
            [self snapshotImagesFromOffsetY:CGRectGetMaxY(drawRect) container:container completion:completion];
        } else {
            [container removeAllObjects];
            [self snapshotImagesFromOffsetY:CGFLOAT_MAX container:container completion:completion];
        }
    });
}

- (void)setTouchCalloutDisabled {
    [self evaluateJavaScript:@"document.documentElement.style.webkitTouchCallout='none';" completionHandler:nil];
}

- (void)setUserSelectDisabled {
    [self evaluateJavaScript:@"document.documentElement.style.webkitUserSelect='none';" completionHandler:nil];
}

@end
