//
//  MNLayoutConstraint.m
//  WeChat
//
//  Created by Vicent on 2020/3/6.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "MNLayoutConstraint.h"
#import <objc/runtime.h>

#define typeofWeakSelf  __weak typeof(self) weakself = self;

#define checkLayout \
if (!weakself.view || !weakself.view.superview) { \
    NSLog(@"建议先添加视图再进行约束"); \
    return weakself; \
}

#define checkLayoutWithView \
if (!weakself.view || !weakself.view.superview || !view || (weakself.view.superview != view && !view.superview)) { \
    NSLog(@"建议先添加视图再进行约束"); \
    return weakself; \
}

@implementation MNLayoutConstraint
@synthesize widthEqual = _widthEqual;
@synthesize widthEqualToView = _widthEqualToView;
@synthesize leftOffsetToView = _leftOffsetToView;
@synthesize leftSpaceToView = _leftSpaceToView;
@synthesize leftEqualToView = _leftEqualToView;
@synthesize rightSpaceToView = _rightSpaceToView;
@synthesize rightOffsetToView = _rightOffsetToView;
@synthesize rightEqualToView = _rightEqualToView;
@synthesize centerXOffsetToView = _centerXOffsetToView;
@synthesize centerXEqualToView = _centerXEqualToView;
@synthesize heightEqual = _heightEqual;
@synthesize heightEqualToView = _heightEqualToView;
@synthesize topOffsetToView = _topOffsetToView;
@synthesize topSpaceToView = _topSpaceToView;
@synthesize topEqualToView = _topEqualToView;
@synthesize bottomOffsetToView = _bottomOffsetToView;
@synthesize bottomSpaceToView = _bottomSpaceToView;
@synthesize bottomEqualToView = _bottomEqualToView;
@synthesize centerYOffsetToView = _centerYOffsetToView;
@synthesize centerYEqualToView = _centerYEqualToView;

- (MNLayoutEqual)widthEqual {
    if (_widthEqual == nil) {
        typeofWeakSelf;
        MNLayoutConstraint *(^widthEqual)(CGFloat) = ^(CGFloat margin) {
            checkLayout
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:margin];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _widthEqual = [widthEqual copy];
    }
    return _widthEqual;
}

- (MNLayoutEqualToView)widthEqualToView {
    if (_widthEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^widthEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _widthEqualToView = [widthEqualToView copy];
    }
    return _widthEqualToView;
}

- (MNLayoutOffsetToView)leftOffsetToView {
    if (_leftOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^leftOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _leftOffsetToView = [leftOffsetToView copy];
    }
    return _leftOffsetToView;
}

- (MNLayoutOffsetToView)leftSpaceToView {
    if (_leftSpaceToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^leftSpaceToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset){
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _leftSpaceToView = [leftSpaceToView copy];
    }
    return _leftSpaceToView;
}

- (MNLayoutEqualToView)leftEqualToView {
    if (_leftEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^leftEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _leftEqualToView = [leftEqualToView copy];
    }
    return _leftEqualToView;
}

- (MNLayoutOffsetToView)rightOffsetToView {
    if (_rightOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^rightOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _rightOffsetToView = [rightOffsetToView copy];
    }
    return _rightOffsetToView;
}

- (MNLayoutOffsetToView)rightSpaceToView {
    if (_rightSpaceToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^rightSpaceToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset){
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _rightSpaceToView = [rightSpaceToView copy];
    }
    return _rightSpaceToView;
}

- (MNLayoutEqualToView)rightEqualToView {
    if (_rightEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^rightEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _rightEqualToView = [rightEqualToView copy];
    }
    return _rightEqualToView;
}

- (MNLayoutOffsetToView)centerXOffsetToView {
    if (_centerXOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^centerXOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _centerXOffsetToView = [centerXOffsetToView copy];
    }
    return _centerXOffsetToView;
}

- (MNLayoutEqualToView)centerXEqualToView {
    if (_centerXEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^centerXEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _centerXEqualToView = [centerXEqualToView copy];
    }
    return _centerXEqualToView;
}

- (MNLayoutEqual)heightEqual {
    if (_heightEqual == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^heightEqual)(CGFloat) = ^(CGFloat margin) {
            checkLayout
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.f constant:margin];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _heightEqual = [heightEqual copy];
    }
    return _heightEqual;
}

- (MNLayoutEqualToView)heightEqualToView {
    if (_heightEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^heightEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _heightEqualToView = [heightEqualToView copy];
    }
    return _heightEqualToView;
}

- (MNLayoutOffsetToView)topOffsetToView {
    if (_topOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^topOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _topOffsetToView = [topOffsetToView copy];
    }
    return _topOffsetToView;
}

- (MNLayoutOffsetToView)topSpaceToView {
    if (_topSpaceToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^topSpaceToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset){
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _topSpaceToView = [topSpaceToView copy];
    }
    return _topSpaceToView;
}

- (MNLayoutEqualToView)topEqualToView {
    if (_topEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^topEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _topEqualToView = [topEqualToView copy];
    }
    return _topEqualToView;
}

- (MNLayoutOffsetToView)bottomOffsetToView {
    if (_bottomOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^bottomOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _bottomOffsetToView = [bottomOffsetToView copy];
    }
    return _bottomOffsetToView;
}

- (MNLayoutOffsetToView)bottomSpaceToView {
    if (_bottomSpaceToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^bottomSpaceToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset){
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _bottomSpaceToView = [bottomSpaceToView copy];
    }
    return _bottomSpaceToView;
}

- (MNLayoutEqualToView)bottomEqualToView {
    if (_bottomEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^bottomEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _bottomEqualToView = [bottomEqualToView copy];
    }
    return _bottomEqualToView;
}

- (MNLayoutOffsetToView)centerYOffsetToView {
    if (_centerYOffsetToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^centerYOffsetToView)(UIView *, CGFloat) = ^(UIView *view, CGFloat offset) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:offset];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
            return weakself;
        };
        _centerYOffsetToView = [centerYOffsetToView copy];
    }
    return _centerYOffsetToView;
}

- (MNLayoutEqualToView)centerYEqualToView {
    if (_centerYEqualToView == nil) {
        typeofWeakSelf
        MNLayoutConstraint *(^centerYEqualToView)(UIView *) = ^(UIView *view) {
            checkLayoutWithView
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:weakself.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
            constraint.identifier = NSStringFromSelector(_cmd);
            constraint.active = YES;
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
