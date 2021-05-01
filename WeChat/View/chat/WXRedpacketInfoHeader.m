//
//  WXRedpacketInfoHeader.m
//  WeChat
//
//  Created by Vincent on 2019/5/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketInfoHeader.h"
#import "WXRedpacket.h"

@interface WXRedpacketInfoHeader ()
@property (nonatomic, strong) UIImageView *closeView;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation WXRedpacketInfoHeader
- (void)createView {
    [super createView];
    
    /// 背景图
    self.imageView.image = [UIImage imageWithColor:MN_R_G_B(243.f, 85.f, 67.f)];
    
    /// 底部
    UIImage *image = [UIImage imageNamed:@"wx_redpacket_envelope"];
    CGSize size = CGSizeMultiplyToWidth(image.size, self.width_mn);
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.height_mn - size.height, size.width, size.height)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:whiteView];
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:whiteView.bounds image:image];
    [whiteView addSubview:imageView];
    
    /// 头像
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(0.f, MN_TOP_BAR_HEIGHT + 30.f, 25.f, 25.f) image:nil];
    headView.layer.cornerRadius = 4.f;
    headView.clipsToBounds = YES;
    [self.contentView addSubview:headView];
    self.headView = headView;
    
    UILabel *fromLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, headView.height_mn) text:nil textColor:MN_R_G_B(254.f, 225.f, 177.f) font:[UIFont systemFontOfSizes:headView.height_mn - 6.f weights:.5f]];
    fromLabel.centerY_mn = headView.centerY_mn;
    fromLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:fromLabel];
    self.fromLabel = fromLabel;
    
    UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(15.f, headView.bottom_mn + 10.f, self.contentView.width_mn - 30.f, 14.f) text:nil alignment:NSTextAlignmentCenter textColor:fromLabel.textColor font:@(14.f)];
    [self.contentView addSubview:textLabel];
    self.textLabel = textLabel;
    
    UILabel *moneyLabel = [UILabel labelWithFrame:CGRectMake(15.f, textLabel.bottom_mn + 50.f, self.contentView.width_mn - 30.f, 60.f) text:nil textColor:nil font:nil];
    [self.contentView addSubview:moneyLabel];
    self.moneyLabel = moneyLabel;
    
    UIFont *font = self.textLabel.font;
    image = UIImageNamed(@"wx_redpacket_arrow");
    size = CGSizeMultiplyToHeight(image.size, font.pointSize - 3.f);
    UILabel *detailLabel = [UILabel labelWithFrame:CGRectMake(0.f, moneyLabel.bottom_mn, self.contentView.width_mn, 25.f) text:nil alignment:NSTextAlignmentCenter textColor:nil font:nil];
    detailLabel.touchInset = UIEdgeInsetWith(-5.f);
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    attachment.bounds = CGRectMake(2.f, -1.f, size.width, size.height);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"已存入零钱, 可直接消费"];
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    string.color = MN_R_G_B(255.f, 226.f, 177.f);
    string.font = font;
    string.alignment = NSTextAlignmentCenter;
    detailLabel.attributedText = string.copy;
    [self.contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    @weakify(self);
    [detailLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        if (self.changeInfoEventHandler) {
            self.changeInfoEventHandler();
        }
    }];
}

#pragma mark - Setter
- (void)setRedpacket:(WXRedpacket *)redpacket {
    
    WXUser *user = [[WechatHelper helper] userForUid:redpacket.from_uid];
    self.headView.image = [user avatar];
    self.fromLabel.text = [user.name stringByAppendingString:@"的红包"];
    [self.fromLabel sizeToFit];
    self.headView.left_mn = MEAN(self.contentView.width_mn - self.headView.width_mn - self.fromLabel.width_mn - 5.f);
    self.fromLabel.left_mn = self.headView.right_mn + 5.f;
    
    self.textLabel.text = redpacket.text;
    
    if (redpacket.isMine) {
        self.moneyLabel.hidden = YES;
        self.detailLabel.hidden = YES;
    } else {
        NSString *string = [redpacket.money stringByAppendingString:@" 元"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        attributedString.font = [UIFont systemFontOfSizes:self.moneyLabel.height_mn weights:.3f];
        [attributedString setFont:[UIFont systemFontOfSizes:14.f weights:.3f] range:[string rangeOfString:@" 元"]];
        attributedString.color = self.fromLabel.textColor;
        attributedString.alignment = NSTextAlignmentCenter;
        self.moneyLabel.attributedText = attributedString.copy;
        
        self.moneyLabel.hidden = NO;
        self.detailLabel.hidden = NO;
    }
}

@end
