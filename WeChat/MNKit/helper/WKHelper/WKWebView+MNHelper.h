//
//  WKWebView+MNHelper.h
//  MNFoundation
//
//  Created by Vicent on 2020/11/9.
//

#if __has_include(<WebKit/WebKit.h>)
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (MNHelper)

/**
 截取网页快照
 @param completionHandler 结束回调
 */
- (void)snapshotImageHierarchyAfterScreenUpdates:(void(^)(UIImage *_Nullable))completionHandler;

/**
 禁止长按
 */
- (void)setTouchCalloutDisabled;

/**
 禁止选择
 */
- (void)setUserSelectDisabled;

@end

NS_ASSUME_NONNULL_END
#endif
