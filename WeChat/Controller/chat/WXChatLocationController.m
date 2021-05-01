//
//  WXLocationViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatLocationController.h"
#import "WXChatLocationResultController.h"
#import "WXChatLocationHeaderView.h"
#import "WXLocationListCell.h"
#import <CoreLocation/CoreLocation.h>

@interface WXChatLocationController () <UITextFieldDelegate, AMapSearchDelegate, CLLocationManagerDelegate>
/// 选择位置
@property (nonatomic, strong) WXLocation *location;
/// 搜索对象
@property (nonatomic, strong) AMapSearchAPI *search;
/// 选择索引
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
/// 定位权限
@property (nonatomic, strong) CLLocationManager *locationAuthenticator;
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
        self.selectIndexPath = nil;
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
    self.navigationBar.shadowView.backgroundColor = SEPARATOR_COLOR;
    self.navigationBar.shadowView.hidden = YES;
    
    self.tableView.frame = self.contentView.bounds;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.rowHeight = 50.f;
    self.tableView.separatorColor = SEPARATOR_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, MN_TAB_SAFE_HEIGHT)];
    
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateNormal];
    [self.searchBar setTitleColor:TEXT_COLOR forState:UIControlStateHighlighted];
    self.searchBar.frame = CGRectMake(0.f, 5.f, self.tableView.width_mn, MN_NAV_BAR_HEIGHT);
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
    WXChatLocationResultController *resultController = [[WXChatLocationResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.headerView.height_mn - self.headerView.mapView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    @weakify(self);
    resultController.didSelectHandler = ^(NSString *name, NSString *address, AMapGeoPoint *location) {
        @strongify(self);
        if (self.selectIndexPath) {
            UITableViewCell *selectCell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
            selectCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectIndexPath = nil;
            self.location = nil;
        }
        [self.searchBar cancel];
        [self.tableView scrollToTop];
        self.headerView.location = location;
        [self.contentView showWechatDialog];
        WXChatLocationResultController *vc = (WXChatLocationResultController *)(self.searchResultController);
        vc.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
        [self startPOIAroundSearch:location];
    };
    self.updater = resultController;
    self.searchResultController = resultController;
    
    // 请求权限
    [self requestLocationAuthorizationStatus];
}

- (void)requestLocation {
    @weakify(self);
    [self.contentView showWechatDialog];
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *loc, AMapLocationReGeocode *regeocode, NSError *error) {
        @strongify(self);
        if (error || !loc) {
            [self.contentView closeDialog];
        } else {
            WXChatLocationResultController *vc = (WXChatLocationResultController *)(self.searchResultController);
            vc.coordinate = loc.coordinate;
            AMapGeoPoint *location = [AMapGeoPoint locationWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude];
            self.headerView.location = location;
            [self startPOIAroundSearch:location];
        }
    }];
}

- (void)startPOIAroundSearch:(AMapGeoPoint *)location {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = location;
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
    [self selectPOI:poi];
}

- (void)selectPOI:(AMapPOI *)poi {
    self.location = [WXLocation locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
    self.location.name = poi.name;
    self.location.address = poi.address;
    self.headerView.location = poi.location;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
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
    NSArray <AMapPOI *>*results = [response.pois.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.name.length > 0 && self.address.length > 0"]];
    if (results.count) {
        [self.dataSource removeAllObjects];
        [self.dataSource addObjectsFromArray:results];
        self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        AMapPOI *poi = results.firstObject;
        [self selectPOI:poi];
        [self reloadList];
    }
    [self.contentView closeDialog];
}

#pragma mark - Authorization
- (void)requestLocationAuthorizationStatus {
    if (![CLLocationManager locationServicesEnabled]) {
        [self close:@"定位服务不可用"];
        return;
    }
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) {
        // 未选择权限
        CLLocationManager *locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
        self.locationAuthenticator = locationManager;
        return;
    }
    if (status >= kCLAuthorizationStatusAuthorizedAlways) {
        // 允许
        [self requestLocation];
    } else {
        // 拒绝
        [self close:@"请允许应用使用位置信息"];
    }
}

- (void)close:(NSString *)msg {
    @weakify(self)
    [[MNAlertView alertViewWithTitle:nil message:msg handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        UIViewController *vc = weakself.isChildViewController ? weakself.parentController : weakself;
        if (vc.presentingViewController) {
            [vc dismissViewControllerAnimated:YES completion:nil];
        } else {
            [vc.navigationController popViewControllerAnimated:YES];
        }
    } ensureButtonTitle:@"确定" otherButtonTitles:nil] showInView:self.view];
}

#pragma mark - CLLocationManagerDelegate
#ifdef __IPHONE_14_0
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined) return;
    if (status >= kCLAuthorizationStatusAuthorizedAlways) {
        // 允许
        [self requestLocation];
    } else {
        // 拒绝
        [self close:@"请允许应用使用位置信息"];
    }
}
#else
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) return;
    if (status >= kCLAuthorizationStatusAuthorizedAlways) {
        // 允许
        [self requestLocation];
    } else {
        // 拒绝
        [self close:@"请允许应用使用位置信息"];
    }
}
#endif

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
    if (!self.location || self.location.name.length <= 0) {
        [self.view showDialog:MNLoadDialogStyleWechatError message:@"请选择详细位置"];
        return;
    }
    @weakify(self);
    [self.view showWechatDialog];
    [self.headerView takeSnapshotCompletion:^(UIImage *image) {
        @strongify(self);
        [self.view closeDialog];
        if (!image) {
            [self.view showDialog:MNLoadDialogStyleWechatError message:@"获取位置截图失败"];
            return;
        }
        if (self.didSelectHandler) {
            self.location.snapshot = image;
            self.didSelectHandler(self.location);
        }
    }];
}

#pragma mark - Super
- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

#pragma mark - dealloc
- (void)dealloc {
    _search.delegate = nil;
    [_search cancelAllRequests];
    _locationManager.delegate = nil;
    [_locationManager stopUpdatingLocation];
}

@end
