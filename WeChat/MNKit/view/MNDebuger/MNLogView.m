//
//  MNLogView.m
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLogView.h"
#import "MNLogCell.h"
#import "MNLoger.h"
#import "MNLogModel.h"

@interface MNLogView ()<UITableViewDelegate, UITableViewDataSource, MNLogerDelegate>
{
    BOOL StatusBarHidden;
    UIStatusBarStyle StatusBarStyle;
}
@property (nonatomic) BOOL scrollToBottomEnabled;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *backgroundView;
@end

@implementation MNLogView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0.f;
        self.scrollToBottomEnabled = YES;
        
        [self addSubview:UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight)];
        
        UIImageView *backgroundView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, MIN(self.width_mn, self.height_mn)/3.f, MIN(self.width_mn, self.height_mn)/3.f) image:[MNBundle imageForResource:@"log_empty"]];
        backgroundView.center_mn = self.bounds_center;
        backgroundView.alpha = 0.f;
        backgroundView.userInteractionEnabled = NO;
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:backgroundView];
        self.backgroundView = backgroundView;
        
        UITableView *tableView = [UITableView tableWithFrame:self.bounds style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.showsVerticalScrollIndicator = YES;
        [self addSubview:tableView];
        self.tableView = tableView;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, tableView.width_mn, MN_STATUS_BAR_HEIGHT + 5.f)];
        tableView.tableHeaderView = headerView;
        
        UIView *footerView = headerView.viewCopy;
        footerView.height_mn = MN_TAB_SAFE_HEIGHT + 5.f;
        tableView.tableFooterView = footerView;
    }
    return self;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MNLoger.logger.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MNLoger.logger.dataSource[indexPath.row].height;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return .1f;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return .1f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return nil;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MNLogCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.mn.debug.cell"];
    if (!cell) {
        cell = [[MNLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"com.mn.debug.cell"];
    }
    cell.model = MNLoger.logger.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollToBottomEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self updateDisplayIfNeeded];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateDisplayIfNeeded];
}

- (void)updateDisplayIfNeeded {
    CGSize contentSize = self.tableView.contentSize;
    if (contentSize.height <= self.tableView.height_mn) {
        self.scrollToBottomEnabled = YES;
        return;
    }
    self.scrollToBottomEnabled = fabs(contentSize.height - self.tableView.height_mn - self.tableView.contentOffset.y) <= 35.f;
}

#pragma mark - MNLogerDelegate
- (void)logerDidChageLog:(MNLoger *)logger {
    [self reloadData];
    if (self.scrollToBottomEnabled && MNLoger.logger.dataSource.count) {
        [self.tableView scrollToRow:MNLoger.logger.dataSource.count - 1
                          inSection:0
                   atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (void)logerDidCleanLog:(MNLoger *)logger {
    [self reloadData];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)show {
    if (self.alpha == 1.f) return;
    [self logerDidChageLog:MNLoger.logger];
    MNLoger.logger.delegate = self;
    StatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    StatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 1.f;
    }];
}

- (void)dismiss {
    if (self.alpha == 0.f) return;
    MNLoger.logger.delegate = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:StatusBarStyle animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:StatusBarHidden withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        self.scrollToBottomEnabled = YES;
    }];
}
#pragma clang diagnostic pop

- (void)reloadData {
    [self.tableView reloadData];
    self.backgroundView.alpha = MNLoger.logger.dataSource.count > 0 ? 0.f : 1.f;
}

#pragma mark - Setter
- (void)setFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

@end
