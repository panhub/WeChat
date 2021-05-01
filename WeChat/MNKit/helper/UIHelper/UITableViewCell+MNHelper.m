//
//  UITableViewCell+MNHelper.m
//  MNKit
//
//  Created by Vincent on 2018/9/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "UITableViewCell+MNHelper.h"

@implementation UITableViewCell (MNHelper)
#pragma mark - 寻找自身所在的TableView
- (UITableView *)tableView {
    UIResponder *responder = self.nextResponder;
    while (responder && ![responder isKindOfClass:[UITableView class]]) {
        responder = [responder nextResponder];
    }
    return (responder && [responder isKindOfClass:UITableView.class]) ? (UITableView *)responder : nil;
}

- (NSIndexPath *)index_path {
    return [self.tableView indexPathForCell:self];
}

@end
