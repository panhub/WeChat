//
//  WXShakeMatchView.h
//  MNChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//  摇一摇提示信息

#import <UIKit/UIKit.h>

/**
 摇一摇匹配类型
 - WXShakeMatchPerson 人
 - WXShakeMatchMusic 音乐
 - WXShakeMatchTV 电视节目
 */
typedef NS_ENUM(NSInteger, WXShakeMatchType) {
    WXShakeMatchPerson = 0,
    WXShakeMatchMusic,
    WXShakeMatchTV
};

@interface WXShakeMatchView : UIView

/**刷新信息*/
@property (nonatomic) WXShakeMatchType type;

/**显示摇一摇匹配视图*/
- (void)startAnimating;

/**隐藏摇一摇匹配视图*/
- (void)stopAnimating;

@end

