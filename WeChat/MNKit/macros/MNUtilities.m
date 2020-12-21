//
//  MNUtilities.m
//  MNKit
//
//  Created by 冯盼 on 2019/10/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNUtilities.h"

UIViewContentMode UIViewContentModeFromGravity(CALayerContentsGravity gravity) {
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{ kCAGravityCenter:@(UIViewContentModeCenter),
                 kCAGravityTop:@(UIViewContentModeTop),
                 kCAGravityBottom:@(UIViewContentModeBottom),
                 kCAGravityLeft:@(UIViewContentModeLeft),
                 kCAGravityRight:@(UIViewContentModeRight),
                 kCAGravityTopLeft:@(UIViewContentModeTopLeft),
                 kCAGravityTopRight:@(UIViewContentModeTopRight),
                 kCAGravityBottomLeft:@(UIViewContentModeBottomLeft),
                 kCAGravityBottomRight:@(UIViewContentModeBottomRight),
                 kCAGravityResize:@(UIViewContentModeScaleToFill),
                 kCAGravityResizeAspect:@(UIViewContentModeScaleAspectFit),
                 kCAGravityResizeAspectFill:@(UIViewContentModeScaleAspectFill) };
    });
    if (!gravity) return UIViewContentModeScaleToFill;
    return (UIViewContentMode)((NSNumber *)dic[gravity]).integerValue;
}

CALayerContentsGravity CALayerContentsGravityFromMode(UIViewContentMode contentMode) {
    switch (contentMode) {
        case UIViewContentModeScaleToFill: return kCAGravityResize;
        case UIViewContentModeScaleAspectFit: return kCAGravityResizeAspect;
        case UIViewContentModeScaleAspectFill: return kCAGravityResizeAspectFill;
        case UIViewContentModeRedraw: return kCAGravityResize;
        case UIViewContentModeCenter: return kCAGravityCenter;
        case UIViewContentModeTop: return kCAGravityTop;
        case UIViewContentModeBottom: return kCAGravityBottom;
        case UIViewContentModeLeft: return kCAGravityLeft;
        case UIViewContentModeRight: return kCAGravityRight;
        case UIViewContentModeTopLeft: return kCAGravityTopLeft;
        case UIViewContentModeTopRight: return kCAGravityTopRight;
        case UIViewContentModeBottomLeft: return kCAGravityBottomLeft;
        case UIViewContentModeBottomRight: return kCAGravityBottomRight;
        default: return kCAGravityResize;
    }
}

void UIKeyboardWillChangeFrameConvert (NSNotification *notification, void(^completion)(CGRect from, CGRect to, CGFloat duration, UIViewAnimationOptions options)) {
    NSDictionary *userInfo = notification.userInfo;
    CGRect _from = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect _to = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat _duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions _options = ([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16 ) | UIViewAnimationOptionBeginFromCurrentState;
    if (completion) {
        completion(_from, _to, _duration, _options);
    }
}

NSUInteger __IPHONE (CGFloat verson) {
    NSString *string = [NSString stringWithFormat:@"%.1f", verson];
    NSArray <NSString *>*components = [string componentsSeparatedByString:@"."];
    NSUInteger v = components.firstObject.intValue*10000;
    if (components.count > 1) {
        v += (components[1].intValue*100);
    }
    return v;
}

BOOL __IPHONE_MAX_ALLOWED (CGFloat verson) {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    return __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE(verson);
#endif
    return NO;
}
