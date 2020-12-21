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

NS_ASSUME_NONNULL_BEGIN

typedef MNLayoutConstraint *_Nonnull(^MNLayoutEqual)(CGFloat);
typedef MNLayoutConstraint *_Nonnull(^MNLayoutEqualToView)(UIView *);
typedef MNLayoutConstraint *_Nonnull(^MNLayoutOffsetToView)(UIView *, CGFloat);

@interface MNLayoutConstraint : NSObject
/**记录设置视图*/
@property (nonatomic, readonly, weak) UIView *view;
/**设置宽*/
@property (nonatomic, readonly, copy) MNLayoutEqual widthEqual;
/**设置宽与指定视图相等*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView widthEqualToView;
/**设置横向起始值*/
@property (nonatomic, readonly, copy) MNLayoutEqual leftEqual;
/**设置横向起始与指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView leftOffsetToView;
/**设置横向起始与指定视图的距离*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView leftSpaceToView;
/**设置横向起始与指定视图相等*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView leftEqualToView;
/**设置横向终点值*/
@property (nonatomic, readonly, copy) MNLayoutEqual rightEqual;
/**设置横向终点与指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView rightOffsetToView;
/**设置横向终点与指定视图的距离*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView rightSpaceToView;
/**设置横向终点与指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView rightEqualToView;
/**设置横向中心点值*/
@property (nonatomic, readonly, copy) MNLayoutEqual centerXEqual;
/**设置横向中心点与指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView centerXOffsetToView;
/**设置横向中心点与指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView centerXEqualToView;
/**设置高*/
@property (nonatomic, readonly, copy) MNLayoutEqual heightEqual;
/**设置高于指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView heightEqualToView;
/**设置纵向起始值*/
@property (nonatomic, readonly, copy) MNLayoutEqual topEqual;
/**设置纵向起始于指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView topOffsetToView;
/**设置纵向起始于指定视图的距离*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView topSpaceToView;
/**设置纵向起始于指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView topEqualToView;
/**设置纵向终点值*/
@property (nonatomic, readonly, copy) MNLayoutEqual bottomEqual;
/**设置纵向终点与指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView bottomOffsetToView;
/**设置纵向终点与指定视图的距离*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView bottomSpaceToView;
/**设置纵向终点与指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView bottomEqualToView;
/**设置纵向中心点值*/
@property (nonatomic, readonly, copy) MNLayoutEqual centerYEqual;
/**设置纵向中心点与指定视图的偏移*/
@property (nonatomic, readonly, copy) MNLayoutOffsetToView centerYOffsetToView;
/**设置纵向中心点与指定视图相同*/
@property (nonatomic, readonly, copy) MNLayoutEqualToView centerYEqualToView;

@end


@interface UIView (MNLayoutConstraint)
 
/**约束对象*/
@property (nonatomic, readonly, strong) MNLayoutConstraint *layout;

@end

NS_ASSUME_NONNULL_END
