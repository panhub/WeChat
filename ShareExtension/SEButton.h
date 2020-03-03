//
//  SEButton.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//  分享按钮

#import <UIKit/UIKit.h>

/**定义按钮类型*/
typedef NS_ENUM(NSInteger, SEButtonType) {
    SEButtonTypeSession = 0,
    SEButtonTypeMoment,
    SEButtonTypeFavorites
};

@interface SEButton : UIControl
/**标题*/
@property (nonatomic, copy) NSString *title;
/**图标*/
@property (nonatomic, strong) UIImage *image;
/**不可点击图片*/
@property (nonatomic, strong) UIImage *disablemage;
/**按钮类型*/
@property (nonatomic) SEButtonType type;

@end
