//
//  WXEmoticonViewController.m
//  MNChat
//
//  Created by Vincent on 2019/7/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEmoticonViewController.h"
#import "WXMineEmoticonController.h"
#import "WXAllEmoticonController.h"

@interface WXEmoticonViewController ()<MNSegmentControllerDelegate, MNSegmentControllerDataSource>
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) MNSegmentController *segmentController;
@end

@implementation WXEmoticonViewController

- (void)createView {
    [super createView];
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = VIEW_COLOR;
    
    self.contentView.clipsToBounds = YES;
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"我的表情", @"全部表情"]];
    segment.frame = CGRectMake(0.f, MEAN(self.navigationBar.height_mn - UIStatusBarHeight() - 28.f) + UIStatusBarHeight(), 145.f, 28.f);
    segment.centerX_mn = self.navigationBar.width_mn/2.f;
    segment.tintColor = [UIColor blackColor];
    segment.selectedSegmentIndex = 0;
    [segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
    [segment setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateSelected];
    [segment addTarget:self action:@selector(segmentControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.navigationBar addSubview:segment];
    self.segmentControl = segment;
    
    MNSegmentController *segmentController = [[MNSegmentController alloc] initWithFrame:CGRectMake(0.f, -40.f, self.contentView.width_mn, self.contentView.height_mn + 40.f)];
    segmentController.delegate = self;
    segmentController.dataSource = self;
    self.segmentController = segmentController;
    
    [self addChildViewController:segmentController inView:self.contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - SegmentControlValueChanged
- (void)segmentControlValueChanged:(UISegmentedControl *)segment {
    [self.segmentController scrollPageToIndex:segment.selectedSegmentIndex];
}

#pragma mark - MNSegmentControllerDataSource
- (NSArray <NSString *>*)segmentControllerShouldLoadPageTitles:(MNSegmentController *)segmentController {
    return @[@"我的表情", @"全部表情"];
}

- (UIViewController *)segmentController:(MNSegmentController *)segmentController childControllerOfPageIndex:(NSUInteger)pageIndex {
    if (pageIndex == 0) {
        return [[WXMineEmoticonController alloc] initWithFrame:segmentController.view.bounds];
    }
    return [[WXAllEmoticonController alloc] initWithFrame:segmentController.view.bounds];
}

#pragma mark - MNSegmentControllerDelegate
- (void)segmentController:(MNSegmentController*)segmentController
      didLeavePageOfIndex:(NSUInteger)fromPageIndex
            toPageOfIndex:(NSUInteger)toPageIndex {
    self.segmentControl.selectedSegmentIndex = toPageIndex;
}

@end
