//
//  WXLocationViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationViewController.h"
#import "WXLocationResultController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <CoreLocation/CLLocation.h>
#import "WXLocationListCell.h"
#import "WXLocation.h"

@interface WXLocationViewController ()<AMapSearchDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
/// 搜索对象
@property (nonatomic, strong) AMapSearchAPI *search;
/// 选择索引
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
/// 定位对象
@property (nonatomic, strong) AMapLocationManager *locationManager;
/// 定位权限
@property (nonatomic, strong) CLLocationManager *locationAuthenticator;
/// 位置信息
@property (nonatomic, strong) NSMutableArray <AMapPOI *>*dataSource;
@end

@implementation WXLocationViewController
- (void)initialized {
    [super initialized];
    self.title = @"所在位置";
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
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
        textField.placeholder = @"搜索附近位置";
        textField.tintColor = THEME_COLOR;
        textField.frame = CGRectMake(10.f, MEAN(searchBar.height_mn - 35.f), searchBar.width_mn - 20.f, 35.f);
    };
    MNAdsorbView *headerView = [[MNAdsorbView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.tableView.width_mn, self.searchBar.height_mn + 10.f)];
    headerView.imageView.backgroundColor = VIEW_COLOR;
    [headerView.contentView addSubview:self.searchBar];
    self.tableView.tableHeaderView = headerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// 检索结果展示
    WXLocationResultController *resultController = [[WXLocationResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - MN_STATUS_BAR_HEIGHT - self.searchBar.height_mn)];
    @weakify(self);
    resultController.didSelectHandler = ^(WXLocation *location) {
        @strongify(self);
        if (self.didSelectHandler) self.didSelectHandler(location);
        [self.navigationController popViewControllerAnimated:YES];
    };
    self.updater = resultController;
    self.searchResultController = resultController;
    
    [self requestLocationAuthorizationStatus];
}

- (void)requestLocation {
    @weakify(self);
    [self.contentView showWechatDialog];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        @strongify(self);
        if (!location || !regeocode || error) {
            [self.contentView closeDialog];
        } else {
            WXLocationResultController *vc = (WXLocationResultController *)self.searchResultController;
            vc.city = regeocode.city;
            vc.coordinate = location.coordinate;
            [self startPOIAroundSearch:location];
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        }
    }];
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
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
    }
    [self.contentView closeDialog];
}

#pragma mark - 开启周边搜索
- (void)startPOIAroundSearch:(CLLocation *)location {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    request.sortrule = 0;
    request.offset = 50;
    request.page = 1;
    request.requireExtension = YES;
    request.requireSubPOIs = YES;
    request.radius = 10000;
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    [self.search cancelAllRequests];
    [self.search AMapPOIAroundSearch:request];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataSource.count > 0;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((WXLocationResultController *)self.searchResultController).city ? (self.dataSource.count + 2) : (self.dataSource.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WXLocationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.location.cell"];
    if (!cell) {
        cell = [[WXLocationListCell alloc] initWithReuseIdentifier:@"com.wx.location.cell" size:CGSizeMake(tableView.width_mn, tableView.rowHeight)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(WXLocationListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.text = @"不显示位置";
    } else if (indexPath.row == 1) {
        cell.text = ((WXLocationResultController *)self.searchResultController).city ? : @"";
        cell.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .8f);
    } else {
        cell.location = self.dataSource[indexPath.row - 2];
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        self.selectIndexPath = nil;
    } else {
        if (self.selectIndexPath) {
            UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:self.selectIndexPath];
            selectCell.accessoryType = UITableViewCellAccessoryNone;
        }
        self.selectIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
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
                                              title:@"完成"
                                         titleColor:[UIColor whiteColor]
                                               titleFont:[UIFont systemFontOfSizes:16.f weights:.15f]];
    rightItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightItem, 3.f);
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    /// 判断是否选择了位置
    if (self.selectIndexPath) {
        WXLocation *location;
        NSUInteger row = self.selectIndexPath.row;
        if (row == 0) {
            /// 不选择位置
        } else if (row == 1) {
            /// 城市
            WXLocationResultController *vc = (WXLocationResultController *)self.searchResultController;
            location = [WXLocation locationWithCoordinate:vc.coordinate];
            location.name = ((WXLocationResultController *)self.searchResultController).city;
        } else {
            /// 具体位置
            AMapPOI *poi = self.dataSource[row - 2];
            location = [WXLocation locationWithLatitude:poi.location.latitude longitude:poi.location.longitude];
            location.name = poi.city ? : ((WXLocationResultController *)self.searchResultController).city;
            location.address = poi.name;
        }
        if (self.didSelectHandler) self.didSelectHandler(location);
    }
    [self.navigationController popViewControllerAnimated:YES];
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

- (NSMutableArray <AMapPOI *>*)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

#pragma mark - Super
- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

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
