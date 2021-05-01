//
//  SENavigationBar.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SENavigationBar;

typedef NS_ENUM(NSInteger, SENavigationType) {
    SENavigationTypeMain = 0,
    SENavigationTypeSession,
    SENavigationTypeMoment
};

@protocol SENavigationBarDelegate <NSObject>
@optional;
- (void)navigationBarLeftBarButtonClicked:(SENavigationBar *)navigationBar;
- (void)navigationBarRightBarButtonClicked:(SENavigationBar *)navigationBar;
@end

@interface SENavigationBar : UIView
/**类型*/
@property (nonatomic, readonly) SENavigationType type;
/**事件代理*/
@property (nonatomic, weak) id<SENavigationBarDelegate> delegate;

/**
 设置类型
 @param type 类型
 @param animated 是否动态
 */
- (void)setNavigationType:(SENavigationType)type animated:(BOOL)animated;

@end
