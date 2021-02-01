//
//  WXCookRequest.h
//  MNChat
//
//  Created by Vincent on 2019/6/20.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱请求

#import "WXJHRequest.h"
@class WXCookMenu;

@interface WXCookRequest : WXJHRequest

/**依据菜谱名查询菜谱列表*/
- (instancetype)initWithMenu:(WXCookMenu *)menu;

@end
