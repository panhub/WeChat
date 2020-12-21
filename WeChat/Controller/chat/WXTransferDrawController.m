//
//  WXTransferDrawController.m
//  MNChat
//
//  Created by Vincent on 2019/6/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTransferDrawController.h"
#import "WXTransferDoneController.h"
#import "WXRedpacket.h"
#import "WXMoneyLabel.h"
#import "WXChangeModel.h"

@interface WXTransferDrawController ()
@property (nonatomic, strong) WXRedpacket *redpacket;
@end

@implementation WXTransferDrawController
- (instancetype)initWithRedpacket:(WXRedpacket *)redpacket {
    if (self = [super init]) {
        self.redpacket = redpacket;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationBar.shadowView.hidden = YES;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *waitView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 60.f), MN_TOP_BAR_HEIGHT + 50.f, 60.f, 60.f) image:UIImageNamed(@"wx_transfer_waiting")];
    [self.contentView addSubview:waitView];
    
    UILabel *waitLabel = [UILabel labelWithFrame:CGRectMake(0.f, waitView.bottom_mn + 40.f, self.contentView.width_mn, 16.f) text:@"待确认收款" alignment:NSTextAlignmentCenter textColor:UIColor.darkTextColor font:UIFontRegular(16.f)];
    [self.contentView addSubview:waitLabel];
    
    WXMoneyLabel *moneyLabel = [[WXMoneyLabel alloc] initWithFrame:CGRectMake(15.f, waitLabel.bottom_mn + 18.f, self.contentView.width_mn - 30.f, 49.f)];
    moneyLabel.money = self.redpacket.money;
    moneyLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:moneyLabel];
    
    NSString *time = [NSDate stringValueWithTimestamp:self.redpacket.create_time format:@"yyyy-MM-dd HH:mm:ss"];
    UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(0.f, self.contentView.height_mn - 63.f, self.contentView.width_mn, 12.f) text:[@"转账时间: " stringByAppendingString:time] alignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .6f) font:UIFontRegular(12.f)];
    [self.contentView addSubview:timeLabel];
    
    NSString *text = @"1天内未确认，将退还给对方。立即退还";
    NSMutableAttributedString *string = text.attributedString.mutableCopy;
    string.font = UIFontRegular(14.f);
    string.alignment = NSTextAlignmentCenter;
    string.color = timeLabel.textColor;
    [string setColor:TEXT_COLOR range:[text rangeOfString:@"立即退还"]];
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(0.f, timeLabel.top_mn - 100.f, self.contentView.width_mn, 14.f) text:string alignment:NSTextAlignmentCenter textColor:nil font:nil];
    [self.contentView addSubview:hintLabel];
    
    UIButton *confirmButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.view.width_mn - 185.f), hintLabel.top_mn - 72.f, 185.f, 47.f) image:nil title:@"确认收款" titleColor:[UIColor whiteColor] titleFont:UIFontMedium(18.f)];
    confirmButton.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(confirmButton, 4.f);
    [confirmButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:confirmButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)buttonClicked {
    [self.view showWechatDialog];
    /// 修改领取时间
    self.redpacket.draw_time = [NSDate timestamps];
    /// 插入零钱记录
    WXChangeModel *change = [WXChangeModel new];
    change.title = @"微信转账";
    change.money = self.redpacket.money.floatValue;
    change.timestamp = self.redpacket.draw_time;
    change.type = @"收入";
    change.channel = WXChangeChannelTransfer;
    change.note = self.redpacket.text;
    change.uid = self.redpacket.from_uid;
    if ([[MNDatabase database] insertToTable:WXChangeTableName model:change]) {
        dispatch_async_default(^{
            @PostNotify(WXChangeUpdateNotificationName, nil);
        });
        dispatch_after_main(.5f, ^{
            [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"received_cash" ofType:@"caf" inDirectory:@"sound"] shake:NO];
            if (self.completionHandler) self.completionHandler();
            [self.view closeDialogWithCompletionHandler:^{
                /// 回调
                WXTransferDoneController *vc = [[WXTransferDoneController alloc] initWithRedpacket:self.redpacket];
                vc.networking = NO;
                vc.cls = @"WXChatViewController";
                [self.navigationController pushViewController:vc animated:NO];
            }];
        });
    } else {
        [self.view showInfoDialog:@"操作失败"];
    }
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
