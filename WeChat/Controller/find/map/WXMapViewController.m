//
//  WXMapViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/16.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMapViewController.h"
#import <CoreLocation/CLLocation.h>

@interface WXMapViewController ()<MAMapViewDelegate>
@property (nonatomic, strong) WXLocation *location;
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation WXMapViewController
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [self initWithLocation:[WXLocation locationWithCoordinate:coordinate]];
}

- (instancetype)initWithLocation:(WXLocation *)location {
    if (self = [super init]) {
        self.location = location;
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
    if (self.location) [mapView setCenterCoordinate:self.location.coordinate animated:NO];
    [self.contentView addSubview:mapView];
    self.mapView = mapView;

    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(10.f, MN_STATUS_BAR_HEIGHT, self.contentView.width_mn - 20.f, MN_NAV_BAR_HEIGHT)];
    titleView.backgroundColor = UIColor.whiteColor;
    titleView.layer.cornerRadius = 3.f;
    titleView.layer.shadowOpacity = 1.f;
    titleView.layer.shadowOffset = CGSizeZero;
    titleView.layer.shadowColor = [[UIColor.grayColor colorWithAlphaComponent:.3f] CGColor];
    titleView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:titleView.layer.bounds] CGPath];
    [self.contentView addSubview:titleView];
    
    UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(kNavItemMargin - titleView.left_mn, (titleView.height_mn - kNavItemSize)/2.f, kNavItemSize, kNavItemSize)
                                               image:UIImageWithUnicode(MNFontUnicodeBack, UIColor.darkTextColor, kNavItemSize)
                                               title:nil
                                          titleColor:nil
                                                titleFont:nil];
    backButton.touchInset = UIEdgeInsetWith(-5.f);
    [backButton addTarget:self action:@selector(backButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backButton];
    
    UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero text:self.location.debugDescription textColor:[UIColor.darkTextColor colorWithAlphaComponent:.85f] font:UIFontRegular(17.f)];
    titleLabel.numberOfLines = 1;
    [titleLabel sizeToFit];
    titleLabel.userInteractionEnabled = NO;
    titleLabel.centerY_mn = backButton.centerY_mn;
    titleLabel.left_mn = backButton.right_mn;
    titleLabel.width_mn = MIN(titleView.width_mn - titleLabel.left_mn - backButton.left_mn, titleLabel.width_mn);
    [titleView addSubview:titleLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstAppear && self.location) {
        /// 显示位置大头针
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        annotation.coordinate = self.location.coordinate;
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - MAMapViewDelegate
- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager {
    [locationManager requestAlwaysAuthorization];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
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

#pragma mark - Event
- (void)backButtonTouchUpInside:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
