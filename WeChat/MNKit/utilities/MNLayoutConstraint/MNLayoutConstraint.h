//
//  MNLayoutConstraint.h
//  WeChat
//
//  Created by Vicent on 2020/3/6.
//  Copyright © 2020 Vincent. All rights reserved.
//  视图约束封装

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@class MNLayoutConstraint;

typedef MNLayoutConstraint *(^MNLayoutEqual)(CGFloat);
typedef MNLayoutConstraint *(^MNLayoutEqualToView)(UIView *);
typedef MNLayoutConstraint *(^MNLayoutOffsetToView)(UIView *, CGFloat);

@interface MNLayoutConstraint : NSObject

@property (nonatomic, readonly, weak) UIView *view;

@property (nonatomic, readonly, copy) MNLayoutEqual widthEqual;

@property (nonatomic, readonly, copy) MNLayoutEqualToView widthEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView leftOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView leftSpaceToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView leftEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView rightOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView rightSpaceToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView rightEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView centerXOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView centerXEqualToView;

@property (nonatomic, readonly, copy) MNLayoutEqual heightEqual;

@property (nonatomic, readonly, copy) MNLayoutEqualToView heightEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView topOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView topSpaceToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView topEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView bottomOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView bottomSpaceToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView bottomEqualToView;

@property (nonatomic, readonly, copy) MNLayoutOffsetToView centerYOffsetToView;

@property (nonatomic, readonly, copy) MNLayoutEqualToView centerYEqualToView;

@end


@interface UIView (MNLayoutConstraint)
 
@property (nonatomic, readonly, strong) MNLayoutConstraint *layout;

@end
