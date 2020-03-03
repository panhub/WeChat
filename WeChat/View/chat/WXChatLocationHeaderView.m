//
//  WXChatLocationHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatLocationHeaderView.h"

@interface WXChatLocationHeaderView () <MAMapViewDelegate>

@end

@implementation WXChatLocationHeaderView
- (void)createView {
    [super createView];
    
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, (SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAV_BAR_HEIGHT*2.f)/2.f)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    mapView.delegate = self;
    mapView.showsUserLocation = NO;
    mapView.userTrackingMode = MAUserTrackingModeNone;
    mapView.mapType = MAMapTypeStandard;
    mapView.showsIndoorMap = YES;
    mapView.showsCompass = NO;
    mapView.zoomEnabled = YES;
    mapView.zoomLevel = 15.f;
    mapView.scrollEnabled = YES;
    mapView.rotateEnabled = NO;
    mapView.rotateCameraEnabled = NO;
    [self.contentView addSubview:mapView];
    self.mapView = mapView;
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
        annotationView.animatesDrop = NO;
        annotationView.draggable = NO;
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}

- (void)mapViewDidFailLoadingMap:(MAMapView *)mapView withError:(NSError *)error {
    @weakify(self);
    [[MNAlertView alertViewWithTitle:@"发生错误" message:@"地图加载失败, 请稍后重试!" handler:^(MNAlertView *alertView, NSInteger buttonIndex) {
        @strongify(self);
        [self.viewController.navigationController popViewControllerAnimated:YES];
    } ensureButtonTitle:@"确定" otherButtonTitles: nil] show];
}

#pragma mark - Setter
- (void)setLocation:(AMapGeoPoint *)location {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude);
    [self.mapView removeAnnotations:self.mapView.annotations];
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    [self.mapView addAnnotation:annotation];
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

- (void)takeSnapshotCompletion:(void(^)(UIImage *image))handler {
    NSArray *annotations = self.mapView.annotations;
    if (annotations.count > 0) {
        MAPointAnnotation *annotation = annotations.firstObject;
        [self.mapView setCenterCoordinate:annotation.coordinate animated:NO];
    }
    CGRect rect = self.mapView.annotationVisibleRect;
    CGFloat height = rect.size.height;
    rect.size.height = rect.size.width/2.f;
    rect.origin.y += (height - rect.size.height)/2.f;
    [self.mapView takeSnapshotInRect:rect withCompletionBlock:^(UIImage *resultImage, NSInteger state) {
        if (handler) handler(resultImage);
    }];
}

@end
