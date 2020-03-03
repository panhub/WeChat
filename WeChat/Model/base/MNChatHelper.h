//
//  MNChatHelper.h
//  MNChat
//
//  Created by Vincent on 2019/3/13.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WXUser , WXSession, WXBankCard, WXSong;

typedef void(^WXContactsUpdateHandler)(NSArray <WXUser *>*contacts);

typedef void(^WXSessionUpdateHandler)(NSArray <WXSession *>*sessions);

NSString * MNRandomPhoneNumber (void);

@interface MNChatHelper : NSObject
/**
 联系人列表
 */
@property (nonatomic, strong) NSMutableArray <WXUser *>*contacts;
/**
 会话列表
 */
@property (nonatomic, strong) NSMutableArray <WXSession *>*sessions;
/**
 银行卡
 */
@property (nonatomic, strong) NSMutableArray <WXBankCard *>*cards;
/**
 缓存区Directory
 */
@property (nonatomic, readonly, strong) MNCache *cache;
/**
 文件缓存文件夹
*/
@property (nonatomic, readonly, copy) NSString *directoryPath;
/**
 重载联系人列表回调
 */
@property (nonatomic, copy) WXContactsUpdateHandler contactsUpdateHandler;
/**
 重载会话列表回调
 */
@property (nonatomic, copy) WXSessionUpdateHandler sessionUpdateHandler;

/**
 唯一实例化入口
 @return 实例
 */
+ (instancetype)helper;

/**
 异步加载表
 */
- (void)asyncLoadTable;

/**
 清除相关数据
 */
- (void)reloadData;

/**
 异步加载通讯录
 */
- (void)asyncLoadContacts;

/**
 异步加会话
 */
- (void)asyncLoadSessions:(void(^)(void))completionHandler;

/**
 生成指定数量的用户
 @param count 指定数量
 @param completion 生成回调
 */
- (void)createContacts:(NSUInteger)count completion:(WXContactsUpdateHandler)completion;

/**
 随机获取联系人头像
 @return 随机头像
 */
+ (UIImage *)randomAvatarImage;

/**
 判断uid是否有效
 @param uid uid
 @return 是否有效
 */
- (BOOL)wechatIdAvailable:(NSString *)uid;

/**
 判断uid是否有效
 @param uid uid
 @param completion 是否有效回调
 */
- (void)wechatIdAvailable:(NSString *)uid completion:(void(^)(BOOL allowed))completion;

/**
 往通讯录中插入联系人
 @param user 联系人
 @return 是否添加成功
 */
- (BOOL)insertUserToContacts:(WXUser *)user;

/**
 是否有此用户
 @param user 指定用户
 @return 判断结果
 */
- (BOOL)containsUser:(WXUser *)user;

/**
 是否有此用户
 @param uid 指定用户uid
 @return 判断结果
 */
- (BOOL)containsUserWithUid:(NSString *)uid;

/**
 获取指定uid用户
 @param uid 指定uid
 @return 联系人
 */
- (WXUser *)userForUid:(NSString *)uid;

/**
 获取指定uid用户
 @param uids 指定uid数组
 @return 联系人数组
 */
- (NSArray <WXUser *>*)usersForUids:(NSArray <NSString *>*)uids;

/**
 保存银行卡
 @param card 银行卡
 @param completion 是否保存成功
 */
+ (void)insertBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion;

/**
 保存银行卡
 @param card 银行卡
 @return 是否保存成功
 */
- (BOOL)insertBankCard:(WXBankCard *)card;

/**
 删除银行卡
 @param card 银行卡
 @return 是否删除成功
 */
- (BOOL)deleteBankCard:(WXBankCard *)card;

/**
 删除银行卡
 @param card 银行卡
 @param completion 是否删除成功
 */
+ (void)deleteBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion;

/**
 更新银行卡
 @param card 银行卡
 @param completion 是否更新成功
 */
+ (void)updateBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion;

/**
 更新银行卡
 @param card 银行卡
 @return 是否更新成功
 */
- (BOOL)updateBankCard:(WXBankCard *)card;

/**
 朋友圈时间显示
 @param timestamp 时间戳
 @return 朋友圈时间
 */
+ (NSString *)momentCreatedTimeWithTimestamp:(NSString *)timestamp;

/**
 聊天时间显示
 @param timestamp 时间戳
 @return 聊天时间
 */
+ (NSString *)chatMsgCreatedTimeWithTimestamp:(NSString *)timestamp;

/**
 获取指定用户会话
 @param uid 指定uid
 @return 会话实例
 */
- (WXSession *)sessionForUid:(NSString *)uid;

/**
 获取指定会话
 @param identifier 会话标识
 @return 会话实例
 */
- (WXSession *)sessionForIdentifier:(NSString *)identifier;

/**
 生成随机用户
 */
+ (WXUser *)generateRandomUser;

/**
生成随机微信号
*/
+ (NSString *)generateRandomWechatId;

@end
