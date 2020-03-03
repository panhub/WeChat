//
//  MNCityPicker.h
//  MNFoundation
//
//  Created by Vincent on 2020/1/20.
//  Copyright © 2020 Vincent. All rights reserved.
//  简单的地点选择器<数据可能不全>

#import <UIKit/UIKit.h>
@class MNCityPicker;

@interface MNCityPicker : UIView
/**省*/
@property (nonatomic, readonly) NSString *city;
/**城市*/
@property (nonatomic, readonly) NSString *province;

/**
 展示城市选择器
 @param selectHandler 选择回调
 */
- (void)showWithSelectHandler:(void (^)(MNCityPicker *picker))selectHandler;

/**
 展示城市选择器
 @param superview 父视图
 @param selectHandler 选择回调
 */
- (void)showInView:(UIView *)superview selectHandler:(void (^)(MNCityPicker *picker))selectHandler;

@end
