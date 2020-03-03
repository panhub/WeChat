//
//  WXAddMomentTableView.h
//  MNChat
//
//  Created by Vincent on 2019/5/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  发布朋友圈底部cell

#import <UIKit/UIKit.h>
#import "WXAddMomentTableViewModel.h"

@protocol WXAddMomentTableViewDelegate <NSObject>

@end

@interface WXAddMomentTableView : UIView

@property (nonatomic, strong) WXAddMomentTableViewModel *viewModel;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

@end
