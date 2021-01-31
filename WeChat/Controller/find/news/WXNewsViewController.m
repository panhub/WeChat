//
//  WXNewsViewController.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsViewController.h"
#import "WXNewsCategory.h"
#import "WXNewsListController.h"

@interface WXNewsViewController ()<MNSegmentControllerDelegate, MNSegmentControllerDataSource>
@property (nonatomic, copy) NSArray <WXNewsCategory *>*categorys;
@property (nonatomic, strong) MNSegmentController *segmentController;
@end

@implementation WXNewsViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"新闻";
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowView.hidden = YES;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    self.contentView.backgroundColor = UIColor.whiteColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MNSegmentController *segmentController = [[MNSegmentController alloc] initWithFrame:self.contentView.bounds];
    segmentController.delegate = self;
    segmentController.dataSource = self;
    segmentController.fixedHeight = MN_NAV_BAR_HEIGHT;
    self.segmentController = segmentController;
    
    [self addChildViewController:segmentController inView:self.contentView];
}

- (void)loadData {
    NSArray <NSString *>*titles = @[@"社会", @"国内", @"国际", @"娱乐", @"体育", @"军事", @"科技", @"财经", @"时尚"];
    NSArray <NSString *>*types = @[@"shehui", @"guonei", @"guoji", @"yule", @"tiyu", @"junshi", @"keji", @"caijing", @"shishang"];
    NSMutableArray <WXNewsCategory *>*categorys = @[].mutableCopy;
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXNewsCategory *m = [WXNewsCategory modelWithTitle:obj type:types[idx]];
        [categorys addObject:m];
    }];
    self.categorys = categorys.copy;
}

#pragma mark - MNSegmentControllerDelegate && MNSegmentControllerDataSource
- (UIView *)segmentControllerShouldLoadHeaderView:(MNSegmentController *)segmentController {
    [self.navigationBar removeFromSuperview];
    return self.navigationBar;
}


- (NSArray <NSString *>*)segmentControllerShouldLoadPageTitles:(MNSegmentController *)segmentController {
    NSMutableArray <NSString *>*titles = [NSMutableArray arrayWithCapacity:self.categorys.count];
    [self.categorys.copy enumerateObjectsUsingBlock:^(WXNewsCategory * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:obj.title];
    }];
    return titles.copy;
}

- (UIViewController *)segmentController:(MNSegmentController *)segmentController childControllerOfPageIndex:(NSUInteger)pageIndex {
    WXNewsListController *vc = [[WXNewsListController alloc] initWithFrame:segmentController.view.bounds category:self.categorys[pageIndex]];
    return vc;
}

- (void)segmentControllerInitializedConfiguration:(MNSegmentConfiguration *)configuration {
    configuration.height = 43.f;
    configuration.titleMargin = 45.f;
    configuration.contentMode = MNSegmentContentModeFill;
    configuration.shadowMask = MNSegmentShadowMaskFit;
    configuration.backgroundColor = UIColor.whiteColor;
    configuration.titleFont = [UIFont systemFontOfSize:16.5f];
    configuration.selectedTitleFont = [UIFont systemFontOfSize:16.5f];
    configuration.titleColor = [UIColor.darkTextColor colorWithAlphaComponent:.93f];
    configuration.selectedColor = THEME_COLOR;
    configuration.shadowColor = THEME_COLOR;
    configuration.shadowSize = CGSizeMake(10.f, 2.f);
    configuration.separatorColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
}

- (void)segmentControllerPageDidScroll:(MNSegmentController *)segmentController {
    CGFloat contentOffsetY = segmentController.contentOffset.y;
    //contentOffsetY = MIN(contentOffsetY, MN_NAV_BAR_HEIGHT);
    //self.navigationBar.alpha = (contentOffsetY - MN_NAV_BAR_HEIGHT)/MN_NAV_BAR_HEIGHT;
    NSLog(@"%f", contentOffsetY);
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
