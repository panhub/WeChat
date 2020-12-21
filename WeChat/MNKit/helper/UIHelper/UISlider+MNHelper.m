//
//  UISlider+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/12/8.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UISlider+MNHelper.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation UISlider (MNHelper)
#pragma mark - 系统滑块
+ (UISlider *)volumeSlider {
    /**我们可以将此view添加到视图层次中, 然后将此view隐藏或移动*/
    static UISlider *volume_slider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MPVolumeView *volumeView = [MPVolumeView new];
        for (UIView *subview in [volumeView subviews]) {
            if ([[[subview class] description] isEqualToString:@"MPVolumeSlider"]){
                volume_slider = (UISlider*)subview;
                break;
            }
        }
    });
    return volume_slider;
}

@end
