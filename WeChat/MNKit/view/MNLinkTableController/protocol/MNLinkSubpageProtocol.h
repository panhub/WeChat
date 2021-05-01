//
//  MNLinkSubpageProtocol.h
//  MNKit
//
//  Created by Vincent on 2018/12/26.
//  Copyright © 2018年 小斯. All rights reserved.
//  联动列表子页面协议 

#import <Foundation/Foundation.h>

@protocol MNLinkSubpageDataSource <NSObject>
@optional
- (UIScrollView *)linkSubpageScrollView;
- (UIGestureRecognizer *)linkSubpageFailToRecognizer;
@end

