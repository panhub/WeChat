//
//  WXLocationViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatLocationController.h"
#import "WXChatLocationResultController.h"
#import "WXChatLocationHeaderView.h"
#import "WXLocationListCell.h"

@interface WXChatLocationController () <UITextFieldDelegate, AMapSearchDelegate>
/// 是否需要搜索附近
@property (nonatomic) BOOL needSearch;
/// 选择位置
@property (nonatomic, strong) WXMapLocation *location;
/// 定位位置
@property (nonatomic, strong) AMapGeoPoint *geoPoint;
/// 搜索对象
@property (nonatomic, strong) AMapSearchAPI *search;
/// 选择索引
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
/// 城市信息
@property (nonatomic, strong) AMapLocationReGeocode *address;
/// 定位对象
@property (nonatomic, strong) AMapLocationManager *locationManager;
/// 表头<显示地图>
@property (nonatomic, strong) WXChatLocationHeaderView *headerView;
/// 位置信息
@property (nonatomic, strong) NSMutableArray <AMapPOI *>*dataSource;
@end

@implementation WXChatLocationController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"位置";
        self.needSearch = YES;
        self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.view.backgroundColor = VIEW_COLOR;
    self.contentView.backgroundColor = VIEW_COLOR;
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 50.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
    self.searchBar.frame = CGRectMake(0.f, 5.f, self.tableView.width_mn, NAV_BAR_HEIGHT);
    @weakify(self);
    self.searchBar.textFieldConfigurationHandler = ^(MNSearchBar *searchBar, MNTextField *textField) {
        @strongify(self);
        textField.delegate = self;
        textField.placeholder = @"搜索地点";
        textField.tintColor = THEME_COLOR;
        textField.frame = CGRectMake(10.f, MEAN(searchBar.height_mn - 35.f), searchBar.width_mn - 20.f, 35.f);
    };
    WXChatLocationHeaderView *headerView = [[WXChatLocationHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, 0.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    [headerView.contentView addSubview:self.searchBar];
    headerView.mapView.top_mn = self.searchBar.bottom_mn + 5.f;
    headerView.height_mn = headerView.mapView.bottom_mn;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /// 检索结果展示
    WXChatLocationResultController *resultController = [[WXChatLocationResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.headerView.height_mn - self.headerView.mapView.height_mn, self.view.width_mn, self.view.height_mn - UIStatusBarHeight() - self.searchBar.height_mn)];
    @weakify(self);
    resultController.didSelectHandler = ^(NSString *name, NSString *address, AMapGeoPoint *location) {
        @strongify(self);
        self.location = [WXMapLocation pointWithLatitude:location.latitude longitude:location.longitude];
        self.location.name = name;
        self.location.address = address;
        self.headerView.location = location;
        if (self.selectIndexPath) {
            UITableViewCell *selectCell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
            selectCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectIndexPath = nil;
        }
        [self.searchBar cancel];
    };
    self.updater = resultController;
    self.searchResultController = resultController;
}

- (void)loadData {
    [self.contentView showWeChatDialog];
    [MNAuthenticator requestLocationAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            @weakify(self);
            [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
                @strongify(self);
                if (location && regeocode) {
                    self.address = regeocode;
                    self.geoPoint = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
                    self.headerView.location = self.geoPoint;
                    NSString *desc = regeocode.city;
                    if (regeocode.district.length > 0) desc = [NSString stringWithFormat:@"%@%@%@", desc, WXMsgSeparatedSign, regeocode.district];
                    [self startPOIAroundSearch:location];
                } else {
                    [self.contentView closeDialog];
                    [self.dataSource removeAllObjects];
                }
                @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
            }];
        } else {
            [self.contentView closeDialog];
            [[MNAlertView alertViewWithTitle:nil message:@"请允许应用获取您的位置信息!" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
                if (self.presentingViewController) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } ensureButtonTitle:@"退出" otherButtonTitles:nil] show];
        }
    }];
}

- (void)startPOIAroundSearch:(CLLocation *)location {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = self.geoPoint;
    request.sortrule = 0;
    request.offset = 50;
    request.page = 1;
    request.requireExtension = YES;
    request.requireSubPOIs = YES;
    request.radius = 3000;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    [self.search cancelAllRequests];
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXLocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.location.cell"];
    if (!cell) {
        cell = [[WXLocationListCell alloc] initWithReuseIdentifier:@"com.wx.location.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXLocationListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    cell.location = self.dataSource[indexPath.row];
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) return;
    if (self.selectIndexPath) {
        UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:self.selectIndexPath];
        selectCell.accessoryType = UITableViewCellAccessoryNone;
    }
    self.selectIndexPath = indexPath;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    AMapPOI *poi = self.dataSource[indexPath.row];
    self.location = [WXMapLocation pointWithLatitude:poi.location.latitude longitude:poi.location.longitude];
    self.location.name = poi.name;
    self.location.address = poi.address;
    self.headerView.location = poi.location;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

#pragma mark - MNSearchControllerDelegate
- (void)willPresentSearchController:(MNSearchViewController *)searchController {
    WXChatLocationResultController *vc = (WXChatLocationResultController *)(searchController.searchResultController);
    vc.location = self.geoPoint;
    vc.address = self.address;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataSource.count > 0;
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    [self.contentView closeDialog];
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    [self.contentView closeDialog];
    NSMutableArray <AMapPOI *>*results = [NSMutableArray arrayWithCapacity:response.pois.count];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.name.length > 0 && obj.address.length > 0) {
            [results addObject:obj];
        }
    }];
    [self.dataSource addObjectsFromArray:results.copy];
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

#pragma mark - Getter
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        AMapLocationManager *locationManager = [[AMapLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.pausesLocationUpdatesAutomatically = NO;
        locationManager.allowsBackgroundLocationUpdates = YES;
        locationManager.locatingWithReGeocode = YES;
        locationManager.locationTimeout = 10.f;
        locationManager.reGeocodeTimeout = 5.f;
        locationManager.reGeocodeLanguage = AMapLocationReGeocodeLanguageChinse;
        _locationManager = locationManager;
    }
    return _locationManager;
}

- (AMapSearchAPI *)search {
    if (!_search) {
        AMapSearchAPI *search = [[AMapSearchAPI alloc] init];
        search.delegate = self;
        search.timeout = 10;
        search.language = AMapSearchLanguageZhCN;
        _search = search;
    }
    return _search;
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIButton *leftItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 40.f, kNavItemSize)
                                             image:nil
                                             title:@"取消"
                                        titleColor:UIColorWithAlpha([UIColor darkTextColor], .9f)
                                              titleFont:@(17.f)];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 53.f, 32.f)
                                              image:nil
                                              title:@"发送"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    if (self.location.name.length <= 0) {
        [self.view showInfoDialog:@"获取位置信息失败"];
    } else {
        [self didSelectLocation];
    }
}

- (void)didSelectLocation {
    @weakify(self);
    [self.headerView takeSnapshotCompletion:^(UIImage *image) {
        @strongify(self);
        if (self.didSelectHandler) {
            self.location.snapshot = image;
            self.didSelectHandler(self.location);
        }
    }];
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

@end
