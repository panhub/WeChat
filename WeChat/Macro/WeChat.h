//
//  MCS_Macro.h
//  WeChat
//
//  Created by Vincent on 2019/3/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#ifndef WeChat_h
#define WeChat_h

/**
 滑动方向
 - WXScrollDirectionUnknown: 未知
 - WXScrollDirectionUp: 向上
 - WXScrollDirectionDown: 向下
 */
typedef NS_ENUM(NSInteger, WXScrollDirection) {
    WXScrollDirectionUnknown = 0,
    WXScrollDirectionUp,
    WXScrollDirectionDown
};

/// 文字分割标识分隔符
#define WeChatSeparator  @"~!+=-^*%¢181377¥@-=+!~"

/// 微信联系人列表名
#define WXContactsTableName  @"t_contacts"
/// 微信联系人信息更改通知
#define WXUserUpdateNotificationName  @"com.wx.user.info.update.notification.name"
/// 微信联系人添加通知
#define WXUserAddNotificationName  @"com.wx.user.add.notification.name"
/// 微信联系人删除通知
#define WXUserDeleteNotificationName  @"com.wx.user.delete.notification.name"
/// 微信联系人数据重载通知
#define WXContactsDataReloadNotificationName  @"com.wx.contacts.data.reload.notification.name"

/// 微信标签列表名
#define WXLabelTableName  @"t_labels"
/// 微信标签刷新通知
#define WXLabelUpdateNotificationName  @"com.wx.label.update.notification.name"

/// 微信会话列表名
#define WXSessionTableName  @"t_sessions"
/// 微信添加会话通知
#define WXSessionAddNotificationName  @"com.wx.session.add.notification.name"
/// 微信删除会话通知
#define WXSessionDeleteNotificationName  @"com.wx.session.delete.notification.name"
/// 微信指定会话更新通知
#define WXSessionUpdateNotificationName  @"com.wx.session.update.notification.name"
/// 微信会话置顶通知
#define WXSessionBringFrontNotificationName  @"com.wx.session.front.notification.name"
/// 微信会话列表刷新数据通知
#define WXSessionTableReloadNotificationName  @"com.wx.session.table.reload.notification.name"
/// 微信会话数据重载通知
#define WXSessionDataReloadNotificationName  @"com.wx.session.data.reload.notification.name"
/// 微信表情 移除/删除 通知
#define WXEmoticonStateDidChangeNotificationName  @"com.wx.emoticon.change.notification.name"

/// 微信聊天列表刷新事件
#define WXMessageUpdateNotificationName    @"com.wx.chat.list.reload.notification.name"

/// 微信收藏数据库表名
#define WXFavoriteTableName  @"t_favorites"
/// 微信收藏更新通知
#define WXFavoriteUpdateNotificationName  @"com.wx.favorite.reload.notification.name"


/// --------------------------begin 朋友圈相关 begin-------------------------- ///
/// 朋友圈数据库表名
#define WXMomentTableName   @"t_moments"
/// 朋友圈提醒数据库表名
#define WXMomentNotifyTableName   @"t_moment_notifys"
/// 朋友圈点赞数据库表名
#define WXMomentLikeTableName   @"t_moment_likes"
/// 朋友圈配图数据库表名
#define WXMomentProfileTableName   @"t_moment_profiles"
/// 朋友圈评论数据库表名
#define WXMomentCommentTableName   @"t_moment_comments"

/// 微信朋友圈添加通知
#define WXMomentUpdateNotificationName  @"com.wx.moment.update.notification.name"
/// 微信朋友圈删除通知
#define WXMomentDeleteNotificationName  @"com.wx.moment.delete.notification.name"
/// 微信朋友圈提醒事项通知
#define WXMomentNotifyReloadNotificationName    @"com.wx.moment.notify.reload.notification.name"

/// --------------------------end 朋友圈相关 end-------------------------- ///

/// --------------------------begin 相册 begin-------------------------- ///
///
/// 微信相册图片通知
#define WXAlbumPictureDeleteNotificationName  @"com.wx.album.picture.delete.notification.name"

/// ----------------------------end 相册 end-------------------------- ///


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
#define WeChatShareSuiteName    @"group.com.mn.chat.share"

// 沙盒内存放是否已登录
#define WXShareLoginKey   @"com.ext.share.login"

/// 分享公共沙盒收藏提取标记
#define WXShareFavoritesKey    @"com.ext.share.favorites"
/// 分享公共沙盒收藏标题提取标记
#define WXShareFavoriteTitleKey    @"com.ext.share.favorite.title"
/// 分享公共沙盒收藏副标题提取标记
#define WXShareFavoriteSubtitleKey    @"com.ext.share.favorite.subtitle"
/// 分享公共沙盒收藏Url提取标记
#define WXShareFavoriteUrlKey    @"com.ext.share.favorite.url"
/// 分享公共沙盒收藏时间提取标记
#define WXShareFavoriteTimeKey   @"com.ext.share.favorite.time"
/// 分享公共沙盒收藏图片提取标记
#define WXShareFavoriteImageKey    @"com.ext.share.favorite.image"
/// 分享公共沙盒收藏来源提取标记
#define WXShareFavoriteSourceKey    @"com.ext.share.favorite.source"

/// 分享公共沙盒存放最近会话
#define WXShareSessionKey    @"com.ext.share.session"
/// 分享公共沙盒最近会话-id
#define WXShareSessionIdentifierKey    @"com.ext.share.session.identifier"
/// 分享公共沙盒最近会话-备注/昵称
#define WXShareSessionNameKey    @"com.ext.share.session.name"
/// 分享公共沙盒最近会话-头像
#define WXShareSessionAvatarKey    @"com.ext.share.session.avatar"
/// 分享公共沙盒最近会话-Uid
#define WXShareSessionUidKey    @"com.ext.share.session.uid"

/// 分享公共沙盒存放会话消息
#define WXShareToSessionKey    @"com.ext.share.to.session"
/// 分享公共沙盒存放会话网页数据
#define WXShareToSessionWebpageKey   @"com.ext.share.to.session.webpage"

/// 分享公共沙盒存放朋友圈数据
#define WXShareToMomentKey    @"com.ext.share.to.moment"
/// 分享公共沙盒存放朋友圈数据文字
#define WXShareToMomentWebpageKey    @"com.ext.share.to.moment.webpage"
/// 分享公共沙盒存放朋友圈数据文字
#define WXShareToMomentTextKey    @"com.ext.share.to.moment.text"


/// --------------------------end    插件   end-------------------------- ///

#endif /* WeChat_h */

