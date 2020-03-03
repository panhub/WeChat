//
//  WXChangeInfoController.m
//  MNChat
//
//  Created by Vincent on 2019/6/3.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangeInfoController.h"
#import "WXChangeInfoHeader.h"
#import "WXDataValueModel.h"
#import "WXChangeInfoCell.h"
#import "WXChangeInfoToolBar.h"
#import "WXChangeModel.h"

@interface WXChangeInfoController ()
@property (nonatomic, strong) WXChangeModel *model;
@property (nonatomic, strong) NSArray <WXDataValueModel *>*dataArray;
@property (nonatomic, strong) MNWebProgressView *progressView;
@end

@implementation WXChangeInfoController
- (instancetype)initWithChangeModel:(WXChangeModel *)model {
    if (self = [super init]) {
        self.model = model;
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
    self.tableView.rowHeight = 30.f;
    self.tableView.backgroundColor = UIColorWithSingleRGB(237.f);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    WXChangeInfoHeader *headerView = [[WXChangeInfoHeader alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.model = self.model;
    self.tableView.tableHeaderView = headerView;
    
    WXChangeInfoToolBar *toolBar = [[WXChangeInfoToolBar alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, 0.f)];
    toolBar.bottom_mn = self.contentView.height_mn;
    @weakify(self);
    toolBar.buttonClickedHandler = ^(NSInteger index) {
        if (index == 0) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:NO];
        }
    };
    [self.contentView addSubview:toolBar];
    
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
    NSMutableArray <WXDataValueModel *>*dataArray = [NSMutableArray arrayWithCapacity:6];
    WXDataValueModel *model0 = [WXDataValueModel new];
    model0.title = @"类型";
    model0.desc = self.model.type;
    [dataArray addObject:model0];
    WXDataValueModel *model1 = [WXDataValueModel new];
    model1.title = @"时间";
    model1.desc = [NSDate dateStringWithTimestamp:self.model.timestamp format:@"yyyy-MM-dd HH:mm:ss"];
    [dataArray addObject:model1];
    WXDataValueModel *model2 = [WXDataValueModel new];
    model2.title = @"交易单号";
    model2.desc = self.model.numbers;
    [dataArray addObject:model2];
    WXDataValueModel *model3 = [WXDataValueModel new];
    model3.title = @"剩余零钱";
    model3.desc = [@"¥" stringByAppendingString:WXPreference.preference.money];
    [dataArray addObject:model3];
    if (self.model.note.length > 0) {
        WXDataValueModel *model4 = [WXDataValueModel new];
        model4.title = @"备注";
        model4.desc = self.model.note;
        [dataArray addObject:model4];
    }
    WXDataValueModel *model5 = [WXDataValueModel new];
    model5.title = @"";
    model5.desc = @"";
    [dataArray addObject:model5];
    self.dataArray = dataArray.copy;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXChangeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.change.info.id"];
    if (!cell) {
        cell = [[WXChangeInfoCell alloc] initWithReuseIdentifier:@"com.wx.change.info.id" size:tableView.rowSize];
    }
    cell.model = self.dataArray[indexPath.row];
    return cell;
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

- (void)navigationBarLeftBarItemTouchUpInside:(UIView *)leftBarItem {
    NSInteger count = self.navigationController.viewControllers.count;
    if (count >= 3) {
        UIViewController *vc = self.navigationController.viewControllers[count - 3];
        [self.navigationController popToViewController:vc animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSoluble];
}

@end
