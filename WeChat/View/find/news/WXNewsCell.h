//
//  WXNewsCell.h
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "MNTableViewCell.h"
@class WXNewsViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface WXNewsCell : MNTableViewCell

/**视图模型*/
@property (nonatomic, strong) WXNewsViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
