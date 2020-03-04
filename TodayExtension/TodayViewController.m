//
//  TodayViewController.m
//  TodayExtension
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TodayViewController.h"
#import "UIView+MNLayout.h"
#import "TEWatchView.h"
#import "TEMemoryLabel.h"
#import "TEStreamLabel.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) TEWatchView *watchView;
@property (nonatomic, strong) TEStreamLabel *streamLabel;
@property (nonatomic, strong) TEMemoryLabel *memoryLabel;
@property (nonatomic, strong) TEMemoryLabel *diskMemoryLabel;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /// 配置视图大小
    //self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    self.preferredContentSize = CGSizeMake(0.f, 100.f);
    
    /// 钟表
    TEWatchView *watchView = [[TEWatchView alloc] initWithFrame:CGRectMake(20.f, 10.f, 90.f, 90.f)];
    watchView.startAngle = -M_PI_2;
    watchView.endAngle = M_PI_2*3;
    watchView.innerInterval = 2.f;
    watchView.scaleInterval = 4.f;
    watchView.strokeColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
    watchView.fillColor = [UIColor clearColor];
    watchView.divide = 12;
    watchView.subdivide = 5;
    watchView.detailViewHandler = ^UIView *(NSUInteger idx) {
        if (idx == 0) return nil;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 20.f, 10.f)];
        label.text = [NSString stringWithFormat:@"%@", @(idx)];
        label.font = [UIFont systemFontOfSize:10.f];
        label.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    };
    watchView.layer.cornerRadius = watchView.width_mn/2.f;
    watchView.clipsToBounds = YES;
    [watchView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(watchClicked)]];
    [self.view addSubview:watchView];
    self.watchView = watchView;
    
    CGFloat interval = (watchView.height_mn - 60.f - 10.f)/2.f;
    
    /// 流量
    TEStreamLabel *streamLabel = [[TEStreamLabel alloc] initWithFrame:CGRectMake(watchView.right_mn + 30.f, watchView.top_mn + 5.f, self.view.width_mn - watchView.right_mn - 70.f, 20.f)];
    [self.view addSubview:streamLabel];
    self.streamLabel = streamLabel;
    
    /// 内存
    TEMemoryLabel *memoryLabel = [[TEMemoryLabel alloc] initWithFrame:streamLabel.frame];
    memoryLabel.top_mn = streamLabel.bottom_mn + interval;
    memoryLabel.type = TEMemoryLabelMemory;
    [self.view addSubview:memoryLabel];
    self.memoryLabel = memoryLabel;
    
    /// 磁盘
    TEMemoryLabel *diskMemoryLabel = [[TEMemoryLabel alloc] initWithFrame:memoryLabel.frame];
    diskMemoryLabel.top_mn = memoryLabel.bottom_mn + interval;
    diskMemoryLabel.type = TEMemoryLabelDisk;
    [self.view addSubview:diskMemoryLabel];
    self.diskMemoryLabel = diskMemoryLabel;
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*
    if (@available(iOS 10.0, *)) {
        self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    } else {
        [self.extensionContext setValue:@(1) forKey:@"widgetLargestAvailableDisplayMode"];
    }
    */
    [self fire];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fire];
    [_memoryLabel loadData];
    [_diskMemoryLabel loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self invalidate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self invalidate];
}

#pragma mark - Event
- (void)watchClicked {
    NSString *url = @"mnchat://app.extension.today?action=WXWatchViewController";
    [self.extensionContext openURL:[NSURL URLWithString:url] completionHandler:nil];
}

#pragma mark - NCWidgetProviding
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

/*
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (activeDisplayMode == NCWidgetDisplayModeCompact) {
            self.preferredContentSize = CGSizeMake(0.f, 100.f);
        } else {
            self.preferredContentSize = CGSizeMake(0.f, 180.f);
        }
    });
}
#pragma clang diagnostic pop
*/
#pragma mark - 配置边距<似乎没作用>
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets {
    return UIEdgeInsetsZero;
}

#pragma mark - Timer
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:1.f
                                         target:self
                                       selector:@selector(updateData)
                                       userInfo:nil
                                        repeats:YES];
    }
    return _timer;
}

- (void)updateData {
    [_watchView updateTime];
    [_streamLabel updateData];
}

- (void)fire {
    if (_timer) return;
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self.timer fire];
}

- (void)invalidate {
    if (!_timer) return;
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - dealloc
- (void)dealloc {
    [self invalidate];
}

@end
