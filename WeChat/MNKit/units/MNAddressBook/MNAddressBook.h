//
//  MNAddressBook.h
//  MNKit
//
//  Created by Vincent on 2019/3/16.
//  Copyright © 2019 Vincent. All rights reserved.
//  获取联系人信息

#import <Foundation/Foundation.h>

typedef NSString * MNContactLocalizedKey;
FOUNDATION_EXTERN MNContactLocalizedKey const MNContactLocalizedDataKey;
FOUNDATION_EXTERN MNContactLocalizedKey const MNContactLocalizedIndexedKey;

@interface MNLabeledValue : NSObject
@property (nonatomic, copy) NSString *label;
@property (nonatomic, strong) id value;
@end

@interface MNContact : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *givenName;
@property (nonatomic, copy) NSString *familyName;
@property (nonatomic, copy) NSString *middleName;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *namePrefix;
@property (nonatomic, copy) NSString *nameSuffix;
@property (nonatomic, copy) NSString *givenNamePhonetic;
@property (nonatomic, copy) NSString *familyNamePhonetic;
@property (nonatomic, copy) NSString *middleNamePhonetic;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *job;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, copy) NSData *imageData;
@property (nonatomic, copy) NSData *thumbnailImageData;
@property (nonatomic, copy) NSArray <MNLabeledValue *>*phones;
@property (nonatomic, copy) NSArray <MNLabeledValue *>*emails;
@property (nonatomic, copy) NSArray <MNLabeledValue *>*dates;
@end

typedef void(^MNContactFetchHandler)(NSArray <MNContact *>*contacts);

@interface MNAddressBook : NSObject

/**
 获取联系人列表
 @param handler 回调处理
 */
+ (void)fetchContactsWithCompletionHandler:(MNContactFetchHandler)handler;

/**
 联系人排序后的数组
 @param contacts 联系人数组<乱序>
 @param sortKey 获取排序属性的方法字符串
 @return 排序后的联系人数组
 */
+ (NSArray <NSDictionary <MNContactLocalizedKey, id>*>*)localizedIndexedContacts:(NSArray *)contacts sortKey:(NSString *)sortKey;

/**
请求权限
@param handler 请求回调
*/
+ (void)requestAuthorizationStatusWithHandler:(void(^)(BOOL allowed))handler;

@end
