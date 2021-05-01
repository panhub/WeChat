//
//  WXWeatherViewController.m
//  WeChat
//
//  Created by Vincent on 2019/5/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWeatherViewController.h"
#import "WXWeatherRequest.h"
#import "WXWeatherModel.h"
#import "WXCityModel.h"

@interface WXWeatherViewController ()
@property (nonatomic, strong) WXDistrictModel *districtModel;
@property (nonatomic, strong) WXWeatherModel *weatherModel;
@end

@implementation WXWeatherViewController
- (instancetype)initWithDistrict:(WXDistrictModel *)districtModel {
    if (self = [super init]) {
        self.districtModel = districtModel;
        WXWeatherRequest *request = [[WXWeatherRequest alloc] initWithCity:districtModel.city district:districtModel.name];
        self.httpRequest = request;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor clearColor];
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - MNNavigationBarDelegate
- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIControl *leftItemView = [[UIControl alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
    leftItemView.touchInset = UIEdgeInsetsMake(0.f, -7.f, 0.f, 0.f);
    UIImageView *backView = [UIImageView imageViewWithFrame:CGRectMake(-7.f, 0.f, leftItemView.height_mn, leftItemView.height_mn) image:UIImageWithUnicode(MNFontUnicodeBack, [UIColor whiteColor], leftItemView.height_mn)];
    backView.userInteractionEnabled = NO;
    [leftItemView addSubview:backView];
    NSString *string = [NSString stringWithFormat:@"%@-%@", self.districtModel.city, self.districtModel.name];
    CGFloat width = [string sizeWithFont:[UIFont systemFontOfSize:16.f]].width;
    UILabel *cityLabel = [UILabel labelWithFrame:CGRectMake(backView.right_mn - 5.f, MEAN(leftItemView.height_mn - 16.f), width, 16.f) text:string alignment:NSTextAlignmentLeft textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:16.f]];
    [leftItemView addSubview:cityLabel];
    leftItemView.width_mn = cityLabel.right_mn;
    [leftItemView addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItemView;
}

#pragma mark - Super
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (BOOL)loadDataFinishWithRequest:(__kindof MNHTTPDataRequest *)request {
    if ([super loadDataFinishWithRequest:request]) {
        self.weatherModel = [request.dataArray lastObject];
    }
    return YES;
}

- (void)showEmptyViewNeed:(BOOL)isNeed image:(UIImage *)image message:(NSString *)message title:(NSString *)title type:(MNEmptyEventType)type {
    [super showEmptyViewNeed:isNeed image:[MNBundle imageForResource:@"empty_data_jd"] message:message title:@"点击重试" type:MNEmptyEventTypeReload];
}

@end
