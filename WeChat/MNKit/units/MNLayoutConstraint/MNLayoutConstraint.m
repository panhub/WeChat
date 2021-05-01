//
//  MNLayoutConstraint.m
//  WeChat
//
//  Created by Vicent on 2020/3/6.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNLayoutConstraint.h"
#import <objc/runtime.h>

@implementation MNLayoutConstraint
@synthesize widthEqual = _widthEqual;
@synthesize widthEqualToView = _widthEqualToView;
@synthesize leftEqual = _leftEqual;
@synthesize leftOffsetToView = _leftOffsetToView;
@synthesize leftSpaceToView = _leftSpaceToView;
@synthesize leftEqualToView = _leftEqualToView;
@synthesize rightEqual = _rightEqual;
@synthesize rightSpaceToView = _rightSpaceToView;
@synthesize rightOffsetToView = _rightOffsetToView;
@synthesize rightEqualToView = _rightEqualToView;
@synthesize centerXEqual = _centerXEqual;
@synthesize centerXOffsetToView = _centerXOffsetToView;
@synthesize centerXEqualToView = _centerXEqualToView;
@synthesize heightEqual = _heightEqual;
@synthesize heightEqualToView = _heightEqualToView;
@synthesize topEqual = _topEqual;
@synthesize topOffsetToView = _topOffsetToView;
@synthesize topSpaceToView = _topSpaceToView;
@synthesize topEqualToView = _topEqualToView;
@synthesize bottomEqual = _bottomEqual;
@synthesize bottomOffsetToView = _bottomOffsetToView;
@synthesize bottomSpaceToView = _bottomSpaceToView;
@synthesize bottomEqualToView = _bottomEqualToView;
@synthesize centerYEqual = _centerYEqual;
@synthesize centerYOffsetToView = _centerYOffsetToView;
@synthesize centerYEqualToView = _centerYEqualToView;

- (MNLayoutEqual)widthEqual {
    if (_widthEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^widthEqual)(CGFloat) = ^(CGFloat width) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.size.width = width;
                view.frame = frame;
            }
            return weakself;
        };
        _widthEqual = [widthEqual copy];
    }
    return _widthEqual;
}

- (MNLayoutEqualToView)widthEqualToView {
    if (_widthEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^widthEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.size.width = CGRectGetWidth(toView.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _widthEqualToView = [widthEqualToView copy];
    }
    return _widthEqualToView;
}

- (MNLayoutEqual)leftEqual {
    if (_leftEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^leftEqual)(CGFloat) = ^(CGFloat left) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.x = left;
                view.frame = frame;
            }
            return weakself;
        };
        _leftEqual = [leftEqual copy];
    }
    return _leftEqual;
}

- (MNLayoutOffsetToView)leftOffsetToView {
    if (_leftOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^leftOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMinX(toView.frame) + offset;
                view.frame = frame;
            }
            return weakself;
        };
        _leftOffsetToView = [leftOffsetToView copy];
    }
    return _leftOffsetToView;
}

- (MNLayoutOffsetToView)leftSpaceToView {
    if (_leftSpaceToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^leftSpaceToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat space){
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMaxX(toView.frame) + space;
                view.frame = frame;
            }
            return weakself;
        };
        _leftSpaceToView = [leftSpaceToView copy];
    }
    return _leftSpaceToView;
}

- (MNLayoutEqualToView)leftEqualToView {
    if (_leftEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^leftEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMinX(toView.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _leftEqualToView = [leftEqualToView copy];
    }
    return _leftEqualToView;
}

- (MNLayoutEqual)rightEqual {
    if (_rightEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^rightEqual)(CGFloat) = ^(CGFloat right) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.x = right - CGRectGetWidth(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _rightEqual = [rightEqual copy];
    }
    return _rightEqual;
}

- (MNLayoutOffsetToView)rightOffsetToView {
    if (_rightOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^rightOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMaxX(toView.frame) + offset - CGRectGetWidth(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _rightOffsetToView = [rightOffsetToView copy];
    }
    return _rightOffsetToView;
}

- (MNLayoutOffsetToView)rightSpaceToView {
    if (_rightSpaceToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^rightSpaceToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset){
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMinX(toView.frame) + offset - CGRectGetWidth(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _rightSpaceToView = [rightSpaceToView copy];
    }
    return _rightSpaceToView;
}

- (MNLayoutEqualToView)rightEqualToView {
    if (_rightEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^rightEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMaxX(toView.frame) - CGRectGetWidth(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _rightEqualToView = [rightEqualToView copy];
    }
    return _rightEqualToView;
}

- (MNLayoutEqual)centerXEqual {
    if (_centerXEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerXEqual)(CGFloat) = ^(CGFloat centerX) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.x = centerX - CGRectGetWidth(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerXEqual = [centerXEqual copy];
    }
    return _centerXEqual;
}

- (MNLayoutOffsetToView)centerXOffsetToView {
    if (_centerXOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerXOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMidX(toView.frame) + offset - CGRectGetWidth(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerXOffsetToView = [centerXOffsetToView copy];
    }
    return _centerXOffsetToView;
}

- (MNLayoutEqualToView)centerXEqualToView {
    if (_centerXEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerXEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.x = CGRectGetMidX(toView.frame) - CGRectGetWidth(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerXEqualToView = [centerXEqualToView copy];
    }
    return _centerXEqualToView;
}

- (MNLayoutEqual)heightEqual {
    if (_heightEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^heightEqual)(CGFloat) = ^(CGFloat height) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.size.height = height;
                view.frame = frame;
            }
            return weakself;
        };
        _heightEqual = [heightEqual copy];
    }
    return _heightEqual;
}

- (MNLayoutEqualToView)heightEqualToView {
    if (_heightEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^heightEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.size.height = CGRectGetHeight(toView.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _heightEqualToView = [heightEqualToView copy];
    }
    return _heightEqualToView;
}

- (MNLayoutEqual)topEqual {
    if (_topEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^topEqual)(CGFloat) = ^(CGFloat top) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.y = top;
                view.frame = frame;
            }
            return weakself;
        };
        _topEqual = [topEqual copy];
    }
    return _topEqual;
}

- (MNLayoutOffsetToView)topOffsetToView {
    if (_topOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^topOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMinY(toView.frame) + offset;
                view.frame = frame;
            }
            return weakself;
        };
        _topOffsetToView = [topOffsetToView copy];
    }
    return _topOffsetToView;
}

- (MNLayoutOffsetToView)topSpaceToView {
    if (_topSpaceToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^topSpaceToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat space){
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMaxY(toView.frame) + space;
                view.frame = frame;
            }
            return weakself;
        };
        _topSpaceToView = [topSpaceToView copy];
    }
    return _topSpaceToView;
}

- (MNLayoutEqualToView)topEqualToView {
    if (_topEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^topEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMinY(toView.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _topEqualToView = [topEqualToView copy];
    }
    return _topEqualToView;
}

- (MNLayoutEqual)bottomEqual {
    if (_bottomEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^bottomEqual)(CGFloat) = ^(CGFloat bottom) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.y = bottom - CGRectGetHeight(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _bottomEqual = [bottomEqual copy];
    }
    return _bottomEqual;
}

- (MNLayoutOffsetToView)bottomOffsetToView {
    if (_bottomOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^bottomOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMaxY(toView.frame) + offset - CGRectGetHeight(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _bottomOffsetToView = [bottomOffsetToView copy];
    }
    return _bottomOffsetToView;
}

- (MNLayoutOffsetToView)bottomSpaceToView {
    if (_bottomSpaceToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^bottomSpaceToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat space){
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMinY(toView.frame) + space - CGRectGetHeight(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _bottomSpaceToView = [bottomSpaceToView copy];
    }
    return _bottomSpaceToView;
}

- (MNLayoutEqualToView)bottomEqualToView {
    if (_bottomEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^bottomEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMaxY(toView.frame) - CGRectGetHeight(view.frame);
                view.frame = frame;
            }
            return weakself;
        };
        _bottomEqualToView = [bottomEqualToView copy];
    }
    return _bottomEqualToView;
}

- (MNLayoutEqual)centerYEqual {
    if (_centerYEqual == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerYEqual)(CGFloat) = ^(CGFloat centerY) {
            UIView *view = weakself.view;
            if (view) {
                CGRect frame = view.frame;
                frame.origin.y = centerY - CGRectGetHeight(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerYEqual = [centerYEqual copy];
    }
    return _centerYEqual;
}

- (MNLayoutOffsetToView)centerYOffsetToView {
    if (_centerYOffsetToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerYOffsetToView)(UIView *, CGFloat) = ^(UIView *toView, CGFloat offset) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMidY(toView.frame) + offset - CGRectGetHeight(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerYOffsetToView = [centerYOffsetToView copy];
    }
    return _centerYOffsetToView;
}

- (MNLayoutEqualToView)centerYEqualToView {
    if (_centerYEqualToView == nil) {
        __weak typeof(self) weakself = self;
        MNLayoutConstraint *(^centerYEqualToView)(UIView *) = ^(UIView *toView) {
            UIView *view = weakself.view;
            if (view && toView) {
                CGRect frame = view.frame;
                frame.origin.y = CGRectGetMidY(toView.frame) - CGRectGetHeight(view.frame)/2.f;
                view.frame = frame;
            }
            return weakself;
        };
        _centerYEqualToView = [centerYEqualToView copy];
    }
    return _centerYEqualToView;
}

@end



static const NSString *UIViewLayoutConstraintAssociatedKey = @"com.mn.layout.constraint.key";

@implementation UIView (MNLayoutConstraint)

- (MNLayoutConstraint *)layout {
    MNLayoutConstraint *layout = objc_getAssociatedObject(self, &UIViewLayoutConstraintAssociatedKey);
    if (!layout) {
        layout = [[MNLayoutConstraint alloc] init];
        [layout setValue:self forKey:@"view"];
        objc_setAssociatedObject(self, &UIViewLayoutConstraintAssociatedKey, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return layout;
}

@end
