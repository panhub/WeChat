//
//  WXCollectViewController.h
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//  收藏

#import "MNSearchViewController.h"
#import "WXWebpage.h"

typedef NS_ENUM(NSInteger, WXCollectControllerType) {
    WXCollectControllerMine = 0,
    WXCollectControllerChat
};

@interface WXCollectViewController : MNSearchViewController

@property (nonatomic) WXCollectControllerType type;

@property (nonatomic, copy) void (^selectedHandler) (WXWebpage *page);

@end
