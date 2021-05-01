//
//  WXAlbumHeaderView.h
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  相册表头视图

#import <UIKit/UIKit.h>

@interface WXAlbumHeaderView : UIView

/**点击事件*/
@property (nonatomic, copy) void (^touchEventHandler) (void);

@end
