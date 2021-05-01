//
//  MNTailorTimeView.h
//  MNKit
//
//  Created by Vicent on 2020/8/2.
//  时间简介

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNTailorTimeView : UIView

/**当前时长*/
@property (nonatomic) NSTimeInterval duration;

/**分割线颜色*/
@property (nonatomic, copy) UIColor *separatorColor;

/**字体颜色*/
@property (nonatomic, copy) UIColor *textColor;

@end

NS_ASSUME_NONNULL_END
