//
//  WXRedpacketAlertView.m
//  WeChat
//
//  Created by Vincent on 2019/5/27.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXRedpacketAlertView.h"

@interface WXRedpacketAlertView ()
@property (nonatomic, strong) UIView *blurEffect;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *closeView;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UIImageView *openView;
@property (nonatomic, strong) UILabel *fromLabel;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, copy) WXRedpacketAlertHandler openHandler;
@property (nonatomic, copy) WXRedpacketAlertHandler detailHandler;
@end

@implementation WXRedpacketAlertView
- (instancetype)initWithOpenHandler:(WXRedpacketAlertHandler)openHandler
                      detailHandler:(WXRedpacketAlertHandler)detailHandler
{
    if (self = [super init]) {
        self.openHandler = openHandler;
        self.detailHandler = detailHandler;
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    /// 背景模糊
    UIVisualEffectView *blurEffect = UIBlurEffectCreate(self.bounds, UIBlurEffectStyleExtraLight);
    [self addSubview:blurEffect];
    self.blurEffect = blurEffect;
    
    UIImage *image = [UIImage imageNamed:@"wx_redpacket_bg"];
    CGSize size = CGSizeMultiplyToWidth(image.size, self.width_mn - 90.f);
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(45.f, 0.f, size.width, size.height)];
    contentView.centerY_mn = self.height_mn/2.f - 20.f;
    contentView.backgroundColor = MN_R_G_B(224.f, 84.f, 73.f);
    contentView.layer.cornerRadius = 7.f;
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    self.contentView = contentView;
    
    /*
    /// 底部图案
    UIImageView *patternView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(contentView.width_mn - 20.f), contentView.height_mn - 30.f, 20.f, 20.f) image:[UIImage imageNamed:@"wx_redpacket_pattern"]];
    [contentView addSubview:patternView];
    */
     
    /// 封口
    image = [UIImage imageNamed:@"wx_redpacket_seal"];
    size = CGSizeMultiplyToWidth(image.size, contentView.width_mn);
    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:image];
    imageView.bottom_mn = 1280.f/1587.f*contentView.height_mn;
    [contentView addSubview:imageView];
    
    /// 开
    UIImageView *openView = [UIImageView imageViewWithFrame:CGRectMake(contentView.width_mn/3.f, 0.f, contentView.width_mn/3.f, contentView.width_mn/3.f) image:[UIImage imageNamed:@"wx_redpacket_open"]];
    openView.centerY_mn = imageView.bottom_mn - 20.f/150.f*imageView.height_mn;
    [contentView addSubview:openView];
    self.openView = openView;
    
    /// 头像
    UIImageView *headView = [UIImageView imageViewWithFrame:CGRectMake(0.f, openView.top_mn/3.f, 25.f, 25.f) image:nil];
    headView.layer.cornerRadius = 4.f;
    headView.clipsToBounds = YES;
    [contentView addSubview:headView];
    self.headView = headView;
    
    /// 红包来源
    UILabel *fromLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, 0.f, headView.height_mn) text:nil textColor:MN_R_G_B(254.f, 225.f, 177.f) font:[UIFont systemFontOfSizes:headView.height_mn - 6.f weights:.5f]];
    fromLabel.centerY_mn = headView.centerY_mn;
    fromLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:fromLabel];
    self.fromLabel = fromLabel;
    
    /// 文字/金额
    UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(15.f, headView.bottom_mn + 20.f, contentView.width_mn - 30.f, 24.f) text:nil alignment:NSTextAlignmentCenter textColor:fromLabel.textColor font:[UIFont systemFontOfSize:24.f]];
    [contentView addSubview:textLabel];
    self.textLabel = textLabel;
    
    /// 领取详情
    UIFont *font = [UIFont systemFontOfSize:15.f];
    image = UIImageNamed(@"wx_redpacket_arrow");
    size = CGSizeMultiplyToHeight(image.size, font.pointSize - 3.f);
    UILabel *detailLabel = [UILabel labelWithFrame:CGRectMake(0.f, contentView.height_mn - 55.f, contentView.width_mn, 50.f) text:nil alignment:NSTextAlignmentCenter textColor:nil font:nil];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageWithCGImage:image.CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    attachment.bounds = CGRectMake(2.f, -1.f, size.width, size.height);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"查看领取详情"];
    [string appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    string.color = MN_R_G_B(255.f, 226.f, 177.f);
    string.font = font;
    string.alignment = NSTextAlignmentCenter;
    detailLabel.attributedText = string.copy;
    [contentView addSubview:detailLabel];
    self.detailLabel = detailLabel;
    
    /// 关闭
    UIImageView *closeView = [UIImageView imageViewWithFrame:CGRectMake(MEAN(self.width_mn - 47.f), 0.f, 47.f, 47.f) image:[UIImage imageNamed:@"wx_redpacket_close"]];
    closeView.centerY_mn = contentView.bottom_mn + (self.height_mn - contentView.bottom_mn)/2.f;
    [self addSubview:closeView];
    self.closeView = closeView;
    
    self.blurEffect.alpha = 0.f;
    self.closeView.alpha = 0.f;
    self.contentView.alpha = 0.f;
    self.contentView.transform = CGAffineTransformMakeScale(.15f, .15f);
}

- (void)handEvents {
    @weakify(self);
    [self handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        [self dismiss];
    }];
    
    [self.openView handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        [self openRedpacketEvent];
    }];
    
    [self.detailLabel handTapConfiguration:nil eventHandler:^(id sender) {
        @strongify(self);
        [self removeFromSuperview];
        if (self.detailHandler) {
            self.detailHandler();
        }
    }];
}

- (void)openRedpacketEvent {
    self.openView.image = [UIImage imageNamed:@"wx_redpacket_open_ani_0"];
    NSArray <UIImage *>*anis = @[UIImageNamed(@"wx_redpacket_open_ani_0"),
                                 UIImageNamed(@"wx_redpacket_open_ani_1"),
                                 UIImageNamed(@"wx_redpacket_open_ani_2"), UIImageNamed(@"wx_redpacket_open_ani_3"), UIImageNamed(@"wx_redpacket_open_ani_4"), UIImageNamed(@"wx_redpacket_open_ani_5")];
    [self.openView startAnimationWithImages:anis duration:.8f repeat:3 completion:^{
        [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"received_cash" ofType:@"caf" inDirectory:@"sound"] shake:NO];
        [self removeFromSuperview];
        if (self.openHandler) {
            self.openHandler();
        }
    }];
}

- (void)setRedpacket:(WXRedpacket *)redpacket {
    _redpacket = redpacket;
    WXUser *user = [[WechatHelper helper] userForUid:redpacket.from_uid];
    self.headView.image = [user avatar];
    self.fromLabel.text = [user.name stringByAppendingString:@"的红包"];
    [self.fromLabel sizeToFit];
    self.headView.left_mn = MEAN(self.width_mn - 80.f - self.headView.width_mn - self.fromLabel.width_mn - 5.f);
    self.fromLabel.left_mn = self.headView.right_mn + 5.f;
    if (redpacket.isOpen) {
        self.detailLabel.hidden = NO;
        self.openView.hidden = YES;
        self.textLabel.width_mn = self.width_mn - 100.f;
        self.textLabel.height_mn = 50.f;
        NSString *string = [redpacket.money stringByAppendingString:@" 元"];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        attributedString.font = [UIFont systemFontOfSize:self.textLabel.height_mn];
        [attributedString setFont:[UIFont systemFontOfSizes:14.f weights:.4f] range:[string rangeOfString:@" 元"]];
        attributedString.color = self.textLabel.textColor;
        attributedString.alignment = NSTextAlignmentCenter;
        self.textLabel.attributedText = attributedString.copy;
    } else {
        self.detailLabel.hidden = YES;
        self.openView.hidden = NO;
        self.textLabel.text = redpacket.text;
        [self.textLabel sizeToFit];
    }
    self.textLabel.centerX_mn = MEAN(self.width_mn - 80.f);
}

- (void)show {
    if (self.superview || self.blurEffect.alpha > 0.f) return;
    [[UIWindow mainWindow] endEditing:YES];
    [[UIWindow mainWindow] addSubview:self];
    [UIView animateWithDuration:.2f animations:^{
        self.contentView.alpha = 1.f;
    }];
    [UIView animateWithDuration:.4f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.blurEffect.alpha = .7f;
        self.closeView.alpha = 1.f;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismiss {
    if (!self.superview || self.blurEffect.alpha <= 0.f) return;
    [UIView animateWithDuration:.3f animations:^{
        self.blurEffect.alpha = 0.f;
        self.closeView.alpha = 0.f;
        self.contentView.transform = CGAffineTransformMakeScale(.1f, .1f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setFrame:(CGRect)frame {
    frame = [[UIScreen mainScreen] bounds];
    [super setFrame:frame];
}

@end
