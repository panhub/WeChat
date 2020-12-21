//
//  MNVideoResizeButton.h
//  MNKit
//
//  Created by Vicent on 2020/8/1.
//  视频调整按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNVideoResizeButton : UIButton

/**保存比例*/
@property (nonatomic) CGFloat scale;

/**选择颜色*/
@property (nonatomic, copy) UIColor *selectedColor;

/**正常颜色*/
@property (nonatomic, copy) UIColor *normalColor;

@end

NS_ASSUME_NONNULL_END
