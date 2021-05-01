//
//  AVAssetTrack+MNExportMetadata.m
//  MNKit
//
//  Created by Vincent on 2019/12/31.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "AVAssetTrack+MNExportMetadata.h"

@implementation AVAssetTrack (MNExportMetadata)
- (CGFloat)rotateRadian {
    if (![self.mediaType isEqualToString:AVMediaTypeVideo]) return 0.f;
    CGFloat r = 0.f;
    CGAffineTransform t = self.preferredTransform;
    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        // Portrait
        r = M_PI_2;
    } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        // PortraitUpsideDown
        r = M_PI + M_PI_2;
    } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
        // LandscapeRight
        r = 0.f;
    } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        // LandscapeLeft
        r = M_PI;
    }
    return r;
}

- (CGSize)naturalSizeOfVideo {
    if (![self.mediaType isEqualToString:AVMediaTypeVideo]) return CGSizeZero;
    CGSize naturalSize = CGSizeApplyAffineTransform(self.naturalSize, self.preferredTransform);
    return CGSizeMake(fabs(naturalSize.width), fabs(naturalSize.height));
}

- (CGAffineTransform)positiveTransform {
    if (![self.mediaType isEqualToString:AVMediaTypeVideo]) return CGAffineTransformIdentity;
    CGFloat angle = 0.f;
    CGAffineTransform transform = self.preferredTransform;
    if (transform.b == 1 && transform.c == -1) {
        angle = M_PI_2;
    } else if (transform.a == -1 && transform.d == -1) {
        angle = M_PI;
    } else if (transform.b == -1 && transform.c == 1) {
        angle = M_PI_2*3.f;
    }
    return CGAffineTransformMakeRotation(angle);
}

- (CGAffineTransform)transformWithRenderSize:(CGSize)renderSize {
    CGSize naturalSize = self.naturalSizeOfVideo;
    if (CGSizeEqualToSize(naturalSize, CGSizeZero)) return CGAffineTransformIdentity;
    return [self transformWithRect:(CGRect){CGPointZero, naturalSize} renderSize:renderSize];
}

- (CGAffineTransform)transformWithRect:(CGRect)outputRect renderSize:(CGSize)renderSize {
    CGSize naturalSize = self.naturalSizeOfVideo;
    if (CGSizeEqualToSize(naturalSize, CGSizeZero)) return CGAffineTransformIdentity;
    CGFloat angle = 0.f;
    CGFloat x = outputRect.origin.x;
    CGFloat y = outputRect.origin.y;
    CGFloat xScale = renderSize.width/outputRect.size.width;
    CGFloat yScale = renderSize.height/outputRect.size.height;
    CGAffineTransform transform = self.preferredTransform;
    if (transform.b == 1 && transform.c == -1) {
        angle = M_PI_2;
        x = naturalSize.width - x;
        y = -y;
    } else if (transform.a == -1 && transform.d == -1) {
        angle = M_PI;
        x = naturalSize.width - x;
        y = naturalSize.height - y;
    } else if (transform.b == -1 && transform.c == 1) {
        angle = M_PI_2*3.f;
        x = -x;
        y = naturalSize.height - y;
    } else {
        angle = 0.f;
        x = -x;
        y = -y;
    }
    CGAffineTransform videoTransform = CGAffineTransformMakeRotation(angle);
    videoTransform = CGAffineTransformConcat(videoTransform, CGAffineTransformMakeScale(xScale, yScale));
    videoTransform = CGAffineTransformConcat(videoTransform, CGAffineTransformMakeTranslation(x*xScale, y*yScale));
    return videoTransform;
}

@end
