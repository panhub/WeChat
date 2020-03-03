//
//  WXChatViewModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//  聊天视图模型

#import <Foundation/Foundation.h>
#import "WXMessageViewModel.h"
@class WXSession, WXMapLocation, WXWebpage, WXFileModel;

@interface WXChatViewModel : NSObject
/**
 会话
 */
@property (nonatomic, strong) WXSession *session;
/**
 数据源
 */
@property (nonatomic, strong) NSMutableArray <WXMessageViewModel *>*dataSource;

/**
 刷新表事件
 */
@property (nonatomic, copy) void (^reloadTableHandler) (void);
/**
 刷新行事件
 */
@property (nonatomic, copy) void (^reloadRowHandler) (NSInteger row);
/**
 加载结束回调
 */
@property (nonatomic, copy) void (^didLoadFinishHandler) (BOOL removed);
/**
 已发送消息事件
 */
@property (nonatomic, copy) void (^didSendViewModelHandler) (NSArray <WXMessageViewModel *>*viewModels);
/**
 已插入消息
 */
@property (nonatomic, copy) void (^didInsertViewModelHandler) (NSArray <WXMessageViewModel *>*viewModels);
/**
 滚动到指定行事件
 */
@property (nonatomic, copy) void (^scrollRowToBottomHandler) (NSUInteger, BOOL);
/**
 头像点击事件
 */
@property (nonatomic, copy) void (^headButtonClickedHandler) (WXMessageViewModel *viewModel);
/**
 图片点击事件
 */
@property (nonatomic, copy) void (^imageViewClickedHandler) (WXMessageViewModel *viewModel);
/**
 文字点击事件
 */
@property (nonatomic, copy) void (^textLabelClickedHandler) (WXMessageViewModel *viewModel);

/**
 加载聊天数据
 */
- (void)loadData;

/**
 唯一初始化入口
 @param session 会话模型
 @return 聊天视图模型
 */
- (instancetype)initWithSession:(WXSession *)session;

#pragma mark - Send Msg
/**
 发送文本消息
 @param text 文本内容
 @param isMine 是否是自己发送
 @return 是否成功
 */
- (BOOL)sendTextMsg:(NSString *)text isMine:(BOOL)isMine;
/**
 发送图片消息
 @param image 图片
 @param isMine 是否是自己发送
 @return 是否成功
 */
- (BOOL)sendImageMsg:(UIImage *)image isMine:(BOOL)isMine;

/**
 发送表情消息
 @param image 表情
 @param isMine 是否是自己发送
 @return 是否成功
 */
- (BOOL)sendEmotionMsg:(UIImage *)image isMine:(BOOL)isMine;

/**
 发送位置消息
 @param location 经纬度
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendLocationMsg:(WXMapLocation *)location isMine:(BOOL)isMine;

/**
 发送收藏消息
 @param webpage 收藏数据模型
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendWebpage:(WXWebpage *)webpage isMine:(BOOL)isMine;

/**
 发送红包消息
 @param text 标题
 @param money 金额
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendRedpacketMsg:(NSString *)text money:(NSString *)money isMine:(BOOL)isMine;

/**
 发送转账消息
 @param text 标题
 @param money 金额
 @param time 消息创建时间<便于发送领取消息时使用>
 @param isMine 是否是自己发送
 @param isUpdate 是否是更新状态消息<领取转账, 自发送>
 @return 是否发送成功
 */
- (BOOL)sendTransferMsg:(NSString *)text money:(NSString *)money time:(NSString *)time isMine:(BOOL)isMine isUpdate:(BOOL)isUpdate;

/**
 发送语音消息
 @param voicePath 语音路径<nilable 代表预发送>
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendVoiceMsg:(NSString *)voicePath isMine:(BOOL)isMine;

/**
 取消语音消息
 @return 是否取消成功
 */
- (BOOL)cancelVoiceMsg;

/**
 发送名片消息
 @param user 联系人
 @param text 文字消息
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendCardMsg:(WXUser *)user text:(NSString *)text isMine:(BOOL)isMine;

/**
 发送视频消息
 @param videoPath 视频路径
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendVideoMsg:(NSString *)videoPath isMine:(BOOL)isMine;

/**
 发送通话消息消息
 @param desc 描述信息
 @param isVideo 是否是视频通话
 @param isMine 是否是自己发送
 @return 是否发送成功
 */
- (BOOL)sendCallMsg:(NSString *)desc isVideo:(BOOL)isVideo isMine:(BOOL)isMine;

/**
 停止音频播放<播放视频前最好调用>
 */
- (void)pauseVoicePlay;

#pragma mark - Update Msg
/**
 更新视图模型<红包状态修改>
 @param viewModel 视图模型
 @return 是否更新成功
 */
- (BOOL)updateViewModel:(WXMessageViewModel *)viewModel;

@end
