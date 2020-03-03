//
//  WXLocationViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/11.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationViewController.h"
#import "WXLocationResultController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "WXLocationListCell.h"
#import "WXMapLocation.h"

@interface WXLocationViewController () <MNSearchControllerDelegate, AMapLocationManagerDelegate, AMapSearchDelegate, UITextFieldDelegate>
/// 选择索引
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
/// 高德位置
@property (nonatomic, strong) AMapGeoPoint *location;
/// 搜索对象
@property (nonatomic, strong) AMapSearchAPI *search;
/// 城市信息
@property (nonatomic, strong) AMapLocationReGeocode *address;
/// 定位对象
@property (nonatomic, strong) AMapLocationManager *locationManager;
/// 位置信息
@property (nonatomic, strong) NSMutableArray <AMapPOI *>*dataSource;
@end

@implementation WXLocationViewController
- (void)initialized {
    [super initialized];
    self.title = @"所在位置";
    self.delegate = self;
    self.dataSource = [NSMutableArray arrayWithCapacity:0];
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
    WXLocationResultController *resultController = [[WXLocationResultController alloc] initWithFrame:CGRectMake(0.f, self.navigationBar.height_mn + self.tableView.tableHeaderView.height_mn, self.view.width_mn, self.view.height_mn - UIStatusBarHeight() - self.searchBar.height_mn)];
    @weakify(self);
    resultController.didSelectHandler = ^(WXMapLocation *location) {
        @strongify(self);
        if (self.didSelectHandler) {
            location.name = self.address.city;
            self.didSelectHandler(location);
        }
        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - AMapLocationManagerDelegate
/// 定位失败
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    [self.contentView closeDialog];
    [manager stopUpdatingLocation];
    [self.dataSource removeAllObjects];
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

/// 位置更新
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode {
    /// 关闭定位
    [manager stopUpdatingLocation];
    /// 开启搜索
    [self startPOIAroundSearch:location];
    /// 刷新表, 记录城市
    self.address = reGeocode;
    @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
}

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager*)locationManager {
    [locationManager requestAlwaysAuthorization];
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

#pragma mark - 开启周边搜索
- (void)startPOIAroundSearch:(CLLocation *)location {
    self.location = [AMapGeoPoint locationWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = self.location;
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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return self.dataSource.count > 0;
}

#pragma mark - MNSearchControllerDelegate
- (void)willPresentSearchController:(MNSearchViewController *)searchController {
    WXLocationResultController *vc = (WXLocationResultController *)(searchController.searchResultController);
    vc.location = self.location;
    vc.address = self.address;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _address ? (self.dataSource.count + 2) : (self.dataSource.count + 1);
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
        cell.text = self.address.city.length > 0 ? self.address.city : @"";
        cell.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .8f);
    } else {
        cell.location = self.dataSource[indexPath.row - 2];
    }
    if (self.selectIndexPath && self.selectIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
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
        WXMapLocation *location;
        NSUInteger row = self.selectIndexPath.row;
        if (row == 0) {
            /// 不选择位置
        } else if (row == 1) {
            /// 城市
            location = [WXMapLocation pointWithLatitude:self.location.latitude longitude:self.location.longitude];
            location.name = self.address.city;
        } else {
            /// 具体位置
            location = [WXMapLocation pointWithLatitude:self.location.latitude longitude:self.location.longitude];
            location.name = self.address.city;
            AMapPOI *poi = self.dataSource[row - 2];
            location.address = poi.name;
        }
        if (self.didSelectHandler) {
            self.didSelectHandler(location);
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (AMapLocationManager *)locationManager {
    if (!_locationManager) {
        AMapLocationManager *locationManager = [[AMapLocationManager alloc] init];
        //locationManager.delegate = self;
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
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModel];
}

#pragma mark - dealloc
- (void)dealloc {
    _search.delegate = nil;
    [_search cancelAllRequests];
    _locationManager.delegate = nil;
    [_locationManager stopUpdatingLocation];
}

@end
