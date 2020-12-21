//
//  WXAddMomentCollectionViewCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddMomentCollectionViewCell.h"

NSString * const WXMomentCollectionCellShakeAnimationKey = @"com.wx.shake.animation.key";
NSString * const WXMomentCollectionCellShakeNotificationName = @"com.wx.shake.notification.name";
NSString * const WXMomentCollectionCellCancelShakeNotificationName  = @"com.wx.cancel.shake.notification.name";

@interface WXAddMomentCollectionViewCell ()
@property (nonatomic, weak) UIButton *deleteButton;
@end

@implementation WXAddMomentCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.imageView.clipsToBounds = YES;
        self.imageView.userInteractionEnabled = NO;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIButton *deleteButton = [UIButton buttonWithFrame:CGRectMake(self.contentView.width_mn - 25.f, 0.f, 25.f, 25.f)
                                                   image:UIImageNamed(@"wx_moment_delete_pic")
                                                     title:nil
                                                titleColor:nil
                                                 titleFont:nil];
        deleteButton.hidden = YES;
        deleteButton.touchInset = UIEdgeInsetWith(-5.f);
        [self.contentView addSubview:deleteButton];
        self.deleteButton = deleteButton;
        
        @weakify(self);
        [deleteButton handEvents:UIControlEventTouchUpInside eventHandler:^(id sender) {
            @strongify(self);
            self.deleteButton.hidden = YES;
            [self.layer removeAnimationForKey:WXMomentCollectionCellCancelShakeNotificationName];
            if ([self.delegate respondsToSelector:@selector(collectionViewCellDeleteButtonDidClick:)]) {
                [self.delegate collectionViewCellDeleteButtonDidClick:self];
            }
        }];
        
        [self handLongPressConfiguration:^(UILongPressGestureRecognizer *recognizer) {
            recognizer.allowableMovement = NO;
            recognizer.minimumPressDuration = .5f;
        } eventHandler:^(UIGestureRecognizer *recognizer) {
            @strongify(self);
            if (recognizer.state != UIGestureRecognizerStateBegan || self.model.isLast) return;
            [UIWindow endEditing:YES];
            @PostNotify(WXMomentCollectionCellShakeNotificationName, nil);
        }];
    
        [self handNotification:WXMomentCollectionCellShakeNotificationName eventHandler:^(id sender) {
            @strongify(self);
            if (self.model.isLast) return;
            self.deleteButton.hidden = NO;
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation.duration = .25f;
            animation.repeatCount = CGFLOAT_MAX;
            animation.autoreverses = YES;
            animation.fromValue =  [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-.08f,0.f,0.f,.08f)];
            animation.toValue =  [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,.08f,0.f,0.f,.08f)];
            [self.layer addAnimation:animation forKey:WXMomentCollectionCellShakeAnimationKey];
        }];
        
        [self handNotification:WXMomentCollectionCellCancelShakeNotificationName eventHandler:^(id sender) {
            @strongify(self);
            if (self.model.isLast) return;
            self.deleteButton.hidden = YES;
            [self.layer removeAnimationForKey:WXMomentCollectionCellShakeAnimationKey];
        }];
    }
    return self;
}

- (void)setModel:(WXAddMomentCollectionModel *)model {
    _model = model;
    _model.containerView = self.imageView;
    if (model.isLast) {
        self.deleteButton.hidden = YES;
        self.imageView.image = [UIImage imageNamed:@"wx_moment_add_pic"];
    } else {
        self.deleteButton.hidden = !model.isEditing;
        self.imageView.image = model.image;
    }
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview) {
        if (!self.delegate) self.delegate = [self nextResponderForClass:NSClassFromString(@"WXAddMomentCollectionView")];
    } else {
        [self.layer removeAnimationForKey:WXMomentCollectionCellShakeAnimationKey];
    }
}

@end
