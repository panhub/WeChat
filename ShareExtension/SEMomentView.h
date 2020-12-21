//
//  SEMomentView.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//  分享朋友圈视图

#import <UIKit/UIKit.h>

@interface SEMomentView : UIView

/**网页标题*/
@property (nonatomic, copy) NSString *title;

/**朋友圈文字*/
@property (nonatomic, copy) NSString *text;

/**网页图片*/
@property (nonatomic, strong) UIImage *image;

@end
