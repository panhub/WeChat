//
//  WXChatViewController.m
//  MNChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatViewController.h"
#import "WXChatSetingController.h"
#import "WXUserInfoViewController.h"
#import "WXChatLocationController.h"
#import "WXCollectViewController.h"
#import "WXMapViewController.h"
#import "WXTextMessageController.h"
#import "WXRedpacketViewController.h"
#import "WXRedpacketInfoController.h"
#import "WXTransferViewController.h"
#import "WXTransferDrawController.h"
#import "WXTransferDoneController.h"
#import "WXContactsSelectController.h"
#import "WXVoiceCallController.h"
#import "WXVideoCallController.h"
#import "WXSession.h"
#import "WXMessage.h"
#import "WXFileModel.h"
#import "WXMessageCell.h"
#import "WXChatInputView.h"
#import "WXSendCardAlertView.h"
#import "WXRedpacketAlertView.h"
#import "WXVoiceMessageViewModel.h"

typedef NS_ENUM(NSInteger, WXChatUserType) {
    WXChatUserMine = 0,
    WXChatUserOther
};

@interface WXChatViewController () <WXChatInputDelegate, UIScrollViewDelegate>
@property (nonatomic) WXChatUserType chatType;
@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, strong) WXChatInputView *chatInputView;
@property (nonatomic, strong) WXChatViewModel *viewModel;
@end

@implementation WXChatViewController
- (instancetype)initWithSession:(WXSession *)session {
    if (!session) return nil;
    if (self = [super init]) {
        self.pullRefreshEnabled = YES;
        self.title = session.user.notename.length > 0 ? session.user.notename : session.user.nickname;
        self.viewModel = [[WXChatViewModel alloc] initWithSession:session];
        [self handEvents];
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.backgroundColor = VIEW_COLOR;
    self.navigationBar.shadowColor = UIColorWithAlpha([UIColor darkTextColor], .1f);
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
    
    WXChatInputView *chatInputView = [[WXChatInputView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.width_mn, 0.f)];
    chatInputView.top_mn = self.view.height_mn - chatInputView.height_mn;
    chatInputView.delegate = self;
    
    self.tableView.frame = UIEdgeInsetsInsetRect(self.contentView.bounds, UIEdgeInsetsMake(0.f, 0.f, chatInputView.height_mn, 0.f));
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = VIEW_COLOR;
    self.tableView.showsVerticalScrollIndicator = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    
    [self.view addSubview:chatInputView];
    self.chatInputView = chatInputView;
    
    /// 浮窗图片
    UIView *darkView = UIBlurEffectCreate(self.dragView.bounds, UIBlurEffectStyleDark);
    darkView.userInteractionEnabled = NO;
    [self.dragView insertSubview:darkView atIndex:0];
    self.dragView.contentView.size_mn = CGSizeMake(50.f, 50.f);
    self.dragView.contentView.layer.cornerRadius = 25.f;
    self.dragView.contentView.center_mn = self.dragView.bounds_center;
    self.dragView.contentView.image = self.viewModel.session.user.avatar;
    self.dragView.layer.cornerRadius = 12.f;
    
    /// 设置背景图
    UIImage *backgroundImage = nil;
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:WXChatBackgroundKey];
    if ([obj isKindOfClass:NSString.class]) {
        NSString *img = (NSString *)obj;
        if (img.length) backgroundImage = [UIImage imageNamed:img];
    } else if ([obj isKindOfClass:NSData.class]) {
        backgroundImage = [UIImage imageWithData:obj];
    }
    if (backgroundImage) {
        self.view.backgroundImage = backgroundImage;
        self.view.clipsToBounds = YES;
        self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
        self.navigationBar.translucent = YES;
        self.navigationBar.backgroundColor = [UIColor clearColor];
        self.navigationBar.shadowView.hidden = YES;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - Hand Events
- (void)handEvents {
    @weakify(self);
    /// 刷新数据
    [self handNotification:WXChatListReloadNotificationName eventHandler:^(NSNotification *notification) {
        @strongify(self);
        if (notification.object && self.viewModel.session == notification.object) {
            // 有可能刚进入前台触发通知, 这里就不判断是否出现, 直接重载数据
            [self.viewModel.dataSource removeAllObjects];
            [self reloadData];
        }
    }];
    
    /// 刷新列表
    self.viewModel.reloadTableHandler = ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        }];
    };
    
    /// 刷新行
    self.viewModel.reloadRowHandler = ^(NSInteger row) {
        [UIView performWithoutAnimation:^{
            @strongify(self);
            [self.tableView reloadRow:row inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }];
    };
    
    /// 滚动指定行到指定位置
    self.viewModel.scrollRowToBottomHandler = ^(NSUInteger row, BOOL animated) {
        @strongify(self);
        [self.tableView scrollToRow:row inSection:0 atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    };
    
    /// 已插入视图模型
    self.viewModel.didInsertViewModelHandler = ^(NSArray <WXMessageViewModel *>*viewModels) {
        @strongify(self);
        CGPoint contentOffset = self.tableView.contentOffset;
        UIView *snapshotView = [self.tableView snapshotView];
        [self.tableView.superview addSubview:self.snapshotView = snapshotView];
        if (self.chatInputView.bottom_mn < self.chatInputView.superview.height_mn) {
            [self.tableView reloadData];
            [self.tableView setNeedsLayout];
            [self.tableView layoutIfNeeded];
            dispatch_after_main(.15f, ^{
                [self.tableView setContentOffset:contentOffset animated:NO];
            });
        } else {
            NSMutableArray <NSIndexPath *>*indexPaths = @[].mutableCopy;
            [viewModels enumerateObjectsUsingBlock:^(WXMessageViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[self.viewModel.dataSource indexOfObject:obj] inSection:0]];
            }];
            [self.tableView insertRowsAtIndexPaths:indexPaths.copy withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView layoutIfNeeded];
            [self.tableView setContentOffset:contentOffset animated:NO];
        }
    };
    
    /// 已发送消息
    self.viewModel.didSendViewModelHandler = ^(NSArray <WXMessageViewModel *>*viewModels) {
        @strongify(self);
        if (self.snapshotView) [self.snapshotView removeFromSuperview];
        [self scrollRowToVisibleOfIndex:[self.viewModel.dataSource indexOfObject:viewModels.lastObject] animated:self.isAppear];
        if (viewModels.firstObject.isAllowsPlaySound && self.isAppear) {
            [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:(viewModels.firstObject.message.isMine ? @"send_msg" : @"received_msg") ofType:@"caf" inDirectory:@"sound"] shake:NO];
        }
        [MNDatabase updateTable:WXSessionTableName
                          where:@{@"identifier":self.viewModel.session.identifier}.componentString
                          model:self.viewModel.session
                     completion:nil];
    };
    
    /// 加载结束事件
    self.viewModel.didLoadFinishHandler = ^(BOOL removed) {
        @strongify(self);
        [self endPullRefresh];
        dispatch_after_main(.5f, ^{
            if (removed) [self removeRefreshHeader];
        });
    };
    
    /// 头像点击事件
    self.viewModel.headButtonClickedHandler = ^(WXMessageViewModel *viewModel) {
        @strongify(self);
        if (!viewModel) return;
        WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:viewModel.message.user];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    /// 消息点击事件
    self.viewModel.imageViewClickedHandler = ^(WXMessageViewModel *viewModel) {
        @strongify(self);
        if (self.chatInputView.isFirstResponder) {
            [self.chatInputView resignFirstResponder];
            return;
        }
        id extend = viewModel.imageViewModel.extend;
        if (!extend) return;
        if (viewModel.message.type == WXTextMessage) {
            /// 文字消息
            WXTextMessageController *vc = [[WXTextMessageController alloc] initWithAttributedMessage:extend];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXImageMessage) {
            /// 图片消息
            [self.viewModel pauseVoicePlay];
            UIImage *image = (UIImage *)extend;
            if (!viewModel.imageViewModel.obj || !image) return;
            MNAsset *asset = [MNAsset assetWithContent:image];
            asset.containerView = viewModel.imageViewModel.obj;
            MNAssetBrowser *browser = [MNAssetBrowser new];
            browser.allowsSelect = NO;
            browser.assets = @[asset];
            browser.backgroundColor = UIColor.blackColor;
            [browser presentFromAsset:asset animated:YES];
        } else if (viewModel.message.type == WXVideoMessage) {
            /// 视频消息
            WXFileModel *fileModel = (WXFileModel *)extend;
            if (fileModel.filePath.length <= 0 || !viewModel.imageViewModel.obj) return;
            MNAsset *asset = [MNAsset assetWithContent:fileModel.filePath];
            asset.containerView = viewModel.imageViewModel.obj;
            MNAssetBrowser *browser = [MNAssetBrowser new];
            browser.allowsSelect = NO;
            browser.assets = @[asset];
            browser.allowsAutoPlaying = YES;
            browser.backgroundColor = UIColor.blackColor;
            [browser presentFromAsset:asset animated:YES];
        } else if (viewModel.message.type == WXVoiceMessage) {
            /// 语音消息
            [self.viewModel updateViewModel:viewModel];
        } else if (viewModel.message.type == WXVoiceCallMessage || viewModel.message.type == WXVideoCallMessage) {
            /// 语音/视频通话
            if (viewModel.message.type == WXVoiceCallMessage) {
                [self startVoiceCalling:YES];
            } else {
                [self startVideoCalling:YES];
            }
        } else if (viewModel.message.type == WXLocationMessage) {
            /// 位置消息
            WXMapLocation *point = extend;
            WXMapViewController *vc = [[WXMapViewController alloc] initWithPoint:point];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXCardMessage) {
            /// 名片消息
            WXUserInfoViewController *vc = [[WXUserInfoViewController alloc] initWithUser:extend];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXWebpageMessage) {
            /// 网页消息
            WXWebpage *page = extend;
            MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:page.url];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXRedpacketMessage) {
            /// 红包消息
            WXRedpacket *redpacket = (WXRedpacket *)extend;
            if (redpacket.isMine) {
                [self.view showWeChatDialogDelay:.5f completionHandler:^{
                    if (redpacket.isOpen) {
                        /// 领取详情
                        WXRedpacketInfoController *vc = [[WXRedpacketInfoController alloc] initWithRedpacket:redpacket];
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        /// 领取
                        [self.viewModel updateViewModel:viewModel];
                    }
                }];
            } else {
                /// 红包弹窗
                [self.view showWeChatDialog:!redpacket.isOpen delay:.5f completionHandler:^{
                    WXRedpacketAlertView *alertView = [[WXRedpacketAlertView alloc] initWithOpenHandler:^{
                        /// 更新状态
                        [self.viewModel updateViewModel:viewModel];
                    } detailHandler:^{
                        /// 领取详情
                        [self.view showWeChatDialogDelay:.5f completionHandler:^{
                            WXRedpacketInfoController *vc = [[WXRedpacketInfoController alloc] initWithRedpacket:redpacket];
                            [self.navigationController pushViewController:vc animated:YES];
                        }];
                    }];
                    alertView.redpacket = redpacket;
                    [alertView show];
                }];
            }
        } else if (viewModel.message.type == WXTransferMessage) {
            /// 转账
            WXRedpacket *redpacket = (WXRedpacket *)extend;
            if (redpacket.isOpen) {
                /// 领取详情
                WXTransferDoneController *vc = [[WXTransferDoneController alloc] initWithRedpacket:redpacket];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                /// 区别发送人
                if (redpacket.isMine) {
                    /// 更新状态
                    [self.view showWeChatDialogDelay:.5f completionHandler:^{
                        [self.viewModel updateViewModel:viewModel];
                    }];
                } else {
                    /// 领取
                    WXTransferDrawController *vc = [[WXTransferDrawController alloc]initWithRedpacket:redpacket];
                    @weakify(self);
                    vc.completionHandler = ^{
                        @strongify(self);
                        /// 更新状态
                        [self.viewModel updateViewModel:viewModel];
                    };
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    };
}

- (void)reloadData {
    [self loadData];
}

- (void)loadData {
    [self.viewModel loadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    @weakify(self);
    /// 清空聊天记录
    [self handNotification:WXChatTableDeleteNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![kTransform(WXSession *, notify.object).identifier isEqualToString:self.viewModel.session.identifier] || self.viewModel.dataSource.count <= 0) return;
        [self.viewModel.dataSource removeAllObjects];
        @condition(self.isAppear, [self reloadList], [self setNeedsReloadList]);
        [MNDatabase deleteRowFromTable:self.viewModel.session.list where:nil completion:nil];
    }];
    /// 用户资料编辑
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![kTransform(WXUser *, notify.object).uid isEqualToString:self.viewModel.session.user.uid]) return;
        self.title = self.viewModel.session.user.name;
        [self loadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.chatInputView.userInteractionEnabled = YES;
    [AppDelegate makeDebugVisible:NO];
    if (self.isFirstAppear) [self.view bringSubviewToFront:self.dragView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [AppDelegate makeDebugVisible:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.chatInputView.userInteractionEnabled = NO;
    if (self.isAppear) {
        /// 请求访问麦克风/摄像头权限
        [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:nil];
        [MNAuthenticator requestCameraAuthorizationStatusWithHandler:nil];
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.viewModel.dataSource.count) return 0.001f;
    WXMessageViewModel *viewModel = self.viewModel.dataSource[indexPath.row];
    return viewModel.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.viewModel.dataSource.count) return nil;
    WXMessageViewModel *viewModel = self.viewModel.dataSource[indexPath.row];
    WXMessageCell *cell = [WXMessageCell dequeueReusableCellWithTableView:tableView model:viewModel];
    cell.viewModel = viewModel;
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.isDragging) [self.chatInputView resignFirstResponder];
}

#pragma mark - WXChatInputDelegate
- (void)inputViewDidChangeFrame:(WXChatInputView *)inputView animated:(BOOL)animated {
    if (self.dragView.bottom_mn > (inputView.top_mn - 15.f)) {
        [UIView animateWithDuration:(animated ? .3f : 0.f) animations:^{
            self.dragView.bottom_mn = inputView.top_mn - 15.f;
        }];
    }
    if (self.tableView.isDragging || self.viewModel.dataSource.count <= 0) return;
    [self scrollRowToVisibleOfIndex:(self.viewModel.dataSource.count - 1) animated:animated];
}

- (void)inputViewShouldSendText:(NSString *)text {
    if (![self.viewModel sendTextMsg:text isMine:self.chatType == WXChatUserMine]) {
        [self.view showInfoDialog:@"消息发送失败"];
    }
}

- (void)inputViewShouldSendEmotion:(UIImage *)image {
    if (![self.viewModel sendEmotionMsg:image isMine:self.chatType == WXChatUserMine]) {
        [self.view showInfoDialog:@"表情发送失败"];
    }
}

- (void)inputViewShouldSendAsset:(WXChatInputView *)inputView {
    @weakify(self);
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = YES;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.requestGifUseingPhotoPolicy = YES;
    picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    picker.configuration.allowsEditing = NO;
    picker.configuration.allowsCapturing = NO;
    picker.configuration.maxPickingCount = 1;
    picker.configuration.exportPixel = 1000.f;
    [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
        if (assets.count <= 0 || !assets.firstObject.content) return;
        @strongify(self);
        MNAsset *asset = assets.firstObject;
        if (asset.type == MNAssetTypeVideo) {
            @weakify(self);
            [self.view showProgressDialog:@"视频导出中"];
            [MNAssetHelper exportVideoWithAsset:assets.firstObject outputPath:nil presetName:AVAssetExportPresetHighestQuality progressHandler:^(float progress){
                dispatch_async_main(^{
                    @strongify(self);
                    [self.view updateDialogProgress:progress];
                });
            } completionHandler:^(NSString *filePath) {
                @strongify(self);
                if (filePath) {
                    [self.view closeDialog];
                    if (![self.viewModel sendVideoMsg:filePath isMine:self.chatType == WXChatUserMine]) {
                        [self.view showInfoDialog:@"视频发送失败"];
                    }
                } else {
                    [self.view showInfoDialog:@"视频导出失败"];
                }
            }];
        } else {
            if (![self.viewModel sendImageMsg:asset.content isMine:self.chatType == WXChatUserMine]) {
                [self.view showInfoDialog:@"图片发送失败"];
            }
        }
    } cancelHandler:nil];
}

- (void)inputViewShouldSendCapture:(WXChatInputView *)inputView {
    @weakify(self);
    MNAssetPicker *picker = [MNAssetPicker capturer];
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = YES;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.maxCaptureDuration = 60.f;
    picker.configuration.allowsCapturing = YES;
    picker.configuration.allowsEditing = NO;
    picker.configuration.exportPixel = 1000.f;
    [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
        if (assets.count <= 0 || !assets.firstObject.content) return;
        @strongify(self);
        MNAsset *asset = assets.firstObject;
        if (asset.type == MNAssetTypeVideo) {
            @weakify(self);
            [self.view showProgressDialog:@"视频导出中"];
            [MNAssetHelper exportVideoWithAsset:assets.firstObject outputPath:nil presetName:AVAssetExportPresetHighestQuality progressHandler:^(float progress){
                dispatch_async_main(^{
                    @strongify(self);
                    [self.view updateDialogProgress:progress];
                });
            } completionHandler:^(NSString *filePath) {
                @strongify(self);
                if (filePath) {
                    [self.view closeDialog];
                    if (![self.viewModel sendVideoMsg:filePath isMine:self.chatType == WXChatUserMine]) {
                        [self.view showInfoDialog:@"视频发送失败"];
                    }
                } else {
                    [self.view showInfoDialog:@"视频导出失败"];
                }
            }];
        } else {
            if (![self.viewModel sendImageMsg:asset.content isMine:self.chatType == WXChatUserMine]) {
                [self.view showInfoDialog:@"图片发送失败"];
            }
        }
    } cancelHandler:nil];
}

- (void)inputViewShouldSendCard:(WXChatInputView *)inputView {
    @weakify(self);
    WXUser *toUser = self.viewModel.session.user;
    WXContactsSelectController *viewController = WXContactsSelectController.new;
    viewController.expelUsers = @[toUser];
    viewController.selectedHandler = ^(UIViewController *vc, NSArray <WXUser *>*users) {
        WXSendCardAlertView *alertView = WXSendCardAlertView.new;
        alertView.user = users.firstObject;
        alertView.toUser = toUser;
        @weakify(vc);
        // 用户信息查看
        alertView.userClickHandler = ^(WXSendCardAlertView *aView) {
            @strongify(vc);
            WXUserInfoViewController *infoController = [[WXUserInfoViewController alloc] initWithUser:aView.toUser];
            [vc.navigationController pushViewController:infoController animated:YES];
        };
        // 确定发送
        [alertView showInView:vc.view completionHandler:^(WXSendCardAlertView *aView) {
            @strongify(vc);
            [vc.navigationController popViewControllerAnimated:YES];
            WXUser *cUser = aView.user;
            NSString *mText = alertView.text;
            dispatch_after_main(.5f, ^{
                @strongify(self);
                if (![self.viewModel sendCardMsg:cUser text:mText isMine:self.chatType == WXChatUserMine]) {
                    [self.view showInfoDialog:@"推荐联系人失败"];
                }
            });
        }];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)inputViewShouldSendCall:(WXChatInputView *)inputView {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:@"选择通话类型" cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        @strongify(self);
        if (buttonIndex == 0) {
            [self startVoiceCalling:self.chatType == WXChatUserMine];
        } else {
            [self startVideoCalling:self.chatType == WXChatUserMine];
        }
    } otherButtonTitles:@"语音通话", @"视频通话", nil] show];
}

- (void)inputViewShouldSendLocation:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatUserMine;
    WXChatLocationController *vc = [WXChatLocationController new];
    @weakify(self);
    vc.didSelectHandler = ^(WXMapLocation *location) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_after_main(.5f, ^{
            if (![self.viewModel sendLocationMsg:location isMine:isMine]) {
                [self.view showInfoDialog:@"位置发送失败"];
            }
        });
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendWebpage:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatUserMine;
    WXCollectViewController *vc = [WXCollectViewController new];
    vc.type = WXCollectControllerChat;
    @weakify(self);
    vc.selectedHandler = ^(WXWebpage *page) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_after_main(.5f, ^{
            if (![self.viewModel sendWebpage:page isMine:isMine]) {
                [self.view showInfoDialog:@"网页发送失败"];
            }
        });
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendRedpacket:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatUserMine;
    WXRedpacketViewController *vc = [WXRedpacketViewController new];
    vc.mine = isMine;
    @weakify(self);
    vc.completionHandler = ^(NSString *money, NSString *text) {
        @strongify(self);
        if (![self.viewModel sendRedpacketMsg:text money:money isMine:isMine]) {
            [self.view showInfoDialog:@"红包发送失败"];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendTransfer:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatUserMine;
    WXUser *user = isMine ? self.viewModel.session.user : [WXUser shareInfo];
    WXTransferViewController *vc = [[WXTransferViewController alloc] initWithUser:user];
    @weakify(self);
    vc.completionHandler = ^(NSString *money, NSString *text) {
        @strongify(self);
        if (![self.viewModel sendTransferMsg:text money:money time:[NSDate timestamps] isMine:isMine isUpdate:NO]) {
            [self.view showInfoDialog:@"转账失败"];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendVoice:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatUserMine;
    [self.viewModel sendVoiceMsg:nil isMine:isMine];
}

- (void)inputViewDidCancelVoice:(WXChatInputView *)inputView {
    dispatch_after_main(.3f, ^{
        [self.viewModel cancelVoiceMsg];
    });
}

- (void)inputViewDidSendVoice:(NSString *)voicePath {
    BOOL isMine = self.chatType == WXChatUserMine;
    [self.viewModel sendVoiceMsg:voicePath isMine:isMine];
}

- (void)inputViewShouldInsertEmojiToFavorites:(WXChatInputView *)inputView {
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = NO;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.requestGifUseingPhotoPolicy = YES;
    picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    picker.configuration.allowsEditing = YES;
    picker.configuration.allowsCapturing = YES;
    picker.configuration.cropScale = 1.f;
    picker.configuration.exportPixel = 300.f;
    [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
        if (assets.count <= 0) return;
        [inputView insertEmojiToFavorites:assets.firstObject.content];
    } cancelHandler:nil];
}

- (void)inputViewShouldAddEmojiPackets:(WXChatInputView *)inputView {
    UIViewControllerPush(@"WXEmoticonViewController", YES);
}

#pragma mark - Call
- (void)startVoiceCalling:(BOOL)isMine {
    WXVoiceCallController *viewController = [[WXVoiceCallController alloc] initWithUser:self.viewModel.session.user style:(isMine ? WXVoiceCallSend : WXVoiceCallReceive)];
    viewController.didEndCallHandler = ^(WXVoiceCallController *vc) {
        [self.viewModel sendCallMsg:vc.desc isVideo:NO isMine:isMine];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)startVideoCalling:(BOOL)isMine {
    WXVideoCallController *viewController = [[WXVideoCallController alloc] initWithUser:self.viewModel.session.user style:(isMine ? WXVideoCallSend : WXVideoCallReceive)];
    viewController.didEndCallHandler = ^(WXVideoCallController *vc) {
        [self.viewModel sendCallMsg:vc.desc isVideo:YES isMine:isMine];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - MNDragViewDelegate
- (void)dragViewDidClicking:(MNDragView *)slideView {
    self.chatType = 1 - self.chatType;
    UIImage *image = self.chatType == WXChatUserMine ? self.viewModel.session.user.avatar : [[WXUser shareInfo] avatar];
    CATransitionSubtype subtype = self.chatType == WXChatUserMine ? kCATransitionFromBottom : kCATransitionFromTop;
    [self.dragView.contentView.layer transitionWithDuration:.25f type:kCATransitionCube subtype:subtype animations:^(CALayer *transitionLayer) {
        transitionLayer.contents = (__bridge id)(image.CGImage);
    } completion:nil];
    [self.view showInfoDialog:(self.chatType == WXChatUserMine ? @"现在为自己发送消息" : [NSString stringWithFormat:@"现在为%@发送消息", self.viewModel.session.user.name])];
}

#pragma mark - MNNavigationBarDelegate
- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    WXChatSetingController *vc = [[WXChatSetingController alloc] initWithSession:self.viewModel.session];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Tool
- (void)scrollRowToVisibleOfIndex:(NSInteger)index animated:(BOOL)animated {
    CGPoint contentOffset = self.tableView.contentOffset;
    CGRect rect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    rect.origin.y -= contentOffset.y;
    rect.origin.y += self.contentView.top_mn;
    CGFloat delay = self.chatInputView.top_mn - CGRectGetMaxY(rect);
    contentOffset.y = MAX(0.f, contentOffset.y - delay);
    [self.tableView setContentOffset:contentOffset animated:animated];
}

#pragma mark - dealloc
- (void)dealloc {
    if (self.viewModel.dataSource.count > 0) {
        @PostNotify(WXSessionReloadNotificationName, nil);
    } else {
        @PostNotify(WXSessionDeleteNotificationName, self.viewModel.session);
    }
}

@end
