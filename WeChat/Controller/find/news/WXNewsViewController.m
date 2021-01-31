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
    
    MNSegmentController *segmentController = [[MNSegmentController alloc] initWithFrame:self.contentView.bounds];
    segmentController.delegate = self;
    segmentController.dataSource = self;
    self.segmentController = segmentController;
    
    [self addChildViewController:segmentController inView:self.contentView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    configuration.titleColor = UIColor.darkTextColor;
    configuration.selectedColor = THEME_COLOR;
    configuration.shadowColor = THEME_COLOR;
    configuration.shadowSize = CGSizeMake(10.f, 2.f);
    configuration.separatorColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
