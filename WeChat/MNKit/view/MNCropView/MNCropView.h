//
//  MNCropView.h
//  MNKit
//
//  Created by Vincent on 2019/11/11.
//  Copyright © 2019 Vincent. All rights reserved.
//  裁剪框

#import <UIKit/UIKit.h>

@interface MNCropView : UIView

/**裁剪宽高比例限制*/
@property (nonatomic) CGFloat scale;
/**边角尺寸*/
@property (nonatomic) CGSize cornerSize;
/**边框宽度*/
@property (nonatomic) CGFloat borderWidth;
/**边框颜色*/
@property (nonatomic, copy) UIColor *borderColor;
/**边角颜色*/
@property (nonatomic, copy) UIColor *cornerColor;
/**裁剪区域颜色*/
@property (nonatomic, copy) UIColor *fillColor;
/**获取裁剪区域*/
@property (nonatomic, readonly) CGRect cropRect;

@end

