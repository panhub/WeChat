//
//  WXChangeListController.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeListController.h"
#import "WXChangeInfoController.h"
#import "WXChangeListCell.h"
#import "WXChangeModel.h"

@interface WXChangeListController ()
@property (nonatomic, strong) NSArray <WXChangeModel *>*dataArray;
@property (nonatomic, strong) MNWebProgressView *progressView;
@end

@implementation WXChangeListController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"零钱明细";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = UIColorWithSingleRGB(237.f);
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 72.f;
    self.tableView.backgroundColor = UIColorWithSingleRGB(237.f);
    self.tableView.separatorColor = SEPARATOR_COLOR;
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.contentView.alpha = 0.f;
    self.progressView.progress = 0.f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateProgressIfNeeds];
}

- (void)updateProgressIfNeeds {
    [self.progressView setProgress:(self.progressView.progress + .2f) animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.progressView.progress >= .6f) {
            [self.progressView setProgress:1.f animated:YES];
            [UIView animateWithDuration:.3f animations:^{
                self.contentView.alpha = 1.f;
            }];
        } else {
            [self updateProgressIfNeeds];
        }
    });
}

- (void)loadData {
    NSString *where = self.type == WXChangeListWithdraw ? [@{@"channel":@"2"} componentString] : @"";
    [MNDatabase selectRowsModelFromTable:WXChangeTableName where:where limit:NSRangeZero class:WXChangeModel.class completion:^(NSArray<WXChangeModel *> * _Nonnull rows) {
        self.dataArray = rows.reversedArray.copy;
        dispatch_async_main(^{
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        });
    }];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXChangeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.change.list.id"];
    if (!cell) {
        cell = [[WXChangeListCell alloc] initWithReuseIdentifier:@"com.wx.change.list.id" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowsWithAnimated:YES];
    if (indexPath.row >= self.dataArray.count) return;
    dispatch_after_main(.5f, ^{
        WXChangeModel *model = self.dataArray[indexPath.row];
        WXChangeInfoController *vc = [[WXChangeInfoController alloc] initWithChangeModel:model];
        [self.navigationController pushViewController:vc animated:YES];
    });
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 35.f, 35.f)];
    leftItem.backgroundImage = [UIImage imageNamed:@"wx_common_closeHL"];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
