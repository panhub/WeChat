//
//  WXMessage.h
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//  微信消息模型  

#import <Foundation/Foundation.h>
#import "WXLocation.h"
#import "WXRedpacket.h"
#import "WXFileModel.h"
@class WXSession, WXUser, WXWebpage;

typedef NS_ENUM(NSInteger, WXMessageType) {
    WXInitialMessage = 0,
    WXTextMessage,
    WXImageMessage,
    WXVoiceMessage,
    WXTurnMessage,
    WXVideoMessage,
    WXLocationMessage,
    WXWebpageMessage,
    WXRedpacketMessage,
    WXTransferMessage,
    WXCardMessage,
    WXEmotionMessage,
    WXVoiceCallMessage,
    WXVideoCallMessage
};

@interface WXMessage : NSObject

#pragma mark - 作为数据库字段存在
/**
 消息类型
 */
@property (nonatomic) WXMessageType type;
/**
 消息标识
 */
@property (nonatomic, copy) NSString *identifier;
/**
 发送方uid
 */
@property (nonatomic, copy) NSString *uid;
/**
 文字内容
 */
@property (nonatomic, copy) NSString *content;
/**
 文件流
*/
@property (nonatomic, copy) NSData *profile;
/**
 时间戳
 */
@property (nonatomic, copy) NSString *timestamp;
/**
 是否显示时间
 */
@property (nonatomic) BOOL show_time;
/**
 外界获取消息描述
 */
@property (nonatomic, copy) NSString *desc;
/**
 是否时自己发送的消息
 */
@property (nonatomic, getter=isMine) BOOL mine;


#pragma mark - Getter
/**
 发送方用户
 */
@property (nonatomic, strong, readonly) WXUser *user;
/**
 图片<图片类型>
 */
@property (nonatomic, strong, readonly) WXFileModel *fileModel;

/**
 创建初始消息
 @param session 当前会话
 @return 添加成功消息
 */
+ (instancetype)createInitialMessageWithSession:(WXSession *)session;

/**
 创建文字消息
 @param content 文字
 @param isMine 是否自己发送的消息
 @param session 当前会话
 @return 文字消息
 */
+ (instancetype)createTextMsg:(NSString *)content isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建图片消息
 @param image 图片
 @param isMine 是否自己发送的消息
 @param session 当前会话
 @return 图片消息
 */
+ (instancetype)createImageMsg:(UIImage *)image isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建表情消息
 @param image 表情图片
 @param isMine 是否自己发送的消息
 @param session 当前会话
 @return 表情消息
 */
+ (instancetype)createEmotionMsg:(UIImage *)image isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建位置消息
 @param location 位置<经纬度>
 @param isMine 是否是自己发送的消息
 @param session 当前会话
 @return 位置信息
 */
+ (instancetype)createLocationMsg:(WXLocation *)location isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建网页消息
 @param webpage 网页模型
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 网页消息
 */
+ (instancetype)createWebpageMsg:(WXWebpage *)webpage isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建红包消息
 @param text 附带描述
 @param money 金额
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 红包消息
 */
+ (instancetype)createRedpacketMsg:(NSString *)text money:(NSString *)money isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建转账消息
 @param text 附带描述
 @param money 金额
 @param time 消息创建时间<创建领取消息时使用>
 @param isMine 是否是自己发送消息
 @param isUpdate 是否是更新状态消息<领取转账, 自发送>
 @param session 当前会话
 @return 红包消息
 */
+ (instancetype)createTransferMsg:(NSString *)text money:(NSString *)money time:(NSString *)time isMine:(BOOL)isMine isUpdate:(BOOL)isUpdate session:(WXSession *)session;

/**
 创建语音消息
 @param voicePath 语音文件路径
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 语音消息
 */
+ (instancetype)createVoiceMsg:(NSString *)voicePath isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建语音转文字消息
 @param message 文字内容
 @param isMine 是否是自己发送消息
 @return 语音转文字消息
 */
+ (instancetype)createTurnMsg:(NSString *)message isMine:(BOOL)isMine;

/**
 创建视频消息
 @param videoPath 视频文件路径
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 视频消息
 */
+ (instancetype)createVideoMsg:(NSString *)videoPath isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建名片消息
 @param user 名片联系人
 @param text 文字消息
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 名片消息<可能包含文字消息>
 */
+ (NSArray <WXMessage *>*)createCardMsg:(WXUser *)user text:(NSString *)text isMine:(BOOL)isMine session:(WXSession *)session;

/**
 创建通话消息
 @param desc 描述信息
 @param isVideo 是否视频通话
 @param isMine 是否是自己发送消息
 @param session 当前会话
 @return 通话消息
 */
+ (instancetype)createCallMsg:(NSString *)desc isVideo:(BOOL)isVideo isMine:(BOOL)isMine session:(WXSession *)session;

/**
 更新数据<红包修改领取状态>
 @return 是否更新成功
 */
- (BOOL)update;

@end

