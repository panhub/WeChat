//
//  WXMapViewController.m
//  MNChat
//
//  Created by Vincent on 2019/5/16.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMapViewController.h"
#import "WXMapHeaderView.h"
#import "WXMapRightView.h"

@interface WXMapViewController ()<MAMapViewDelegate, AMapSearchDelegate, WXMapHeaderViewDelegate>
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapAddressComponent *address;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) WXMapHeaderView *headerView;
@property (nonatomic, strong) WXMapLocation *point;
@end

@implementation WXMapViewController
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithPoint:[WXMapLocation pointWithCoordinate:coordinate]];
}

- (instancetype)initWithPoint:(WXMapLocation *)point {
    if (self = [super init]) {
        self.point = point;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:self.contentView.bounds];
    mapView.delegate = self;
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MAUserTrackingModeFollow;
    mapView.mapType = MAMapTypeStandard;
    mapView.showsIndoorMap = YES;
    mapView.showsCompass = NO;
    mapView.zoomEnabled = YES;
    mapView.zoomLevel = 15.f;
    mapView.scrollEnabled = YES;
    mapView.rotateEnabled = NO;
    mapView.rotateCameraEnabled = NO;
    if (self.point) [mapView setCenterCoordinate:self.point.coordinate animated:NO];
    [self.contentView addSubview:mapView];
    self.mapView = mapView;
    
    WXMapHeaderView *headerView = [WXMapHeaderView new];
    headerView.delegate = self;
    [self.contentView addSubview:headerView];
    self.headerView = headerView;
    
    /*
    WXMapRightView *rightView = [WXMapRightView new];
    [self.contentView addSubview:rightView];
    */
}

- (void)loadData {
//    @weakify(self);
//    [MNAuthenticator requestLocationAuthorizationStatusWithHandler:^(BOOL allowed) {
//        if (allowed) {
//            @strongify(self);
//            if (!self.point) return;
//            AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
//            request.requireExtension = YES;
//            request.location = [AMapGeoPoint locationWithLatitude:self.point.latitude longitude:self.point.longitude];
//            [self.search AMapReGoecodeSearch:request];
//        } else {
//            [[MNAlertView alertViewWithTitle:nil message:@"请允许应用访问您的位置信息" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
//                @strongify(self);
//                [self.navigationController popViewControllerAnimated:YES];
//            } ensureButtonTitle:@"确定" otherButtonTitles:nil] show];
//        }
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear && self.point) {
        /// 显示位置大头针
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = self.point.coordinate;
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) return nil;
    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"com.map.point.reuseIndentifier"];
        if (annotationView == nil) {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"com.map.point.reuseIndentifier"];
        }
        annotationView.canShowCallout = NO;
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

#pragma mark - AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    self.address = response.regeocode.addressComponent;
    self.headerView.text = response.regeocode.formattedAddress;
}

#pragma mark - WXMapHeaderViewDelegate
- (void)headerView:(WXMapHeaderView *)headerView buttonClickedEvent:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)headerViewClickedEvent:(WXMapHeaderView *)headerView {
    
}

#pragma mark - Getter
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

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
