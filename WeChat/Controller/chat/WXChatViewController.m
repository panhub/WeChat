//
//  WXChatViewController.m
//  WeChat
//
//  Created by Vincent on 2019/3/28.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChatViewController.h"
#import "WXChatSetingController.h"
#import "WXUserViewController.h"
#import "WXChatLocationController.h"
#import "WXFavoriteController.h"
#import "WXMapViewController.h"
#import "WXChatViewModel.h"
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
#import "WXWebpage.h"
#import "WXMessage.h"
#import "WXFileModel.h"
#import "WXMessageCell.h"
#import "WXChatInputView.h"
#import "WXSendCardAlertView.h"
#import "WXRedpacketAlertView.h"
#import "WXVoiceMessageViewModel.h"
#import "WXSpeechView.h"

typedef NS_ENUM(NSInteger, WXChatSource) {
    WXChatSourceMine = 0,
    WXChatSourceOther
};

typedef NS_ENUM(NSInteger, WXChatTipTag) {
    WXChatTipTagHide = 0,
    WXChatTipTagCopy,
    WXChatTipTagDelete,
    WXChatTipTagFavorite,
    WXChatTipTagForward,
    WXChatTipTagTurnText,
};

@interface WXChatViewController () <WXChatInputDelegate, UIScrollViewDelegate>
@property (nonatomic) BOOL speechEnabled;
@property (nonatomic) BOOL cameraEnabled;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) WXChatSource chatType;
@property (nonatomic, weak) UIView *snapshotView;
@property (nonatomic, strong) WXChatViewModel *viewModel;
@property (nonatomic, strong) WXChatInputView *chatInputView;
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
    self.navigationBar.shadowView.hidden = YES;
    //self.navigationBar.shadowView.backgroundColor = UIColorWithAlpha([UIColor darkTextColor], .1f);
    self.navigationBar.rightItemImage = [UIImage imageNamed:@"wx_common_more_black"];
    
    WXChatInputView *chatInputView = [[WXChatInputView alloc] initWithFrame:self.view.bounds];
    chatInputView.delegate = self;
    chatInputView.top_mn = self.view.height_mn - chatInputView.height_mn;
    
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
    /// 更新交互
    self.viewModel.userInteractionHandler = ^(BOOL flag) {
        @strongify(self);
        self.view.userInteractionEnabled = flag;
    };
    
    /// 刷新列表
    self.viewModel.reloadTableHandler = ^{
        [UIView performWithoutAnimation:^{
            @strongify(self);
            [self.tableView reloadData];
        }];
    };
    
    /// 加载结束事件
    self.viewModel.didLoadFinishHandler = ^(BOOL hasMore) {
        @strongify(self);
        if (hasMore) {
            [self endPullRefresh];
        } else {
            [self removeRefreshHeader];
        }
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
    
    /// 滚动指定行到可见区域
    self.viewModel.scrollRowToVisibleHandler = ^(NSUInteger row, BOOL animated) {
        @strongify(self);
        [self scrollRowToVisibleOfIndex:row animated:animated];
    };
    
    /// 已插入视图模型
    self.viewModel.didInsertViewModelHandler = ^(NSArray <WXMessageViewModel *>*viewModels) {
        @strongify(self);
        self.contentOffset = self.tableView.contentOffset;
        [self.tableView.superview insertSubview:self.snapshotView = self.tableView.snapshotView aboveSubview:self.tableView];
        if (self.chatInputView.bottom_mn < self.chatInputView.superview.height_mn) {
            [self.tableView reloadData];
            [self.tableView setNeedsLayout];
            [self.tableView layoutIfNeeded];
        } else {
            NSMutableArray <NSIndexPath *>*indexPaths = @[].mutableCopy;
            [viewModels enumerateObjectsUsingBlock:^(WXMessageViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:[self.viewModel.dataSource indexOfObject:obj] inSection:0]];
            }];
            [self.tableView insertRowsAtIndexPaths:indexPaths.copy withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView setNeedsLayout];
            [self.tableView layoutIfNeeded];
        }
    };
    
    /// 已发送消息
    self.viewModel.didSendViewModelHandler = ^(NSArray <WXMessageViewModel *>*viewModels) {
        @strongify(self);
        if (self.snapshotView) {
            [self.tableView setContentOffset:self.contentOffset animated:NO];
            [self.snapshotView removeFromSuperview];
        }
        [self scrollRowToVisibleOfIndex:[self.viewModel.dataSource indexOfObject:viewModels.lastObject] animated:self.isAppear];
        if (viewModels.firstObject.isAllowsPlaySound && self.isAppear) {
            [MNPlayer playSoundWithFilePath:[WeChatBundle pathForResource:(viewModels.firstObject.message.isMine ? @"send_msg" : @"received_msg") ofType:@"caf" inDirectory:@"sound"] shake:NO];
        }
        [MNDatabase updateTable:WXSessionTableName where:@{@"identifier":sql_pair(self.viewModel.session.identifier)}.sqlQueryValue model:self.viewModel.session completion:nil];
    };
    
    /// 头像点击事件
    self.viewModel.headButtonClickedHandler = ^(WXMessageViewModel *viewModel) {
        @strongify(self);
        if (!viewModel) return;
        WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:viewModel.message.user];
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
            WXTextMessageController *vc = [[WXTextMessageController alloc] initWithMessage:viewModel.message.content];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXImageMessage || viewModel.message.type == WXEmotionMessage) {
            /// 图片消息
            [self.viewModel stopPlaying];
            UIImage *image = (UIImage *)extend;
            if (!viewModel.containerView || !image) return;
            MNAsset *asset = [[MNAsset alloc] init];
            asset.content = image;
            asset.thumbnail = image;
            asset.type = image.isAnimatedImage ? MNAssetTypeGif : MNAssetTypePhoto;
            asset.containerView = viewModel.containerView;
            MNAssetBrowser *browser = [MNAssetBrowser new];
            browser.assets = @[asset];
            browser.backgroundColor = UIColor.blackColor;
            [browser presentFromIndex:0 animated:YES];
        } else if (viewModel.message.type == WXVideoMessage) {
            /// 视频消息
            WXFileModel *fileModel = (WXFileModel *)extend;
            if (fileModel.filePath.length <= 0 || !viewModel.containerView) return;
            MNAsset *asset = [[MNAsset alloc] init];
            asset.type = MNAssetTypeVideo;
            asset.content = fileModel.filePath;
            asset.thumbnail = fileModel.content;
            asset.containerView = viewModel.containerView;
            MNAssetBrowser *browser = [MNAssetBrowser new];
            browser.assets = @[asset];
            browser.allowsAutoPlaying = YES;
            browser.backgroundColor = UIColor.blackColor;
            [browser presentFromIndex:0 animated:YES];
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
            WXMapViewController *vc = [[WXMapViewController alloc] initWithLocation:extend];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXCardMessage) {
            /// 名片消息
            WXUserViewController *vc = [[WXUserViewController alloc] initWithUser:extend];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXWebpageMessage) {
            /// 网页消息
            MNWebViewController *vc = [[MNWebViewController alloc] initWithUrl:((WXWebpage *)extend).url];
            [self.navigationController pushViewController:vc animated:YES];
        } else if (viewModel.message.type == WXRedpacketMessage) {
            /// 红包消息
            WXRedpacket *redpacket = (WXRedpacket *)extend;
            if (redpacket.isMine) {
                [self.view showWechatDialogDelay:.5f completionHandler:^{
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
                [self.view showWechatDialogNeeds:!redpacket.isOpen delay:.5f completionHandler:^{
                    WXRedpacketAlertView *alertView = [[WXRedpacketAlertView alloc] initWithOpenHandler:^{
                        /// 更新状态
                        [self.viewModel updateViewModel:viewModel];
                    } detailHandler:^{
                        /// 领取详情
                        [self.view showWechatDialogDelay:.5f completionHandler:^{
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
                    [self.view showWechatDialogDelay:.5f completionHandler:^{
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
    
    /// 消息长按事件
    self.viewModel.imageViewLongPressHandler = ^(WXMessageViewModel *viewModel) {
        @strongify(self);
        if (self.chatInputView.isFirstResponder) {
            [self.chatInputView resignFirstResponder];
            return;
        }
        if (viewModel.message.type == WXInitialMessage) return;
        // 创建事件
        NSMutableArray <NSString *>*titles = @[].mutableCopy;
        NSMutableArray <NSString *>*imgs = @[].mutableCopy;
        NSMutableArray <NSNumber *>*tags = @[].mutableCopy;
        [titles addObject:@"删除"];
        [imgs addObject:@"chat_tip_delete"];
        [tags addObject:@(WXChatTipTagDelete)];
        switch (viewModel.message.type) {
            case WXTextMessage:
            {
                [titles insertObject:@"收藏" atIndex:0];
                [titles insertObject:@"转发" atIndex:0];
                [titles insertObject:@"复制" atIndex:0];
                [imgs insertObject:@"chat_tip_favorite" atIndex:0];
                [imgs insertObject:@"chat_tip_forward" atIndex:0];
                [imgs insertObject:@"chat_tip_copy" atIndex:0];
                [tags insertObject:@(WXChatTipTagFavorite) atIndex:0];
                [tags insertObject:@(WXChatTipTagForward) atIndex:0];
                [tags insertObject:@(WXChatTipTagCopy) atIndex:0];
            } break;
            case WXVideoMessage:
            case WXImageMessage:
            case WXWebpageMessage:
            case WXEmotionMessage:
            case WXLocationMessage:
            {
                [titles insertObject:@"收藏" atIndex:0];
                [titles insertObject:@"转发" atIndex:0];
                [imgs insertObject:@"chat_tip_favorite" atIndex:0];
                [imgs insertObject:@"chat_tip_forward" atIndex:0];
                [tags insertObject:@(WXChatTipTagFavorite) atIndex:0];
                [tags insertObject:@(WXChatTipTagForward) atIndex:0];
            } break;
            case WXTurnMessage:
            {
                [titles removeAllObjects];
                [titles addObject:@"复制"];
                [titles addObject:@"隐藏"];
                [imgs removeAllObjects];
                [imgs addObject:@"chat_tip_copy"];
                [imgs addObject:@"chat_tip_hide"];
                [tags removeAllObjects];
                [tags addObject:@(WXChatTipTagCopy)];
                [tags addObject:@(WXChatTipTagHide)];
            } break;
            case WXVoiceMessage:
            {
                [titles insertObject:@"转发" atIndex:0];
                [imgs insertObject:@"chat_tip_forward" atIndex:0];
                [tags insertObject:@(WXChatTipTagForward) atIndex:0];
#if __has_include(<Speech/Speech.h>)
                if (@available(iOS 10.0, *)) {
                    if (self.speechEnabled) {
                        NSInteger index = [self.viewModel.dataSource indexOfObject:viewModel];
                        // 判断下一条是否是转文字
                        if (self.viewModel.dataSource.count == (index + 1) || self.viewModel.dataSource[index + 1].message.type != WXTurnMessage) {
                            [titles insertObject:@"转文字" atIndex:0];
                            [imgs insertObject:@"chat_tip_turn_text" atIndex:0];
                            [tags insertObject:@(WXChatTipTagTurnText) atIndex:0];
                        }
                    }
                }
#endif
            }
            default:
                break;
        }
        // 创建视图
        UIView *contentView = [[UIView alloc] init];
        contentView.height_mn = 40.f;
        contentView.width_mn = titles.count*50.f;
        [UIView gridLayoutWithInitial:CGRectMake(0.f, 0.f, contentView.width_mn/titles.count, contentView.height_mn) offset:UIOffsetZero count:titles.count rows:titles.count handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIControl *control = [[UIControl alloc] initWithFrame:rect];
            control.user_info = viewModel;
            control.tag = tags[idx].integerValue;
            [control addTarget:self action:@selector(tip:) forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:control];
            
            UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, 20.f, 20.f) image:[UIImage imageNamed:imgs[idx]]];
            imageView.userInteractionEnabled = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.centerX_mn = control.width_mn/2.f;
            [control addSubview:imageView];
            
            UILabel *label = [UILabel labelWithFrame:CGRectZero text:titles[idx] alignment:NSTextAlignmentCenter textColor:UIColor.whiteColor font:[UIFont systemFontOfSize:13.f]];
            label.numberOfLines = 1;
            [label sizeToFit];
            label.centerX_mn = control.width_mn/2.f;
            label.bottom_mn = control.height_mn;
            [control addSubview:label];
        }];
        MNMenuView *menuView = MNMenuView.new;
        menuView.configuration.animationDuration = .1f;
        menuView.configuration.animationType = MNMenuAnimationFade;
        menuView.configuration.fillColor = MN_RGB(76.f);
        menuView.configuration.arrowSize = CGSizeMake(8.f, 4.f);
        menuView.configuration.arrowDirection = MNMenuArrowDown;
        menuView.configuration.arrowOffset = UIOffsetMake(0.f, -2.f);
        menuView.configuration.contentInsets = UIEdgeInsetsMake(-13.f, tags.firstObject.integerValue == WXChatTipTagTurnText ? -10.f : -5.f, -13.f, -5.f);
        menuView.contentView = contentView;
        menuView.targetView = viewModel.containerView;
        CGFloat horizontal = 0.f, vertical = -2.f;
        MNMenuArrowDirection direction = MNMenuArrowDown;
        CGFloat w = contentView.width_mn - menuView.configuration.contentInsets.left - menuView.configuration.contentInsets.right;
        CGRect rect = [menuView.targetView.superview convertRect:menuView.targetView.frame toView:self.view];
        if (CGRectGetMinY(rect) < (self.navigationBar.bottom_mn + 82.f)) {
            vertical = 2.f;
            direction = MNMenuArrowUp;
        }
        if (viewModel.message.isMine) {
            CGFloat x = self.view.width_mn - CGRectGetMidX(rect) - WXMsgAvatarLeftOrRightMargin/2.f;
            if (w/2.f > x) horizontal = w/2.f - x;
        } else {
            CGFloat x = CGRectGetMidX(rect) - WXMsgAvatarLeftOrRightMargin/2.f;
            if (w/2.f > x) horizontal = x - w/2.f;
        }
        menuView.configuration.arrowDirection = direction;
        menuView.configuration.arrowOffset = UIOffsetMake(horizontal, vertical);
        [menuView showInView:self.view];
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
        [MNDatabase deleteRowFromTable:self.viewModel.session.table_name where:nil completion:nil];
    }];
    /// 用户资料编辑
    [self handNotification:WXUserUpdateNotificationName eventHandler:^(NSNotification *notify) {
        @strongify(self);
        if (![kTransform(WXUser *, notify.object).uid isEqualToString:self.viewModel.session.user.uid]) return;
        self.title = self.viewModel.session.user.name;
        [self loadData];
    }];
    /// 请求用户权限
    [MNAuthenticator requestCameraAuthorizationStatusWithHandler:^(BOOL granted) {
        @strongify(self);
        self.cameraEnabled = granted;
    }];
    [MNAuthenticator requestMicrophoneAuthorizationStatusWithHandler:^(BOOL granted) {
        @strongify(self);
        self.chatInputView.microphoneEnabled = granted;
    }];
    [MNAuthenticator requestSpeechAuthorizationStatusWithHandler:^(BOOL granted) {
        @strongify(self);
        self.speechEnabled = granted;
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    self.navigationBar.shadowView.hidden = offsetY <= 0.f;
}

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
    if (![self.viewModel sendTextMsg:text isMine:self.chatType == WXChatSourceMine]) {
        [self.view showWechatError:@"消息发送失败"];
    }
}

- (void)inputViewShouldSendEmotion:(UIImage *)image {
    if (![self.viewModel sendEmotionMsg:image isMine:self.chatType == WXChatSourceMine]) {
        [self.view showWechatError:@"表情发送失败"];
    }
}

- (void)inputViewShouldSendAsset:(WXChatInputView *)inputView {
    @weakify(self);
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.allowsPickingGif = YES;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = YES;
    picker.configuration.allowsPickingLivePhoto = YES;
    picker.configuration.requestGifUseingPhotoPolicy = YES;
    picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    picker.configuration.allowsEditing = NO;
    picker.configuration.allowsTakeAsset = NO;
    picker.configuration.maxPickingCount = 1;
    picker.configuration.allowsOptimizeExporting = YES;
    [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
        if (assets.count <= 0 || !assets.firstObject.content) return;
        @strongify(self);
        MNAsset *asset = assets.firstObject;
        if (asset.type == MNAssetTypeVideo) {
            if (![self.viewModel sendVideoMsg:asset.content isMine:self.chatType == WXChatSourceMine]) {
                [self.view showWechatError:@"视频发送失败"];
            }
        } else {
            if (![self.viewModel sendImageMsg:asset.content isMine:self.chatType == WXChatSourceMine]) {
                [self.view showWechatError:@"图片发送失败"];
            }
        }
    } cancelHandler:nil];
}

- (void)inputViewShouldSendCapture:(WXChatInputView *)inputView {
    if (!self.cameraEnabled) {
        [self.view showWechatError:@"未获得摄像头权限"];
        return;
    }
    @weakify(self);
    MNAssetPicker *picker = [MNAssetPicker camera];
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = YES;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.maxCaptureDuration = 60.f;
    picker.configuration.allowsEditing = NO;
    picker.configuration.allowsOptimizeExporting = YES;
    [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
        if (assets.count <= 0 || !assets.firstObject.content) return;
        @strongify(self);
        MNAsset *asset = assets.firstObject;
        if (asset.type == MNAssetTypeVideo) {
            if (![self.viewModel sendVideoMsg:asset.content isMine:self.chatType == WXChatSourceMine]) {
                [self.view showWechatError:@"视频发送失败"];
            }
        } else {
            if (![self.viewModel sendImageMsg:asset.content isMine:self.chatType == WXChatSourceMine]) {
                [self.view showWechatError:@"图片发送失败"];
            }
        }
    } cancelHandler:nil];
}

- (void)inputViewShouldSendCard:(WXChatInputView *)inputView {
    @weakify(self);
    WXUser *toUser = self.viewModel.session.user;
    WXContactsSelectController *viewController = WXContactsSelectController.new;
    viewController.expelUsers = @[toUser];
    viewController.selectedHandler = ^(WXContactsSelectController *vc) {
        WXSendCardAlertView *alertView = WXSendCardAlertView.new;
        alertView.user = vc.users.firstObject;
        alertView.toUser = toUser;
        @weakify(vc);
        // 用户信息查看
        alertView.userClickHandler = ^(WXSendCardAlertView *aView) {
            @strongify(vc);
            WXUserViewController *infoController = [[WXUserViewController alloc] initWithUser:aView.toUser];
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
                if (![self.viewModel sendCardMsg:cUser text:mText isMine:self.chatType == WXChatSourceMine]) {
                    [self.view showWechatError:@"推荐联系人失败"];
                }
            });
        }];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)inputViewShouldSendCall:(WXChatInputView *)inputView {
    @weakify(self);
    [[MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) return;
        @strongify(self);
        if (buttonIndex == 0) {
            [self startVoiceCalling:self.chatType == WXChatSourceMine];
        } else {
            [self startVideoCalling:self.chatType == WXChatSourceMine];
        }
    } otherButtonTitles:@"语音通话", @"视频通话", nil] show];
}

- (void)inputViewShouldSendLocation:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatSourceMine;
    WXChatLocationController *vc = [WXChatLocationController new];
    @weakify(self);
    vc.didSelectHandler = ^(WXLocation *location) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        dispatch_after_main(.5f, ^{
            if (![self.viewModel sendLocationMsg:location isMine:isMine]) {
                [self.view showWechatError:@"位置发送失败"];
            }
        });
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendFavorite:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatSourceMine;
    WXFavoriteController *vc = [WXFavoriteController new];
    @weakify(self);
    vc.selectedHandler = ^(WXFavorite *favorite) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        self.view.userInteractionEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![self.viewModel sendFavoriteMsg:favorite isMine:isMine]) {
                [self.view showWechatError:@"发送失败"];
            }
            self.view.userInteractionEnabled = YES;
        });
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendRedpacket:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatSourceMine;
    WXRedpacketViewController *vc = [WXRedpacketViewController new];
    vc.mine = isMine;
    @weakify(self);
    vc.completionHandler = ^(NSString *money, NSString *text) {
        @strongify(self);
        if (![self.viewModel sendRedpacketMsg:text money:money isMine:isMine]) {
            [self.view showWechatError:@"红包发送失败"];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendTransfer:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatSourceMine;
    WXUser *user = isMine ? self.viewModel.session.user : WXUser.shareInfo;
    WXTransferViewController *vc = [[WXTransferViewController alloc] initWithUser:user];
    @weakify(self);
    vc.completionHandler = ^(NSString *money, NSString *text) {
        @strongify(self);
        if (![self.viewModel sendTransferMsg:text money:money time:[NSDate timestamps] isMine:isMine isUpdate:NO]) {
            [self.view showWechatError:@"转账失败"];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)inputViewShouldSendVoice:(WXChatInputView *)inputView {
    BOOL isMine = self.chatType == WXChatSourceMine;
    [self.viewModel sendVoiceMsg:nil isMine:isMine];
}

- (void)inputViewDidCancelVoice:(WXChatInputView *)inputView {
    dispatch_after_main(.3f, ^{
        [self.viewModel cancelVoiceMsg];
    });
}

- (void)inputViewDidSendVoice:(NSString *)voicePath {
    BOOL isMine = self.chatType == WXChatSourceMine;
    [self.viewModel sendVoiceMsg:voicePath isMine:isMine];
}

- (void)inputViewShouldSendSpeech:(WXChatInputView *)inputView {
    if (@available(iOS 10.0, *)) {
        if (!self.speechEnabled) {
            [self.view showWechatError:@"未获得语音识别权限"];
            return;
        }
    } else {
        [self.view showWechatError:@"版本不支持"];
        return;
    }
    @weakify(self);
    WXSpeechView *speechView = [[WXSpeechView alloc] initWithSpeechHandler:^(NSString * _Nullable text) {
        @strongify(self);
        [self inputViewShouldSendText:text];
    }];
    [speechView showInView:self.view];
}

- (void)inputViewShouldInsertEmojiToFavorites:(WXChatInputView *)inputView {
    MNAssetPicker *picker = [MNAssetPicker picker];
    picker.configuration.allowsPickingGif = NO;
    picker.configuration.allowsPickingPhoto = YES;
    picker.configuration.allowsPickingVideo = NO;
    picker.configuration.allowsPickingLivePhoto = NO;
    picker.configuration.requestGifUseingPhotoPolicy = YES;
    picker.configuration.requestLivePhotoUseingPhotoPolicy = YES;
    picker.configuration.allowsEditing = NO;
    picker.configuration.allowsPreviewing = NO;
    picker.configuration.allowsTakeAsset = NO;
    picker.configuration.allowsOptimizeExporting = YES;
    [picker presentWithPickingHandler:^(MNAssetPicker * _Nonnull picker, NSArray<MNAsset *> * _Nullable assets) {
        if (assets.count <= 0) return;
        [MNEmojiManager.defaultManager insertEmojiToFavorites:assets.firstObject.content desc:nil];
    } cancelHandler:nil];
}

- (void)inputViewShouldAddEmojiPackets:(WXChatInputView *)inputView {
    UIViewControllerPush(@"WXEmoticonViewController", YES);
}

#pragma mark - Call
- (void)startVoiceCalling:(BOOL)isMine {
    WXVoiceCallController *viewController = [[WXVoiceCallController alloc] initWithUser:self.viewModel.session.user style:(isMine ? WXVoipStyleSend : WXVoipStyleReceive)];
    viewController.didEndCallHandler = ^(WXVoiceCallController *vc) {
        [self.viewModel sendCallMsg:vc.description isVideo:NO isMine:isMine];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)startVideoCalling:(BOOL)isMine {
    WXVideoCallController *viewController = [[WXVideoCallController alloc] initWithUser:self.viewModel.session.user style:(isMine ? WXVoipStyleSend : WXVoipStyleReceive)];
    viewController.didEndCallHandler = ^(WXVideoCallController *vc) {
        [self.viewModel sendCallMsg:vc.description isVideo:YES isMine:isMine];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Event
- (void)tip:(UIControl *)sender {
    [self.view closeMenuView];
    WXMessageViewModel *viewModel = sender.user_info;
    if (!viewModel) return;
    switch (sender.tag) {
        case WXChatTipTagCopy:
        {
            // 复制
            UIPasteboard.generalPasteboard.string = viewModel.message.content;
            [self.view showDialog:MNLoadDialogStyleWechatComplete message:@"已复制内容至剪切板"];
        } break;
        case WXChatTipTagDelete:
        {
            // 删除
            @weakify(self);
            MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:@"是否删除该条消息?" cancelButtonTitle:@"取消" handler:^(MNActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                @strongify(self);
                if (buttonIndex == actionSheet.cancelButtonIndex) return;
                [self.viewModel deleteViewModel:viewModel];
            } otherButtonTitles:@"确定", nil];
            [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:0];
            [actionSheet showInView:self.view];
        } break;
        case WXChatTipTagFavorite:
        {
            // 收藏
            if ([self.viewModel collectViewModel:viewModel]) {
                [self.view showDialog:MNLoadDialogStyleWechatComplete message:@"已收藏"];
            }
        } break;
        case WXChatTipTagForward:
        {
            // 转发
            @weakify(self);
            WXContactsSelectController *viewController = [[WXContactsSelectController alloc] initWithSelectedHandler:^(WXContactsSelectController *vc) {
                [vc.navigationController popViewControllerAnimated:YES];
                dispatch_after_main(.3f, ^{
                    @strongify(self);
                    [self.viewModel forwardViewModel:viewModel user:vc.users.firstObject];
                });
            }];
            viewController.expelUsers = @[WXUser.shareInfo, self.viewModel.session.user];
            [self.navigationController pushViewController:viewController animated:YES];
        } break;
        case WXChatTipTagTurnText:
        {
            // 转文字
            [self.viewModel turnTextForViewModel:viewModel];
        } break;
        case WXChatTipTagHide:
        {
            // 隐藏
            [self.viewModel hideTurnTextForViewModel:viewModel];
        } break;
        default:
            break;
    }
}

#pragma mark - MNDragViewDelegate
- (void)dragViewDidClicking:(MNDragView *)slideView {
    self.chatType = 1 - self.chatType;
    UIImage *image = self.chatType == WXChatSourceMine ? self.viewModel.session.user.avatar : [WXUser.shareInfo avatar];
    CATransitionSubtype subtype = self.chatType == WXChatSourceMine ? kCATransitionFromBottom : kCATransitionFromTop;
    [self.dragView.contentView.layer transitionWithDuration:.25f type:kCATransitionCube subtype:subtype animations:^(CALayer *transitionLayer) {
        transitionLayer.contents = (__bridge id)(image.CGImage);
    } completion:nil];
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

#pragma mark - Super
- (UIView *)refreshHeader {
    return [[NSClassFromString(@"MNRefreshHeader") alloc] init];
}

- (void)beginPullRefresh {
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself reloadData];
    });
}

#pragma mark - dealloc
- (void)dealloc {
    @PostNotify(WXSessionTableReloadNotificationName, nil);
}

@end
