//
//  WechatHelper.m
//  WeChat
//
//  Created by Vincent on 2019/3/13.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WechatHelper.h"
#import "WXPreference.h"
#import "WXSession.h"
#import "WXMomentMoreView.h"
#import "WXBankCard.h"
#import "WXSong.h"
#import "WXLike.h"

static WechatHelper *_chatHelper;
static NSArray <NSString *>*MNPhoneNumberPrefixSet;

NSString * WechatPhoneGenerater (void) {
    NSInteger count = MNPhoneNumberPrefixSet.count;
    NSMutableString *phone = MNPhoneNumberPrefixSet[arc4random()%count].mutableCopy;
    for (int i = 0; i < 8; i++) {
        int random = arc4random()%9;
        [phone appendString:NSStringFromNumber(@(random))];
    }
    return phone;
}

#define WXMainQueueExecute(...) \
dispatch_async(dispatch_get_main_queue(), ^{ \
    __VA_ARGS__; \
});

@interface WechatHelper ()
@property (nonatomic, strong) MNCache *cache;
@property (nonatomic, copy) NSString *directoryPath;
@property (nonatomic, copy) NSString *avatarPath;
@property (nonatomic, copy) NSString *sessionPath;
@property (nonatomic, copy) NSString *momentPath;
@property (nonatomic, copy) NSString *favoritePath;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_queue_t sandbox_queue;
@property (nonatomic, strong) NSArray <NSString *>*signatures;
@end

@implementation WechatHelper
+ (void)load {
    MNPhoneNumberPrefixSet = @[@"139", @"138", @"137", @"136", @"135", @"181", @"150", @"147", @"198", @"157", @"187", @"188"];
}

+ (instancetype)helper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_chatHelper) {
            _chatHelper = [WechatHelper new];
        }
    });
    return _chatHelper;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatHelper = [super allocWithZone:zone];
    });
    return _chatHelper;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatHelper = [super init];
        if (_chatHelper) {
            _chatHelper.queue = dispatch_queue_create("com.wx.helper.queue", DISPATCH_QUEUE_CONCURRENT);
            _chatHelper.sandbox_queue = dispatch_queue_create("com.ext.share.queue", DISPATCH_QUEUE_SERIAL);
            // 缓存对象
            _chatHelper.cache = [[MNCache alloc] initWithName:@"WeChat"];
            // 签名缓存
            _chatHelper.signatures = [[NSArray alloc] initWithContentsOfFile:[WeChatBundle pathForResource:@"wx-user-signature" ofType:@"plist" inDirectory:@"plist"]];
            // 文件夹
            _chatHelper.directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"WeChat"];
            _chatHelper.avatarPath = [_chatHelper.directoryPath stringByAppendingPathComponent:@"avatars"];
            _chatHelper.sessionPath = [_chatHelper.directoryPath stringByAppendingPathComponent:@"sessions"];
            _chatHelper.momentPath = [_chatHelper.directoryPath stringByAppendingPathComponent:@"moments"];
            _chatHelper.favoritePath = [_chatHelper.directoryPath stringByAppendingPathComponent:@"favorites"];
            [NSFileManager.defaultManager createDirectoryAtPath:_chatHelper.avatarPath withIntermediateDirectories:YES attributes:nil error:nil];
            [NSFileManager.defaultManager createDirectoryAtPath:_chatHelper.sessionPath withIntermediateDirectories:YES attributes:nil error:nil];
            [NSFileManager.defaultManager createDirectoryAtPath:_chatHelper.momentPath withIntermediateDirectories:YES attributes:nil error:nil];
            [NSFileManager.defaultManager createDirectoryAtPath:_chatHelper.favoritePath withIntermediateDirectories:YES attributes:nil error:nil];
            // 获取银行卡信息
            [_chatHelper.cards count];
            // 添加事件通知
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needUpdateContactsInfoNotification:)
                                                         name:WXUserUpdateNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needAddContactsNotification:)
                                                         name:WXUserAddNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needDeleteContactsNotification:)
                                                         name:WXUserDeleteNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needAddSessionNotification:)
                                                         name:WXSessionAddNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needDeleteSessionNotification:)
                                                         name:WXSessionDeleteNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needUpdateSessionNotification:)
                                                         name:WXSessionUpdateNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needBringSessionToFrontNotification:)
                                                         name:WXSessionBringFrontNotificationName
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:_chatHelper
                                                     selector:@selector(needUpdateChangeMoneyNotification:)
                                                         name:WXChangeUpdateNotificationName
                                                       object:nil];
            [_chatHelper needUpdateChangeMoneyNotification:nil];
        }
    });
    return _chatHelper;
}

#pragma mark - Table
- (void)asyncLoadTable {
    /// 联系人表
    [MNDatabase createTable:WXContactsTableName class:NSClassFromString(@"WXUser") completion:nil];
    /// 标签表
    [MNDatabase createTable:WXLabelTableName class:NSClassFromString(@"WXLabel") completion:nil];
    /// 会话表
    [MNDatabase createTable:WXSessionTableName class:NSClassFromString(@"WXSession") completion:nil];
    
    /// 朋友圈数据表
    [MNDatabase createTable:WXMomentTableName class:NSClassFromString(@"WXMoment") completion:nil];
    /// 朋友圈分享表
    [MNDatabase createTable:WXMomentProfileTableName class:NSClassFromString(@"WXProfile") completion:nil];
    /// 朋友圈点赞表
    [MNDatabase createTable:WXMomentLikeTableName class:NSClassFromString(@"WXLike") completion:nil];
    /// 朋友圈评论表
    [MNDatabase createTable:WXMomentCommentTableName class:NSClassFromString(@"WXComment") completion:nil];
    /// 朋友圈提醒表
    [MNDatabase createTable:WXMomentNotifyTableName class:NSClassFromString(@"WXNotify") completion:nil];
    
    /// 收藏表
    [MNDatabase createTable:WXFavoriteTableName class:NSClassFromString(@"WXFavorite") completion:nil];
    
    /// 零钱
    [MNDatabase createTable:WXChangeTableName class:NSClassFromString(@"WXChangeModel") completion:nil];
    /// 银行卡
    [MNDatabase createTable:WXBankCardTableName class:NSClassFromString(@"WXBankCard") completion:nil];
}

#pragma mark - Data
- (void)reloadData {
    /// 删除自身缓存
    [self.sessions removeAllObjects];
    /// 刷新数据
    [self asyncSessionToSandbox];
    /// 通知更新会话
    @PostNotify(WXSessionDataReloadNotificationName, self.sessions);
    /// 删除聊天, 朋友圈相关数据
    [WechatHelper.helper.cache removeAllObjectsWithCompletion:nil];
    [MNDatabase deleteRowFromTable:WXSessionTableName where:nil completion:nil];
    [MNDatabase deleteRowFromTable:WXMomentTableName where:nil completion:nil];
    [MNDatabase deleteRowFromTable:WXMomentProfileTableName where:nil completion:nil];
    [MNDatabase deleteRowFromTable:WXMomentLikeTableName where:nil completion:nil];
    [MNDatabase deleteRowFromTable:WXMomentCommentTableName where:nil completion:nil];
    [MNDatabase deleteRowFromTable:WXMomentNotifyTableName where:nil completion:nil];
    [MNFileManager removeAllItemsAtPath:self.sessionPath error:nil];
    [MNFileManager removeAllItemsAtPath:self.momentPath error:nil];
    [MNFileManager removeAllItemsAtPath:self.favoritePath error:nil];
    /// 刷新数据
    [self asyncLoadSessions:nil];
}

/// 更新用户信息
- (void)needUpdateContactsInfoNotification:(NSNotification *)notification {
    [self asyncSessionToSandbox];
}

/// 添加用户
- (void)needAddContactsNotification:(NSNotification *)notification {
    WXUser *user = notification.object;
    if (!user) return;
    if ([self containsUser:user]) return;
    if (![MNDatabase.database insertToTable:WXContactsTableName model:user]) return;
    [self.contacts addObject:user];
    @PostNotify(WXContactsDataReloadNotificationName, self.contacts);
}

/// 删除用户
- (void)needDeleteContactsNotification:(NSNotification *)notification {
    WXUser *user = notification.object;
    if (!user) return;
    /// 刷新联系人列表
    if ([self.contacts containsObject:user]) {
        [self.contacts removeObject:user];
        WXMainQueueExecute(@PostNotify(WXContactsDataReloadNotificationName, self.contacts));
    }
    /// 更新数据库, 删除与之相关的会话
    NSArray <WXSession *>*result = [self.sessions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", user.uid]];
    if (result.count) @PostNotify(WXSessionDeleteNotificationName, result);
}

/// 添加会话
- (void)needAddSessionNotification:(NSNotification *)notification {
    WXSession *session = notification.object;
    if (!session || [self.sessions containsObject:session]) return;
    /// 创建文件夹
    [NSFileManager.defaultManager createDirectoryAtPath:[WechatHelper.helper.sessionPath stringByAppendingPathComponent:session.identifier] withIntermediateDirectories:YES attributes:nil error:nil];
    /// 根据置顶情况添加模型
    NSArray <WXSession *>*result = [self.sessions.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.front == NO"]];
    NSInteger index = result.count ? [self.sessions indexOfObject:result.firstObject] : 0;
    [self.sessions insertObject:session atIndex:index];
    /// 回调刷新列表
    [self asyncSessionToSandbox];
    WXMainQueueExecute(@PostNotify(WXSessionDataReloadNotificationName, self.sessions));
}

/// 删除会话
- (void)needDeleteSessionNotification:(NSNotification *)notification {
    if (![notification.object isKindOfClass:NSArray.class]) return;
    NSArray <WXSession *>*deletes = notification.object;
    [deletes enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /// 删除文件
        [MNFileManager removeItemAtPath:[self.sessionPath stringByAppendingPathComponent:obj.identifier] error:nil];
        /// 先删除会话表
        [MNDatabase deleteTable:obj.table_name completion:nil];
        /// 删除会话
        [MNDatabase deleteRowFromTable:WXSessionTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue completion:nil];
    }];
    /// 删除会话模型
    [self.sessions removeObjectsInArray:deletes];
    [self asyncSessionToSandbox];
    WXMainQueueExecute(@PostNotify(WXSessionDataReloadNotificationName, self.sessions));
}

/// 更新会话
- (void)needUpdateSessionNotification:(NSNotification *)notification {
    WXSession *session = notification.object;
    if (!session) return;
    [MNDatabase updateTable:WXSessionTableName where:@{sql_field(session.identifier):session.identifier}.sqlQueryValue model:session completion:nil];
}

/// 会话置顶或取消置顶
- (void)needBringSessionToFrontNotification:(NSNotification *)notification {
    WXSession *session = notification.object;
    if (!session) return;
    if ([MNDatabase.database updateTable:WXSessionTableName where:[@{sql_field(session.identifier):session.identifier} componentString] model:session]) {
        if (session.front) {
            [self.sessions bringSubjectToFront:session];
        } else if ([self.sessions containsObject:session]) {
            [self.sessions removeObject:session];
            __block NSInteger index = -1;
            [self.sessions enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.front) index ++;
            }];
            index ++;
            [self.sessions insertObject:session atIndex:index];
        }
        [self asyncSessionToSandbox];
        WXMainQueueExecute(@PostNotify(WXSessionDataReloadNotificationName, self.sessions));
    }
}

- (void)needUpdateChangeMoneyNotification:(NSNotification *)notify {
    [MNDatabase selectSumFromTable:WXChangeTableName column:@"money" completion:^(CGFloat sum) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat money = MAX(sum, 0.f);
            WXPreference.preference.money = [NSString stringWithFormat:@"%.2f", money];
            @PostNotify(WXChangeRefreshNotificationName, nil);
        });
    }];
}

#pragma mark - 加载数据库联系人
- (void)asyncLoadContacts {
    [MNDatabase selectRowsModelFromTable:WXContactsTableName class:[WXUser class] completion:^(NSArray<WXUser *> *rows) {
        if (rows.count > 0) {
            [self.contacts addObjectsFromArray:rows];
            WXMainQueueExecute(@PostNotify(WXContactsDataReloadNotificationName, self.contacts));
        } else {
            dispatch_async(self.queue, ^{
                [self fetchSystemContacts];
            });
        }
    }];
}

- (void)fetchSystemContacts {
    [MNAddressBook fetchContactsWithCompletionHandler:^(NSArray<MNContact *> *contacts) {
        [contacts enumerateObjectsUsingBlock:^(MNContact * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.phones.count <= 0 || obj.name.length <= 0) return;
            MNLabeledValue *label = obj.phones.lastObject;
            WXUser *user = WechatHelper.user;
            user.notename = obj.name;
            user.desc = @"系统通讯录";
            NSString *phone = [label.value stringByReplacingOccurrencesOfString:@"\\p{Cf}" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
            phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            user.phone = phone;
            NSData *avatarData = obj.thumbnailImageData ? : obj.imageData;
            if (avatarData) user.avatarString = [avatarData base64EncodedString];
            [self.contacts addObject:user];
            [MNDatabase insertToTable:WXContactsTableName model:user completion:nil];
        }];
        if (self.contacts.count > 0) {
            WXMainQueueExecute(@PostNotify(WXContactsDataReloadNotificationName, self.contacts));
        }
    }];
}

#pragma mark - 生成联系人
- (void)createContacts:(NSUInteger)count completion:(void(^)(BOOL))completion {
    if (count <= 0) {
        if (completion) completion(NO);
        return;
    }
    dispatch_async(self.queue, ^{
        NSMutableArray <WXUser *>*contacts = [NSMutableArray arrayWithCapacity:count];
        for (int idx = 0; idx < count; idx++) {
            WXUser *user = WechatHelper.user;
            user.desc = @"随机联系人";
            [contacts addObject:user];
            [MNDatabase insertToTable:WXContactsTableName model:user completion:nil];
        }
        [self.contacts addObjectsFromArray:contacts];
        dispatch_async(dispatch_get_main_queue(), ^{
            @PostNotify(WXContactsDataReloadNotificationName, self.contacts);
            if (completion) completion(YES);
        });
    });
}

#pragma mark - 获取头像
+ (UIImage *)avatar {
    return [[UIImage imageNamed:self.avatarName] resizingToPix:40000.f];
}

+ (NSString *)avatarName {
    uint32_t count = arc4random()%101;
    return [NSString stringWithFormat:@"wx_avatar_%@", @(count)];
}

#pragma mark - 判断uid是否有效
- (BOOL)wechatIdAvailable:(NSString *)wechatId {
    if (wechatId.length < 5) return NO;
    NSArray <WXUser *>*result = [self.contacts.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.wechatId == %@", wechatId]];
    return result.count <= 0;
}

- (void)wechatIdAvailable:(NSString *)uid completion:(void(^)(BOOL))completion {
    dispatch_async(self.queue, ^{
        BOOL allowed = [self wechatIdAvailable:uid];
        WXMainQueueExecute(if (completion) completion(allowed));
    });
}

#pragma mark - 添加联系人
- (BOOL)insertUserToContacts:(WXUser *)user {
    if (!user) return NO;
    if ([self containsUser:user]) return YES;
    if (![MNDatabase.database insertToTable:WXContactsTableName model:user]) return NO;
    [self.contacts addObject:user];
    @PostNotify(WXContactsDataReloadNotificationName, self.contacts);
    return YES;
}

#pragma mark - 判断是否存在联系人
- (BOOL)containsUser:(WXUser *)user {
    return [self containsUserWithUid:user.uid];
}

- (BOOL)containsUserWithUid:(NSString *)uid {
    if (uid.length <= 0) return NO;
    if ([uid isEqualToString:WXUser.shareInfo.uid]) return YES;
    NSArray <WXUser *>*result = [self.contacts.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", uid]];
    return result.count > 0;
}

#pragma mark - 异步加载会话列表
- (void)asyncLoadSessions:(void(^)(void))completionHandler {
    dispatch_async(self.queue, ^{
        /// 查找会话列表
        [MNDatabase selectRowsModelFromTable:WXSessionTableName class:[WXSession class] completion:^(NSArray<id> * _Nonnull rows) {
            /// 倒序添加
            [self.sessions addObjectsFromArray:rows.reversedArray];
            [self bringSubsessionToFront];
            [self asyncSessionToSandbox];
            WXMainQueueExecute(@PostNotify(WXSessionDataReloadNotificationName, self.sessions));
        }];
        WXMainQueueExecute(if (completionHandler) completionHandler());
    });
}

/// 整理前置会话
- (void)bringSubsessionToFront {
    if (self.sessions.count <= 1) return;
    NSMutableArray <WXSession *>*frontArray = [NSMutableArray new];
    [self.sessions enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.front) [frontArray addObject:obj];
    }];
    if (frontArray.count <= 0) return;
    [self.sessions removeObjectsInArray:frontArray];
    [frontArray.reversedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.sessions insertObject:obj atIndex:0];
    }];
}

#pragma mark - 获取指定uid用户
- (WXUser *)userForUid:(NSString *)uid {
    if (uid.length <= 0) return nil;
    if ([uid isEqualToString:WXUser.shareInfo.uid]) return WXUser.shareInfo;
    NSArray <WXUser *>*result = [self.contacts.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", uid]];
    return result.count ? result.firstObject : nil;
}

- (NSArray <WXUser *>*)usersForUids:(NSArray <NSString *>*)uids {
    NSMutableArray <WXUser *>*users = @[].mutableCopy;
    [uids enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray <WXUser *>*result = [self.contacts.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", obj]];
        [users addObjectsFromArray:result];
    }];
    return users.copy;
}

#pragma mark - 获取指定会话
- (WXSession *)sessionForUid:(NSString *)uid {
    if (uid.length <= 0) return nil;
    NSArray <WXSession *>*result = [self.sessions.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", uid]];
    return result.count ? result.firstObject : nil;
}

- (WXSession *)sessionForIdentifier:(NSString *)identifier {
    if (identifier.length <= 0) return nil;
    NSArray <WXSession *>*result = [self.sessions.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.identifier == %@", identifier]];
    return result.count ? result.firstObject : nil;
}

#pragma mark - 插入银行卡
+ (void)insertBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion {
    dispatch_async([[WechatHelper helper] queue], ^{
        BOOL succeed = [[WechatHelper helper] insertBankCard:card];
        WXMainQueueExecute(if (completion) completion(succeed));
    });
}

- (BOOL)insertBankCard:(WXBankCard *)card {
    if (card.isValid == NO) return NO;
    if ([[MNDatabase database] insertToTable:WXBankCardTableName model:card]) {
        [self.cards addObject:card];
        return YES;
    }
    return NO;
}

- (BOOL)deleteBankCard:(WXBankCard *)card {
    if (![self.cards containsObject:card]) return YES;
    if ([[MNDatabase database] deleteRowFromTable:WXBankCardTableName where:[@{sql_field(card.number):card.number} componentString]]) {
        [self.cards removeObject:card];
        return YES;
    }
    return NO;
}

+ (void)deleteBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion {
    dispatch_async([[WechatHelper helper] queue], ^{
        BOOL succeed = [[WechatHelper helper] deleteBankCard:card];
        WXMainQueueExecute(if (completion) completion(succeed));
    });
}

+ (void)updateBankCard:(WXBankCard *)card completion:(void(^)(BOOL succeed))completion {
    dispatch_async([[WechatHelper helper] queue], ^{
        BOOL succeed = [[WechatHelper helper] updateBankCard:card];
        WXMainQueueExecute(if (completion) completion(succeed));
    });
}

- (BOOL)updateBankCard:(WXBankCard *)card {
    if (card.isValid == NO) return NO;
    return [[MNDatabase database] updateTable:WXBankCardTableName
                                               where:[@{sql_field(card.number):card.number} componentString]
                                               model:card];
}

#pragma mark - 随机用户/微信号
+ (WXUser *)user {
    WXUser *user = WXUser.new;
    user.uid = NSDate.shortTimestamps;
    user.notename = user.nickname = [NSString chineseWithLength:(arc4random()%3 + 2)];
    user.wechatId = WechatHelper.wechatId;
    user.phone = WechatPhoneGenerater();
    user.location = WXUserDefaultLocation;
    user.gender = arc4random()%(WechatGenderFemale + 1);
    user.avatarString = WechatHelper.avatar.PNGBase64Encoding;
    if (arc4random_uniform(100) >= 50) user.signature = WechatHelper.helper.signatures.randomObject;
    return user;
}

+ (NSString *)wechatId {
    static NSString *chars = @"_a0b1c2d3e4f5g6h7i8j9klmnopqrstyxz";
    NSInteger length = arc4random()%3 + 7;
    NSMutableString *wechatId = @"".mutableCopy;
    for (int i = 0; i < length; i++) {
        NSInteger x = arc4random()%(chars.length - 1);
        [wechatId appendString:[chars substringWithRange:NSMakeRange(x, 1)]];
    }
    return wechatId.copy;
}

#pragma mark - 时间转化
+ (NSString *)momentTimeWithTimestamp:(NSString *)timestamp {
    if (timestamp.length <= 0) return @"";
    NSDateComponents *components = [NSDate dateComponentSince:timestamp];
    if (!components) return @"";
    if (components.year >= 5) {
        return @"五年前";
    } else if (components.year >= 4) {
        return @"四年前";
    } else if (components.year >= 3) {
        return @"三年前";
    } else if (components.year >= 2) {
        return @"两年前";
    } else if (components.year >= 1) {
        return @"一年前";
    } else if (components.month >= 3) {
        return @"3月前";
    } else if (components.month >= 1) {
        return @"1月前";
    } else if (components.day >= 3) {
        return [NSString stringWithFormat:@"%@天前", @(components.day)];
    } else if (components.day == 2) {
        return @"前天";
    } else if (components.day == 1) {
        return @"昨天";
    } else if (components.hour > 0) {
        return [NSString stringWithFormat:@"%@小时前", @(components.hour)];
    } else if (components.minute > 2) {
        return [NSString stringWithFormat:@"%@分钟前", @(components.minute)];
    } else {
        return @"1分钟前";
    }
}

+ (NSString *)msgTimeWithTimestamp:(NSString *)timestamp {
    if (timestamp.length <= 0) return @"";
    NSDateComponents *components = [NSDate dateComponentSince:timestamp];
    if (!components) return @"";
    if ((components.year + components.month) >= 1 || components.day >= 7) {
        return [NSDate stringValueWithTimestamp:timestamp format:@"yyyy年-MM月-dd日 HH:mm"];
    } else if (components.day == 0) {
        return [NSDate stringValueWithTimestamp:timestamp format:@"HH:mm"];
    } else if (components.day == 1) {
        return [@"昨天 " stringByAppendingString:[NSDate stringValueWithTimestamp:timestamp format:@"HH:mm"]];
    }
    return [NSString stringWithFormat:@"%@ %@", [NSDate weekdayFromDate:timestamp], [NSDate stringValueWithTimestamp:timestamp format:@"HH:mm"]];
}

+ (NSString *)favoriteTimeWithTimestamp:(NSString *)timestamp {
    if (timestamp.length <= 0) return @"";
    NSDateComponents *components = [NSDate dateComponentSince:timestamp];
    if (!components) return @"";
    if (components.year > 0 || components.month > 3) {
        return [NSDate stringValueWithTimestamp:timestamp format:@"yyyy/MM/dd"];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%@个月前", @(components.month).stringValue];
    } else if (components.day > 0) {
        return [NSString stringWithFormat:@"%@天前", @(components.day).stringValue];
    }
    return @"今天";
}

#pragma mark - 分享插件数据同步
- (void)asyncSessionToSandbox {
    dispatch_async(self.sandbox_queue, ^{
        NSMutableArray <NSDictionary *>*sessions = @[].mutableCopy;
        [self.sessions.copy enumerateObjectsUsingBlock:^(WXSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXUser *user = obj.user; 
            if (user.name.length <= 0) return;
            NSMutableDictionary *item = @{}.mutableCopy;
            [item setObject:user.uid forKey:WXShareSessionUidKey];
            [item setObject:user.name forKey:WXShareSessionNameKey];
            [item setObject:obj.identifier forKey:WXShareSessionIdentifierKey];
            NSData *imageData = user.avatar.imageData;
            if (imageData) [item setObject:imageData forKey:WXShareSessionAvatarKey];
            [sessions addObject:item];
        }];
        NSUserDefaults *UserDefaults = [[NSUserDefaults alloc] initWithSuiteName:WeChatShareSuiteName];
        [UserDefaults setObject:sessions forKey:WXShareSessionKey];
    });
}

#pragma mark - Getter
- (NSMutableArray <WXSession *>*)sessions {
    if (!_sessions) {
        _sessions = [NSMutableArray arrayWithCapacity:0];
    }
    return _sessions;
}

- (NSMutableArray <WXUser *>*)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray arrayWithCapacity:0];
    }
    return _contacts;
}

- (NSMutableArray <WXBankCard *>*)cards {
    if (!_cards) {
        NSArray *rows = [[MNDatabase database] selectRowsModelFromTable:WXBankCardTableName class:WXBankCard.class];
        _cards = [NSMutableArray arrayWithArray:rows];
    }
    return _cards;
}

#pragma mark - dealloc
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
