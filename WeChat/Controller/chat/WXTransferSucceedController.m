//
//  WXTransferSucceedController.m
//  WeChat
//
//  Created by Vincent on 2019/5/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferSucceedController.h"
#import "WXMoneyLabel.h"

@interface WXTransferSucceedController ()
@property (nonatomic, strong) WXUser *user;
@end

@implementation WXTransferSucceedController
- (instancetype)initWithUser:(WXUser *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)createView {
    [super createView];

    self.contentView.backgroundColor = [UIColor whiteColor];
    
    /// 转账成功图片
    UIImage *image = [UIImage imageNamed:@"wx_transfer_succeed"];
    CGSize size = CGSizeMultiplyToWidth(image.size, 33.f);
    UIImageView *succeedView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.contentView.width_mn - size.width), MN_TOP_BAR_HEIGHT + 5.f, size.width, size.height) image:image];
    [self.contentView addSubview:succeedView];
    /// 转账成功文字
    UILabel *succeedLabel = [UILabel labelWithFrame:CGRectMake(0.f, succeedView.bottom_mn + 15.f, self.contentView.width_mn, 17.f) text:@"支付成功" alignment:NSTextAlignmentCenter textColor:MN_R_G_B(26.f, 173.f, 25.f) font:UIFontRegular(17.f)];
    [self.contentView addSubview:succeedLabel];
    
    /// 收款
    UILabel *nameLabel = [UILabel labelWithFrame:CGRectMake(0.f, 200.f, self.contentView.width_mn, 20.f) text:[NSString stringWithFormat:@"待%@确认收款", self.user.name] alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .85f) font:[UIFont systemFontOfSize:17.f]];
    [self.contentView addSubview:nameLabel];
    
    /// 金额
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(15.f, nameLabel.bottom_mn + 8.f, self.contentView.width_mn - 30.f, 45.f)];
    moneyLabel.money = self.money;
    moneyLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:moneyLabel];
    
    /// 完成
    UIButton *button = [UIButton buttonWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 180.f), self.contentView.height_mn - 134.f, 180.f, 34.f) image:nil title:@"完成" titleColor:succeedLabel.textColor titleFont:UIFontRegular(16.f)];
    UIViewSetBorderRadius(button, 4.f, .8f, succeedLabel.textColor);
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactiveTransitionEnabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactiveTransitionEnabled = YES;
}

- (void)buttonClicked {
    [self.navigationController popToViewController:[self.navigationController seekViewControllerOfClass:NSClassFromString(@"WXChatViewController")] animated:YES];
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypePushModal];
}

@end
