//
//  MCS_Macro.h
//  MNChat
//
//  Created by Vincent on 2019/3/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#ifndef WeChat_h
#define WeChat_h

/// 数据分隔符
#define WXDataSeparatedSign  @"^***^"

/// 用户注册表
#define WXUsersTableName  @"t_users"

/// 微信会话更新通知
#define WXSessionUpdateNotificationName  @"com.wx.session.update.notification.name"
/// 微信联系人更新通知
#define WXContactsUpdateNotificationName  @"com.wx.contacts.update.notification.name"

/// 微信联系人列表名
#define WXContactsTableName  @"t_contacts"
/// 微信联系人信息更改通知
#define WXUserUpdateNotificationName  @"com.wx.user.info.update.notification.name"
/// 微信联系人添加通知
#define WXUserAddNotificationName  @"com.wx.user.add.notification.name"
/// 微信联系人删除通知
#define WXUserDeleteNotificationName  @"com.wx.user.delete.notification.name"

/// 微信会话列表名
#define WXSessionTableName  @"t_sessions"
/// 微信添加会话通知
#define WXSessionAddNotificationName  @"com.wx.session.add.notification.name"
/// 微信删除会话通知
#define WXSessionDeleteNotificationName  @"com.wx.session.delete.notification.name"
/// 微信会话更新通知
#define WXSessionUpdateNotificationName  @"com.wx.session.update.notification.name"
/// 微信会话置顶通知
#define WXSessionBringFrontNotificationName  @"com.wx.session.front.notification.name"
/// 微信会话列表刷新通知
#define WXSessionReloadNotificationName  @"com.wx.session.reload.notification.name"
/// 微信表情 移除/删除 通知
#define WXEmoticonStateDidChangeNotificationName  @"com.wx.emoticon.change.notification.name"

/// 微信聊天列表刷新事件
#define WXChatListReloadNotificationName    @"com.wx.chat.list.reload.notification.name"

/// 微信收藏网页列表名
#define WXWebpageTableName  @"t_webpages"
/// 微信收藏网页列表刷新通知
#define WXWebpageReloadNotificationName  @"com.wx.webpage.reload.notification.name"


/// --------------------------begin 朋友圈相关 begin-------------------------- ///
/// 朋友圈数据库表名
#define WXMomentTableName   @"t_moments"
/// 朋友圈提醒数据库表名
#define WXMomentRemindTableName   @"t_moment_reminds"
/// 朋友圈分享数据库表名
#define WXMomentWebpageTableName   @"t_moment_webpages"
/// 朋友圈评论数据库表名
#define WXMomentCommentTableName   @"t_moment_comments"

/// 微信朋友圈添加通知
#define WXMomentAddNotificationName  @"com.wx.moment.add.notification.name"
/// 微信朋友圈删除通知
#define WXMomentDeleteNotificationName  @"com.wx.moment.delete.notification.name"
/// 微信朋友圈提醒事项通知
#define WXMomentRemindReloadNotificationName    @"com.wx.moment.remind.reload.notification.name"

/// 朋友圈内容距顶部间距
#define WXMomentAvatarTopMargin    16.f
/// 朋友圈内容左右间距
#define WXMomentContentLeftOrRightMargin     20.f
/// 朋友圈内容顶部间距
#define WXMomentContentTopMargin     8.f
/// 朋友圈头像大小
#define WXMomentAvatarWH    44.f
/// 朋友圈内部 位置 与配图/分享 间距
#define WXMomentLocationTopMargin     5.f
/// 朋友圈正文文字距头像左间距
#define WXMomentTextLeftMargin  12.f
/// 全文/收起 按钮 与 配图/分享 间隔
#define WXMomentInnerViewMargin  10.f
/// 朋友圈网页分享高度
#define WXMomentWebpageHeight   50.f
/// 配图大小 (屏幕尺寸 > 320)
#define WXMomentPictureItemWH1  86.f
/// 配图大小 (屏幕尺寸 <= 320)
#define WXMomentPictureItemWH2  70.f
/// 配图之间间隔
#define WXMomentPictureItemInnerMargin  6.f
/// 单张配图最大高度
#define WXMomentSinglePictureMaxHeight  180.f
/// 配图最大张数
#define WXMomentPicturesMaxCount    9
/// 配图列数
#define WXMomentPictureMaxCols(_count_) ((_count_==4)?2:3)
/// 向上箭头W 45
#define WXMomentArrowViewWidth    45.f
/// 向上箭头H 6
#define WXMomentArrowViewHeight   6.f
/// 更多按钮宽
#define WXMomentMoreButtonWidth     32.f
/// 更多按钮高
#define WXMomentMoreButtonHeight    20.f
/// 朋友圈更多视图宽
#define WXMomentMoreViewWidth   185.f
/// 朋友圈更多视图高
#define WXMomentMoreViewHeight  40.f
/// 更多视图动画时长
#define WXMomentMoreViewAnimatedDuration   .3f
/// 向上箭头W
#define WXMomentArrowViewWidth  45.f
/// 向上箭头H
#define WXMomentArrowViewHeight     6.f
/// 向上箭头顶部间隔
#define WXMomentArrowViewTopMargin  7.f
/// 隐私视图大小
#define WXMomentPrivacyViewWH   17.f
/// 评论内容距评论视图上下间距
#define WXMomentCommentTopOrBottomMargin    3.f
/// 评论内容距评论视图左右间距
#define WXMomentCommentLeftOrRightMargin    8.f
/// 点赞内容距评论视图上下间距
#define WXMomentLikeTopOrBottomMargin    3.5f
/// 点赞内容距评论视图左右间距
#define WXMomentLikeLeftOrRightMargin    WXMomentCommentLeftOrRightMargin
/// 朋友圈分割线高度
#define WXMomentSeparatorHeight    .5f
/// 朋友圈更多视图动画时间
#define WXMommentMoreViewAnimationDuration   .33f

/// 朋友圈昵称字体
#define WXMomentNicknameFont    [UIFont systemFontOfSizes:17.f weights:.2f]
/// 朋友圈正文字体
#define WXMomentContentTextFont     [UIFont systemFontOfSize:17.f]
/// 朋友圈 全文/收起 按钮标题字体
#define WXMomentExpandButtonTitleFont     [UIFont systemFontOfSize:18.f]
/// 朋友圈 地址 时间 来源 字体
#define WXMomentContentInnerFont    [UIFont systemFontOfSize:14.f]
/// 朋友圈 点赞 字体
#define WXMomentLikedTextFont  [UIFont systemFontOfSizes:14.5f weights:.2f]
/// 朋友圈评论内容字体
#define WXMomentCommentTextFont  [UIFont systemFontOfSize:14.5f]
/// 朋友圈评论昵称字体
#define WXMomentCommentNicknameFont  [UIFont systemFontOfSizes:14.5f weights:.2f]

/// 全局黑色字体
#define WXMomentGlobalTextColor   UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 朋友圈昵称字体颜色
#define WXMomentNicknameTextColor  UIColorWithHex(@"#5B6A92")
/// 朋友圈正文字体颜色
#define WXMomentContentTextColor    WXMomentGlobalTextColor
/// 朋友圈评论内容字体颜色
#define WXMomentCommentTextColor   WXMomentGlobalTextColor
/// 朋友圈内容 链接 电话 字体颜色
#define WXMomentLinkTextColor       UIColorWithHex(@"#4380D1")
/// 朋友圈 位置 字体颜色
#define WXMomentLocationTextColor   WXMomentNicknameTextColor
/// 朋友圈 来源 字体颜色
#define WXMomentSourceTextColor    WXMomentNicknameTextColor
/// 朋友圈 删除 字体颜色
#define WXMomentDeleteTextColor    WXMomentNicknameTextColor
/// 朋友圈 时间 字体颜色
#define WXMomentCreatedTimeTextColor    UIColorWithHex(@"#b2b1b2")
/// 朋友圈 评论or点赞view的背景色
#define WXMomentCommentViewBackgroundColor UIColorWithSingleRGB(245.f)
/// 朋友圈 评论or点赞view的选中的背景色
#define WXMomentCommentViewSelectedBackgroundColor UIColorWithHex(@"#CED2DE")

/// --------------------------end 朋友圈相关 end-------------------------- ///


/// --------------------------begin 聊天相关 begin-------------------------- ///
/// 朋友圈数据分隔符
#define WXMsgSeparatedSign  @"^---^"
/// 聊天背景图片保存key
#define WXChatBackgroundKey     @"com.wx.chat.background.key"

/// 微信消息头像大小
#define WXMsgAvatarWH     40.5f
/// 微信消息可视部分底部间隔
#define WXMsgContentBottomMargin   7.5f
/// 微信消息头像左右间距
#define WXMsgAvatarLeftOrRightMargin   15.f
/// 微信消息与头像间距<大>
#define WXMsgAvatarContentMaxMargin      13.f
/// 微信消息与头像间距<小>
#define WXMsgAvatarContentMinMargin      7.f
/// 微信文字消息内容左间距
#define WXTextMsgContentLeftMargin      17.f
/// 微信文字消息内容右间距
#define WXTextMsgContentRightMargin     11.f
/// 微信文字消息内容上下间距
#define WXTextMsgContentTopBottomMargin      10.f
/// 微信图片消息最大宽度
#define WXImageMsgMaxWidth      130.f
/// 微信图片消息最大高度
#define WXImageMsgMaxHeight      220.f
/// 微信位置消息文字左间距
#define WXLocationMsgTextLeftMargin      10.f
/// 微信位置消息文字右间距
#define WXLocationMsgTextRightMargin      15.f
/// 微信位置消息文字上间距
#define WXLocationMsgTextTopMargin      10.f
/// 微信位置消息文字下间距 <描述为空时>
#define WXLocationMsgTextBottomMaxMargin      WXLocationMsgTextTopMargin
/// 微信位置消息文字下间距 <描述不为空时>
#define WXLocationMsgTextBottomMinMargin      5.f
/// 微信位置消息文字间隔
#define WXLocationMsgTextInterval      3.f
/// 微信名片消息头像大小
#define WXCardMsgAvatarWH     43.f
/// 微信名片消息文字左间距
#define WXCardMsgLeftMargin      11.f
/// 微信名片消息文字右间距
#define WXCardMsgRightMargin      16.f
/// 微信名片消息分割线高度
#define WXCardMsgSeparatorHeight    (MN_IS_LOW_SCALE ? .5f : .3f)
/// 微信名片消息头像与文字间距
#define WXCardMsgAvatarTextMargin    WXCardMsgLeftMargin
/// 微信名片消息头像顶部间距
#define WXCardMsgTopMargin      WXCardMsgLeftMargin
/// 微信名片消息"个人名片"文字与分割线间隔
#define WXCardMsgTypeSeparatorMargin    7.f
/// 微信网页收藏消息内容上下间距
#define WXWebpageMsgContentTopBottomMargin      10.f
/// 微信网页收藏消息内容左间距
#define WXWebpageMsgContentLeftMargin      11.f
/// 微信网页收藏消息内容右间距
#define WXWebpageMsgContentRightMargin      17.f
/// 微信网页收藏消息图片大小
#define WXWebpageMsgImageViewWH      35.f
/// 微信网页收藏消息标题文字图片间距
#define WXWebpageMsgTextInterval     2.5f
/// 微信网页收藏消息描述文字图片间距
#define WXWebpageMsgDetailImageMargin     7.f
/// 微信红包消息内容左间距
#define WXRedpacketMsgContentLeftMargin      10.f
/// 微信红包消息内容右间距
#define WXRedpacketMsgContentRightMargin      15.f
/// 微信红包消息上图片与文字间隔
#define WXRedpacketMsgIconTextMargin      8.f
/// 微信红包消息上红包图片宽
#define WXRedpacketMsgIconWidth      37.f
/// 微信红包背景上部分比例<有颜色部分>
#define WXRedpacketBackgroundRatio      (191.f/252.f)
/// 微信转账消息内容左间距
#define WXTransferMsgContentLeftMargin      10.f
/// 微信转账消息内容右间距
#define WXTransferMsgContentRightMargin      15.f
/// 微信转账消息上图片与文字间隔
#define WXTransferMsgIconTextMargin      8.f
/// 微信转账消息上红包图片宽
#define WXTransferMsgIconWidth      37.f
/// 微信转账背景上部分比例<有颜色部分>
#define WXTransferBackgroundRatio      (191.f/252.f)
/// 微信语音消息图标大小
#define WXVoiceMsgIconWH      25.f
/// 微信语音消息图标上下间距
#define WXVoiceMsgIconTopOrBottomMargin      10.f
/// 微信语音消息图标左右间距
#define WXVoiceMsgIconLeftOrRightMargin      10.f
/// 微信语音消息图标与文字间距
#define WXVoiceMsgIconTextMargin      5.f
/// 微信视频消息播放视图大小
#define WXVideoMsgPlayViewWH      40.f
/// 微信视频消息最大宽度
#define WXVideoMsgMaxWidth      165.f
/// 微信视频消息最大高度
#define WXVideoMsgMaxHeight      165.f
/// 微信通话消息内容左间距
#define WXCallMsgContentLeftMargin      17.f
/// 微信通话消息内容右间距
#define WXCallMsgContentRightMargin     11.f
/// 微信通话消息角标与文字间距
#define WXCallMsgTextBadgeMargin     7.f
/// 微信消息 时间 字体颜色
#define WXMsgCreatedTimeTextColor    [[UIColor darkTextColor] colorWithAlphaComponent:.5f]
/// 微信文字消息文字颜色
#define WXTextMsgTextColor    UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信位置消息标题文字颜色
#define WXLocationMsgTitleTextColor    UIColorWithAlpha([UIColor darkTextColor], .85f)
/// 微信位置消息描述文字颜色
#define WXLocationMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信名片消息备注字体颜色
#define WXCardMsgNotenameTextColor     UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信名片消息昵称字体颜色
#define WXCardMsgNicknameTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信名片消息类型字体颜色
#define WXCardMsgTypeTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信网页收藏消息标题文字颜色
#define WXWebpageMsgTitleTextColor    UIColorWithAlpha([UIColor darkTextColor], .85f)
/// 微信网页收藏消息描述文字颜色
#define WXWebpageMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信红包消息标题文字颜色
#define WXRedpacketMsgTitleTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信红包消息领取状态文字颜色
#define WXRedpacketMsgStateTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信红包文字颜色
#define WXRedpacketMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信红包领取描述文字颜色
#define WXRedpacketMsgDescTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信红包领取描述高亮颜色
#define WXRedpacketMsgDescTextHighlightColor    MN_R_G_B(250.f, 157.f, 59.f)
/// 微信转账消息标题文字颜色
#define WXTransferMsgTitleTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信转账消息领取状态文字颜色
#define WXTransferMsgStateTextColor    UIColorWithAlpha([UIColor whiteColor], .95f)
/// 微信转账文字颜色
#define WXTransferMsgDetailTextColor    UIColorWithAlpha([UIColor darkGrayColor], .7f)
/// 微信转账领取描述文字颜色
#define WXTransferMsgDescTextColor    UIColorWithAlpha([UIColor darkGrayColor], .5f)
/// 微信转账领取描述高亮颜色
#define WXTransferMsgDescTextHighlightColor    MN_R_G_B(250.f, 157.f, 59.f)
/// 微信语音消息时长文字颜色
#define WXVoiceMsgDurationTextColor      UIColorWithAlpha([UIColor darkTextColor], .9f)
/// 微信通话消息文字颜色
#define WXCallMsgTextColor    UIColorWithAlpha([UIColor darkTextColor], .9f)

/// 微信消息时间字体
#define WXMsgCreatedTimeTextFont  [UIFont systemFontOfSize:13.f]
/// 微信文字消息字体
#define WXTextMsgTextFont    [UIFont systemFontOfSize:17.f]
/// 微信位置消息标题字体
#define WXLocationMsgTitleTextFont    [UIFont systemFontOfSize:16.f]
/// 微信位置消息描述字体
#define WXLocationMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信名片消息备注字体
#define WXCardMsgNotenameTextFont    [UIFont systemFontOfSize:17.f]
/// 微信名片消息昵称字体
#define WXCardMsgNicknameTextFont    [UIFont systemFontOfSize:13.f]
/// 微信名片消息类型字体
#define WXCardMsgTypeTextFont    [UIFont systemFontOfSize:12.f]
/// 微信网页收藏消息标题字体
#define WXWebpageMsgTitleTextFont    [UIFont systemFontOfSize:16.f]
/// 微信网页收藏消息描述字体
#define WXWebpageMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包消息标题字体<未领取>
#define WXRedpacketMsgTitleTextFont1    [UIFont systemFontOfSize:17.f]
/// 微信红包消息标题字体<已领取>
#define WXRedpacketMsgTitleTextFont2    [UIFont systemFontOfSize:15.f]
/// 微信红包消息领取状态字体
#define WXRedpacketMsgStateTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包文字字体
#define WXRedpacketMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信红包领取描述文字字体
#define WXRedpacketMsgDescTextFont    [UIFont systemFontOfSize:13.f]
/// 微信转账消息标题字体<已领取>
#define WXTransferMsgTitleTextFont    [UIFont systemFontOfSize:18.f]
/// 微信转账消息领取状态字体
#define WXTransferMsgStateTextFont    [UIFont systemFontOfSize:12.f]
/// 微信转账文字字体
#define WXTransferMsgDetailTextFont    [UIFont systemFontOfSize:12.f]
/// 微信转账领取描述文字字体
#define WXTransferMsgDescTextFont    [UIFont systemFontOfSize:13.f]
/// 微信语音消息时长文字字体
#define WXVoiceMsgDurationTextFont    [UIFont systemFontOfSize:14.f]
/// 微信通话消息字体
#define WXCallMsgTextFont    [UIFont systemFontOfSize:17.f]

/// --------------------------end 聊天相关 end-------------------------- ///

/// --------------------------begin 金钱 begin-------------------------- ///
/// 零钱表名
#define WXChangeTableName  @"t_changes"
/// 银行卡表名
#define WXBankCardTableName  @"t_bankcards"
/// 零钱变化通知
#define WXChangeUpdateNotificationName @"com.wx.pay.change.update.notification.name"
/// 零钱刷新通知
#define WXChangeRefreshNotificationName @"com.wx.pay.change.refresh.notification.name"
/// --------------------------end    金钱   end-------------------------- ///

/// --------------------------begin  摇一摇   begin-------------------------- ///
/// 摇一摇历史表
#define WXShakeHistoryTableName  @"t_shake_history"
/// --------------------------end    摇一摇    end-------------------------- ///

/// --------------------------begin  插件   begin-------------------------- ///
/// 分享插件数据沙盒名
#define WXShareExtensionSandboox    @"group.com.mn.chat.share"
/// 沙盒内存放分享网页
#define WXShareWebpageToFavorites    @"com.ext.share.to.favorites"
/// 网页-标题
#define WXShareWebpageTitle    @"com.ext.share.webpage.title"
/// 网页-url
#define WXShareWebpageUrl    @"com.ext.share.webpage.url"
/// 网页-日期
#define WXShareWebpageDate   @"com.ext.share.webpage.date"
/// 网页-缩略图
#define WXShareWebpageThumbnail    @"com.ext.share.webpage.thumbnail"
/// 沙盒内存放最近会话
#define WXShareExtensionSession    @"com.ext.share.session"
/// 最近会话-id
#define WXShareSessionIdentifier    @"com.ext.share.session.identifier"
/// 最近会话-备注/昵称
#define WXShareSessionName    @"com.ext.share.session.name"
/// 最近会话-头像
#define WXShareSessionAvatar    @"com.ext.share.session.avatar"
/// 沙盒内存放向会话分享网页
#define WXShareWebpageToSession    @"com.ext.share.to.session"
/// 沙盒内存放向朋友圈分享网页
#define WXShareWebpageToMoment    @"com.ext.share.to.moment"
/// 朋友圈文字
#define WXShareMomentText    @"com.ext.share.moment.text"
/// 沙盒内存放网页
#define WXShareExtensionWebpage   @"com.ext.share.webpage"
// 沙盒内存放是否已登录
#define WXShareExtensionLogin   @"com.ext.share.login"
/// --------------------------end    插件   end-------------------------- ///

#endif /* WeChat_h */

/// --------------------------end    内联函数   end-------------------------- ///

/// 微信消息内容最大宽度
static inline CGFloat WXMsgContentMaxWidth (void) {
    return 250.f;
}
/// 微信消息内容最小高度
static inline CGFloat WXMsgContentMinWidth (void) {
    return 100.f;
}
/// 微信消息内容最大高度
static inline CGFloat WXMsgContentMaxHeight (void) {
    return 300.f;
}

/// 微信朋友圈正文, 评论的宽度
static inline CGFloat WXMomentContentWidth(void) {
    return (MN_SCREEN_MIN - WXMomentContentLeftOrRightMargin*2 - WXMomentAvatarWH - WXMomentTextLeftMargin);
}
/// 微信朋友圈配图宽度<九宫格>
static inline CGFloat WXMomentPictureItemWidth(void) {
    return (MN_SCREEN_MIN <= 320.f ? WXMomentPictureItemWH2 : WXMomentPictureItemWH1);
}
/// 微信朋友圈单张配图最大宽度<方形or等比例>
static inline CGFloat WXMomentSinglePictureMaxWidth(void) {
    return (WXMomentPictureItemWidth() + WXMomentPictureItemInnerMargin)*2.f;
}
