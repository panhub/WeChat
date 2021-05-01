//
//  WXShakeViewController.m
//  WeChat
//
//  Created by Vincent on 2020/1/31.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeViewController.h"
#import "WXUserViewController.h"
#import "WXMusicPlayController.h"
#import "WXShakeMatchControl.h"
#import "WXShakeMatchView.h"
#import "WXShakePersonCard.h"
#import "WXShakeHistory.h"
#import "WXSong.h"

typedef NS_ENUM(NSInteger, WXShakeStatus) {
    WXShakeStatusNone = 0,
    WXShakeStatusShaking,
    WXShakeStatusMatching
};

#define WXShakeMatchTag   10

@interface WXShakeViewController ()
@property (nonatomic) WXShakeStatus status;
@property (nonatomic) WXShakeMatchType type;
@property (nonatomic, strong) UIView *shakeUpView;
@property (nonatomic, strong) UIView *shakeDownView;
@property (nonatomic, strong) UIView *shakeUpLineView;
@property (nonatomic, strong) UIView *shakeDownLineView;
@property (nonatomic, strong) UIImageView *shakeHideView;
@property (nonatomic, strong) WXShakeMatchView *matchView;
@property (nonatomic, strong) WXShakePersonCard *personCard;
@property (nonatomic, getter=isAllowsShakeSound) BOOL allowsShakeSound;
@end

@implementation WXShakeViewController
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"摇一摇";
        [MNDatabase createTable:WXShakeHistoryTableName class:WXShakeHistory.class completion:nil];
    }
    return self;
}

- (void)createView {
    [super createView];
    // 创建视图
    self.navigationBar.translucent = NO;
    self.navigationBar.titleColor = UIColor.whiteColor;
    self.navigationBar.backgroundColor = UIColor.clearColor;
    self.navigationBar.shadowView.backgroundColor = UIColor.clearColor;
    
    self.contentView.backgroundColor = UIColorWithSingleRGB(51.f);
    //self.contentView.backgroundImage = [UIImage imageNamed:@"shake_background"];
    //self.contentView.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    __block CGFloat y = 0.f;
    NSArray <NSString *>*titles = @[@"人", @"歌曲", @"电视"];
    NSArray <NSString *>*imgs = @[@"wx_shake_people", @"wx_shake_music", @"wx_shake_tv"];
    CGFloat wh = 38.f;
    CGFloat x = (self.contentView.width_mn - titles.count*wh)/(titles.count + 1);
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXShakeMatchControl *control = [[WXShakeMatchControl alloc] initWithFrame:CGRectMake(x + (x + wh)*idx, 0.f, wh, wh*1.5f)];
        control.bottom_mn = self.contentView.height_mn - MAX(MN_TAB_SAFE_HEIGHT + 5.f, 10.f);
        control.title = obj;
        control.image = [UIImage imageNamed:imgs[idx]];
        control.selectedImage = [UIImage imageNamed:[imgs[idx] stringByAppendingString:@"HL"]];
        control.touchInset = UIEdgeInsetWith(-10.f);
        control.selected = idx == 0;
        control.tag = WXShakeMatchTag + idx;
        [control addTarget:self action:@selector(shakeControlTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:control];
        y = control.top_mn;
    }];
    
    // 上部分
    UIView *shakeUpView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.contentView.width_mn, self.contentView.height_mn/3.f)];
    shakeUpView.backgroundColor = self.contentView.backgroundColor;
    shakeUpView.bottom_mn = (y - self.navigationBar.bottom_mn)/2.f + self.navigationBar.bottom_mn - 15.f;
    [self.contentView insertSubview:shakeUpView atIndex:0];
    self.shakeUpView = shakeUpView;
    
    UIImageView *shakeUpImageView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"shake_logo_up"]];
    shakeUpImageView.size_mn = CGSizeMultiplyToWidth(shakeUpImageView.image.size, shakeUpView.width_mn/3.f*1.13f);
    shakeUpImageView.bottom_mn = shakeUpView.height_mn;
    shakeUpImageView.centerX_mn = shakeUpView.width_mn/2.f;
    [shakeUpView addSubview:shakeUpImageView];
    
    UIView *shakeUpLineView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, shakeUpView.width_mn, 4.f)];
    shakeUpLineView.clipsToBounds = YES;
    shakeUpLineView.hidden = YES;
    shakeUpLineView.backgroundColor = UIColorWithSingleRGB(92.f);
    shakeUpLineView.bottom_mn = shakeUpView.height_mn;
    [shakeUpView addSubview:shakeUpLineView];
    self.shakeUpLineView = shakeUpLineView;
    
    // 下部分
    UIView *shakeDownView = [[UIView alloc] initWithFrame:shakeUpView.frame];
    shakeDownView.backgroundColor = self.contentView.backgroundColor;
    shakeDownView.top_mn = shakeUpView.bottom_mn;
    [self.contentView insertSubview:shakeDownView atIndex:0];
    self.shakeDownView = shakeDownView;
    
    UIImageView *shakeDownImageView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"shake_logo_down"]];
    shakeDownImageView.size_mn = CGSizeMultiplyToWidth(shakeDownImageView.image.size, shakeUpImageView.width_mn);
    shakeDownImageView.centerX_mn = shakeDownView.width_mn/2.f;
    [shakeDownView addSubview:shakeDownImageView];
    
    UIView *shakeDownLineView = shakeUpLineView.viewCopy;
    shakeDownLineView.top_mn = 0.f;
    shakeDownLineView.clipsToBounds = YES;
    shakeDownLineView.hidden = YES;
    [shakeDownView addSubview:shakeDownLineView];
    self.shakeDownLineView = shakeDownLineView;
    
    // 底部鲜花
    UIImageView *shakeHideView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
    [self.contentView insertSubview:shakeHideView atIndex:0];
    self.shakeHideView = shakeHideView;
    
    // 匹配提示
    WXShakeMatchView *matchView = [[WXShakeMatchView alloc] init];
    matchView.top_mn = CGRectGetMaxY([shakeDownImageView.superview convertRect:shakeDownImageView.frame toView:self.contentView]) + 5.f;
    matchView.centerX_mn = self.contentView.width_mn/2.f;
    [self.contentView addSubview:matchView];
    self.matchView = matchView;
    
    // 卡片
    WXShakePersonCard *personCard = WXShakePersonCard.new;
    personCard.bottom_mn = shakeUpView.bottom_mn;
    personCard.centerX_mn = self.contentView.width_mn/2.f;
    personCard.hidden = YES;
    [personCard addTarget:self action:@selector(personCardTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView insertSubview:personCard belowSubview:shakeUpView];
    self.personCard = personCard;
}

- (void)updateShakeSeting {
    self.allowsShakeSound = WXPreference.preference.isAllowsShakeSound;
    self.shakeHideView.image = WXPreference.preference.shakeBackgroundImage;
    self.shakeHideView.size_mn = CGSizeMultiplyToWidth(self.shakeHideView.image.size, self.contentView.width_mn/4.f*3.f);
    self.shakeHideView.centerY_mn = self.shakeUpView.bottom_mn;
    self.shakeHideView.centerX_mn = self.contentView.width_mn/2.f;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication.sharedApplication setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    [self updateShakeSeting];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resignFirstResponder];
}

#pragma mark - Event
- (void)shakeControlTouchUpInside:(WXShakeMatchControl *)sender {
    if (sender.selected || self.status != WXShakeStatusNone) return;
    NSArray <UIView *>*views = [self.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag >= %@", @(WXShakeMatchTag)]];
    [views setValue:@NO forKey:kPath(sender.selected)];
    sender.selected = YES;
    self.type = sender.tag - WXShakeMatchTag;
}

- (void)beganShakeMotionAnimation {
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(beganShakeMatch) object:nil];
    [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(showShakeMatchResult) object:nil];
    [self.matchView stopAnimating];
    [self.personCard stopAnimating];
    self.status = WXShakeStatusShaking;
    self.shakeUpLineView.hidden = self.shakeDownLineView.hidden = NO;
    if (self.isAllowsShakeSound) {
        [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"shake_sound_male" ofType:@"caf" inDirectory:@"sound"] shake:NO];
    }
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shakeUpView.bottom_mn = self.shakeHideView.top_mn;
        self.shakeDownView.top_mn = self.shakeHideView.bottom_mn;
    } completion:^(BOOL finished) {
        dispatch_after_main(.4f, ^{
            [self endShakeMotionAnimation];
        });
    }];
}

- (void)endShakeMotionAnimation {
    [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.shakeUpView.bottom_mn = self.shakeHideView.centerY_mn;
        self.shakeDownView.top_mn = self.shakeUpView.bottom_mn;
    } completion:^(BOOL finished) {
        self.status = WXShakeStatusMatching;
        self.shakeUpLineView.hidden = self.shakeDownLineView.hidden = YES;
        [self performSelector:@selector(beganShakeMatch) withObject:nil afterDelay:.5f];
    }];
}

- (void)beganShakeMatch {
    self.matchView.type = self.type;
    [self.matchView startAnimating];
    [self performSelector:@selector(showShakeMatchResult) withObject:nil afterDelay:1.5f];
}

- (void)showShakeMatchResult {
    [self.matchView stopAnimating];
    self.status = WXShakeStatusNone;
    if (self.isAllowsShakeSound) {
        [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:@"shake_match" ofType:@"caf" inDirectory:@"sound"] shake:NO];
    }
    if (self.type == WXShakeMatchPerson) {
        // 匹配人
        self.personCard.user = WechatHelper.user;
        self.personCard.bottom_mn = self.shakeUpView.bottom_mn;
        self.personCard.hidden = NO;
        [UIView animateWithDuration:.6f animations:^{
            self.personCard.top_mn = self.matchView.top_mn;
        } completion:^(BOOL finished) {
            // 插入搜索历史
            WXShakeHistory *history = [[WXShakeHistory alloc] initWithUser:self.personCard.user];
            history.subtitle = self.personCard.distance;
            [MNDatabase insertToTable:WXShakeHistoryTableName model:history completion:nil];
        }];
    } else if (self.type == WXShakeMatchMusic) {
        // 匹配音乐
        WXSong *song = WXSong.fetchRandomSong;
        WXShakeHistory *history = [[WXShakeHistory alloc] initWithSong:song];
        [MNDatabase insertToTable:WXShakeHistoryTableName model:history completion:nil];
        @weakify(self);
        dispatch_after_main(.3f, ^{
            @strongify(self);
            WXMusicPlayController *vc = [[WXMusicPlayController alloc] initWithSongs:@[song]];
            [self.navigationController pushViewController:vc animated:YES];
        });
    } else {
        // 匹配电视节目
        WXShakeHistory *history = WXShakeHistory.fetchTVHistory;
        [MNDatabase insertToTable:WXShakeHistoryTableName model:history completion:nil];
        @weakify(self);
        dispatch_after_main(.3f, ^{
            @strongify(self);
            UIViewControllerPush(@"WXShakeTVController", YES);
        });
    }
}

- (void)personCardTouchUpInside:(WXShakePersonCard *)personCard {
    WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:personCard.user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - ShakeToEdit 摇动手机之后的回调方法
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion != UIEventSubtypeMotionShake || self.status == WXShakeStatusShaking) return;
    [self beganShakeMotionAnimation];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion != UIEventSubtypeMotionShake) return;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion != UIEventSubtypeMotionShake) return;
}

#pragma mark - Overwrite
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)navigationBarShouldDrawBackBarItem {
    return NO;
}

- (UIView *)navigationBarShouldCreateLeftBarItem {
    UIImage *image = UIImageNamed(@"wx_common_back_white");
    CGSize leftItemSize = CGSizeMultiplyToWidth(image.size, kNavItemSize);
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItem.frame = (CGRect){CGPointZero, leftItemSize};
    leftItem.touchInset = UIEdgeInsetWith(-10.f);
    [leftItem setBackgroundImage:image forState:UIControlStateNormal];
    [leftItem addTarget:self action:@selector(navigationBarLeftBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return leftItem;
}

- (UIView *)navigationBarShouldCreateRightBarItem {
    UIImage *image = UIImageNamed(@"wx_common_seting");
    CGSize rightItemSize = CGSizeMultiplyToWidth(image.size, 23.f);
    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.frame = (CGRect){CGPointZero, rightItemSize};
    rightItem.touchInset = UIEdgeInsetWith(-10.f);
    [rightItem setBackgroundImage:image forState:UIControlStateNormal];
    [rightItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    UIViewControllerPush(@"WXShakeSetingController", YES);
}

- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
