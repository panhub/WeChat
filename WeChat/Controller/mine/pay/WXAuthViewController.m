//
//  WXAuthViewController.m
//  MNChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAuthViewController.h"
#import "WXDataValueModel.h"
#import "WXAuthListCell.h"

@interface WXAuthViewController ()
@property (nonatomic, strong) MNWebProgressView *progressView;
@property (nonatomic, strong) NSArray <NSArray <WXDataValueModel *>*>*dataArray;
@end

@implementation WXAuthViewController
- (instancetype)init {
    if (self = [super init]) {
        self.title = @"实名认证中心";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    MNWebProgressView *progressView = [[MNWebProgressView alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn - 2.5f, self.navigationBar.width_mn, 2.5f)];
    progressView.tintColor = THEME_COLOR;
    [self.navigationBar addSubview:progressView];
    self.progressView = progressView;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.rowHeight = 48.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.backgroundColor = VIEW_COLOR;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadData {
    NSArray <NSArray <NSString *>*>*titles = @[@[@"姓名", @"证件类型", @"证件号"], @[@"职业类别", @"身份证照片", @"证件有效期"]];
    NSArray <NSArray *>*descs = @[@[@"*三", @"身份证", @"4****************2"], @[@"企事业单位工作人员", @"", @"待完善"]];
    NSMutableArray <NSArray <WXDataValueModel *>*>*dataArray = [NSMutableArray arrayWithCapacity:3];
    [titles enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger index, BOOL * _Nonnull sp) {
        NSMutableArray <WXDataValueModel *>*listArray = [NSMutableArray arrayWithCapacity:obj.count];
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            WXDataValueModel *model = [WXDataValueModel new];
            model.title = title;
            model.desc = descs[index][idx];
            [listArray addObject:model];
        }];
        [dataArray addObject:listArray.copy];
    }];
    self.dataArray = dataArray.copy;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.progressView.progress = 0.f;
    self.tableView.alpha = 0.f;
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
                self.tableView.alpha = 1.f;
            }];
        } else {
            [self updateProgressIfNeeds];
        }
    });
}

#pragma mark - TableViewDelegate & TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MNTableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.mn.pay.auth.header.id"];
    if (!header) {
        header = [[MNTableViewHeaderFooterView alloc] initWithReuseIdentifier:@"com.mn.pay.auth.header.id"];
        header.contentView.backgroundColor = VIEW_COLOR;
        header.titleLabel.frame = CGRectMake(15.f, MEAN(30.f - 13.f), tableView.width_mn - 30.f, 13.f);
        header.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .4f);
        header.titleLabel.font = [UIFont systemFontOfSize:13.f];
        header.titleLabel.textAlignment = NSTextAlignmentLeft;
        header.titleLabel.numberOfLines = 1;
    }
    header.titleLabel.text = section == 0 ? @"已认证信息" : @"完善身份信息以享受更全面的支付服务";
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXAuthListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.mn.pay.auth.cell.id"];
    if (!cell) {
        cell = [[WXAuthListCell alloc] initWithReuseIdentifier:@"com.mn.pay.auth.cell.id" size:tableView.rowSize];
    }
    cell.section = indexPath.section;
    cell.model = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat y = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = y <= 0.f;
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

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIControl *rightItem = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, kNavItemSize, kNavItemSize)];
    rightItem.backgroundImage = [UIImage imageNamed:@"wx_common_more_black"];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

@end
