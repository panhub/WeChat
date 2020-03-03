//
//  SESessionView.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SESessionView.h"
#import "SESessionCell.h"
#import "SESessionHeader.h"
#import "UIView+MNFrame.h"

@interface SESessionView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray <SESession *>*dataArray;
@end

@implementation SESessionView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = UIColor.whiteColor;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 53.f;
        tableView.backgroundColor = UIColor.whiteColor;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        tableView.estimatedRowHeight = 0.f;
        tableView.estimatedSectionHeaderHeight = 0.f;
        tableView.estimatedSectionFooterHeight = 0.f;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = [UIColor.grayColor colorWithAlphaComponent:.2f];
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, CGFLOAT_MIN)];
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            if ([tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        #endif
        [self addSubview:tableView];
        self.tableView = tableView;
    }
    return self;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SESessionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.ext.share.header.id"];
    if (!header) {
        header = [[SESessionHeader alloc] initWithReuseIdentifier:@"com.ext.share.header.id"];
    }
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SESessionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.ext.share.session.id"];
    if (!cell) {
        cell = [[SESessionCell alloc] initWithReuseIdentifier:@"com.ext.share.session.id" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SESessionCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.session = self.dataArray[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SESession *session = self.dataArray[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(sessionViewDidSelectSession:)]) {
        [self.delegate sessionViewDidSelectSession:session];
    }
}

#pragma mark - Getter
- (NSArray <SESession *>*)dataArray {
    if (!_dataArray) {
        NSMutableArray <SESession *>*dataArray = @[].mutableCopy;
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.mn.chat.share"];
        NSArray <NSDictionary *>*sessions = [userDefaults arrayForKey:@"com.ext.share.session"];
        [sessions enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [dataArray addObject:[SESession sessionWithSandboox:obj]];
        }];
        _dataArray = dataArray.copy;
    }
    return _dataArray;
}

@end
