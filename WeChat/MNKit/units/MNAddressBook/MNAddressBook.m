//
//  MNAddressBook.m
//  MNKit
//
//  Created by Vincent on 2019/3/16.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAddressBook.h"
#import <AddressBook/AddressBook.h>
#if __has_include(<Contacts/Contacts.h>)
#import <Contacts/Contacts.h>
#endif

MNContactLocalizedKey const MNContactLocalizedDataKey = @"com.mn.contact.localized.data.key";
MNContactLocalizedKey const MNContactLocalizedIndexedKey = @"com.mn.contact.localized.indexed.key";

@implementation MNLabeledValue

@end

@implementation MNContact

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
@implementation MNAddressBook
#pragma mark - 请求联系人信息
+ (void)fetchContactsWithCompletionHandler:(MNContactFetchHandler)handler {
    [self requestAuthorizationStatusWithHandler:^(BOOL allowed) {
        if (allowed) {
            dispatch_queue_t queue = dispatch_queue_create("com.mn.address.book.queue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue, ^{
                if (UIDevice.currentDevice.systemVersion.floatValue >= 9.f) {
                    [self requestContactsWithHandler:handler];
                } else {
                    [self requestAddressBookWithHandler:handler];
                }
            });
        } else {
            if (handler) {
                handler(nil);
            }
        }
    }];
}

#pragma mark - iOS >= 9.0
+ (void)requestContactsWithHandler:(MNContactFetchHandler)handler {
    NSArray *keys = @[CNContactGivenNameKey, CNContactMiddleNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactNicknameKey, CNContactOrganizationNameKey, CNContactDepartmentNameKey, CNContactJobTitleKey, CNContactPhoneticGivenNameKey, CNContactPhoneticMiddleNameKey, CNContactPhoneticFamilyNameKey, CNContactBirthdayKey, CNContactImageDataKey, CNContactThumbnailImageDataKey, CNContactEmailAddressesKey, CNContactDatesKey, CNContactNamePrefixKey, CNContactNameSuffixKey, CNContactIdentifierKey]; //CNContactNoteKey
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    CNContactStore *contactStore = [CNContactStore new];
    NSMutableArray <MNContact *>*peopleArray = [NSMutableArray arrayWithCapacity:0];
    [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        MNContact *people = [MNContact new];
        people.identifier = contact.identifier;
        people.familyName = contact.familyName;
        people.givenName = contact.givenName;
        people.middleName = contact.middleName;
        people.name = [[people.familyName stringByAppendingString:people.middleName] stringByAppendingString:people.givenName];
        people.nickName = contact.nickname;
        people.familyNamePhonetic = contact.phoneticFamilyName;
        people.givenNamePhonetic = contact.phoneticGivenName;
        people.middleNamePhonetic = contact.phoneticMiddleName;
        people.namePrefix = contact.namePrefix;
        people.nameSuffix = contact.nameSuffix;
        people.organization = contact.organizationName;
        people.department = contact.departmentName;
        people.job = contact.jobTitle;
        people.birthday = contact.birthday.date;
        people.imageData = contact.imageData;
        people.thumbnailImageData = contact.thumbnailImageData;
        if (UIDevice.currentDevice.systemVersion.floatValue < 13.f) {
            people.note = contact.note ? : @"";
        }
        
        NSArray *phoneNumbers = contact.phoneNumbers;
        NSMutableArray <MNLabeledValue *>*phoneArray = [NSMutableArray arrayWithCapacity:phoneNumbers.count];
        for (CNLabeledValue *labeledValue in phoneNumbers) {
            CNPhoneNumber *number = labeledValue.value;
            NSString *value = number.stringValue;
            if (value.length <= 0) continue;
            NSString *label = labeledValue.label;
            MNLabeledValue *phone = [MNLabeledValue new];
            phone.label = label;
            phone.value = value;
            [phoneArray addObject:phone];
        }
        people.phones = phoneArray.copy;
        
        NSArray *emailAddresses = contact.emailAddresses;
        NSMutableArray <MNLabeledValue *>*emailArray = [NSMutableArray arrayWithCapacity:emailAddresses.count];
        for (CNLabeledValue *labeledValue in emailAddresses) {
            NSString *value = labeledValue.value;
            if (value.length <= 0) continue;
            NSString *label = labeledValue.label;
            MNLabeledValue *email = [MNLabeledValue new];
            email.label = label;
            email.value = value;
            [emailArray addObject:email];
        }
        people.emails = emailArray.copy;
        
        NSArray *dates = contact.dates;
        NSMutableArray <MNLabeledValue *>*dateArray = [NSMutableArray arrayWithCapacity:dates.count];
        for (CNLabeledValue *labeledValue in dateArray) {
            NSDateComponents *components = labeledValue.value;
            NSDate *value = components.date;
            if (!value) continue;
            NSString *label = labeledValue.label;
            MNLabeledValue *date = [MNLabeledValue new];
            date.label = label;
            date.value = value;
            [dateArray addObject:date];
        }
        people.dates = dateArray.copy;
        
        [peopleArray addObject:people];
    }];
    if (handler) {
        handler(peopleArray.copy);
    }
}

#pragma mark - iOS < 9.0
+ (void)requestAddressBookWithHandler:(MNContactFetchHandler)handler {
    ABAddressBookRef AddressBookRef = ABAddressBookCreate();
    CFArrayRef ArrayRef = ABAddressBookCopyArrayOfAllPeople(AddressBookRef);
    signed long count = CFArrayGetCount(ArrayRef);
    NSMutableArray <MNContact *>*peopleArray = [NSMutableArray arrayWithCapacity:count];
    for (int idx = 0; idx < count; idx++) {
        /// 创建联系人模型
        MNContact *people = [MNContact new];
        
        /// 联系人记录
        ABRecordRef RecordRef = CFArrayGetValueAtIndex(ArrayRef, idx);
        
        /// 父姓
        NSString *familyName = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonLastNameProperty);
        people.familyName = familyName;
        
        /// 母姓
        NSString *middleName = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonMiddleNameProperty);
        people.middleName = middleName;
        
        /// 名
        NSString *givenName = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonFirstNameProperty);
        people.givenName = givenName;
        
        /// 姓名<中国形式>
        people.name = [NSString stringWithFormat:@"%@%@", familyName, givenName];
        
        /// 昵称
        NSString *nickName = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonNicknameProperty);
        people.nickName = nickName;
        
        /// 前缀
        NSString *namePrefix = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonPrefixProperty);
        people.namePrefix = namePrefix;
        
        /// 后缀
        NSString *nameSuffix = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonSuffixProperty);
        people.nameSuffix = nameSuffix;
        
        /// 父姓拼音
        NSString *familyNamePhonetic = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonLastNamePhoneticProperty);
        people.familyNamePhonetic = familyNamePhonetic;
        
        /// 母姓拼音
        NSString *middleNamePhonetic = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonMiddleNamePhoneticProperty);
        people.middleNamePhonetic = middleNamePhonetic;
        
        /// 名拼音
        NSString *givenNamePhonetic = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonFirstNamePhoneticProperty);
        people.givenNamePhonetic = givenNamePhonetic;
        
        /// 公司
        NSString *organization = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonOrganizationProperty);
        people.organization = organization;
        
        /// 部门
        NSString *department = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonDepartmentProperty);
        people.department = department;
        
        /// 职位
        NSString *job = (__bridge NSString *)ABRecordCopyValue(RecordRef, kABPersonJobTitleProperty);
        people.job = job;
        
        /// 生日
        NSDate *birthday = (__bridge NSDate*)(ABRecordCopyValue(RecordRef, kABPersonBirthdayProperty));
        people.birthday = birthday;
        
        /// 备注
        NSString *note = (__bridge NSString*)(ABRecordCopyValue(RecordRef, kABPersonNoteProperty));
        people.note = note;
        
        /// 创建时间
        NSDate *creationDate = (__bridge NSDate*)(ABRecordCopyValue(RecordRef, kABPersonCreationDateProperty));
        people.creationDate = creationDate;
        
        /// 最近修改时间
        NSDate *modificationDate = (__bridge NSDate*)(ABRecordCopyValue(RecordRef, kABPersonModificationDateProperty));
        people.modificationDate = modificationDate;
        
        /// 头像图片
        NSData *imageData = (__bridge NSData*)(ABPersonCopyImageData(RecordRef));
        people.imageData = imageData;
        
        /// 小头像图片
        NSData *thumbnailImageData = (__bridge NSData*)(ABPersonCopyImageDataWithFormat(RecordRef, kABPersonImageFormatThumbnail));
        people.thumbnailImageData = thumbnailImageData;
        
        /// 电话号码
        ABMultiValueRef PhoneRef = ABRecordCopyValue(RecordRef, kABPersonPhoneProperty);
        signed long phone_count = ABMultiValueGetCount(PhoneRef);
        NSMutableArray <MNLabeledValue *>*phoneArray = [NSMutableArray arrayWithCapacity:phone_count];
        for (int i = 0; i < phone_count; i++) {
            NSString *value = (__bridge NSString *)ABMultiValueCopyValueAtIndex(PhoneRef, i);
            if (value.length <= 0) continue;
            NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(PhoneRef, i);
            MNLabeledValue *phone = [MNLabeledValue new];
            phone.label = label;
            phone.value = value;
            [phoneArray addObject:phone];
        }
        people.phones = phoneArray.copy;
        
        CFRelease(PhoneRef);
        
        /// 邮件
        ABMultiValueRef EmailRef = ABRecordCopyValue(RecordRef, kABPersonEmailProperty);
        signed long email_count = ABMultiValueGetCount(EmailRef);
        NSMutableArray <MNLabeledValue *>*emailArray = [NSMutableArray arrayWithCapacity:email_count];
        for (int j = 0; j < email_count; j++) {
            NSString *value = (__bridge NSString *)ABMultiValueCopyValueAtIndex(EmailRef, j);
            if (value.length <= 0) return;
            NSString *label = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(EmailRef, j);
            MNLabeledValue *email = [MNLabeledValue new];
            email.label = label;
            email.value = value;
            [emailArray addObject:email];
        }
        people.emails = emailArray.copy;
        
        CFRelease(EmailRef);
        
        /// 纪念日
        ABMultiValueRef DateRef = ABRecordCopyValue(RecordRef, kABPersonDateProperty);
        signed long date_count = ABMultiValueGetCount(DateRef);
        NSMutableArray <MNLabeledValue *>*dateArray = [NSMutableArray arrayWithCapacity:date_count];
        for (int d = 0; d < date_count; d++) {
            NSDate *value = (__bridge NSDate*)ABMultiValueCopyValueAtIndex(DateRef, d);
            if (!value) continue;
            NSString *label = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(DateRef, d);
            MNLabeledValue *date = [MNLabeledValue new];
            date.label = label;
            date.value = value;
            [dateArray addObject:date];
        }
        people.dates = dateArray.copy;
        
        CFRelease(DateRef);
        
        CFRelease(RecordRef);
        
        [peopleArray addObject:people];
    }
    CFRelease(ArrayRef);
    CFRelease(AddressBookRef);
    if (handler) {
        handler(peopleArray.copy);
    }
}

#pragma mark - 联系人排序
+ (NSArray <NSDictionary <MNContactLocalizedKey, id>*>*)localizedIndexedContacts:(NSArray *)contacts sortKey:(NSString *)sortKey
{
    if (contacts.count <= 0 || sortKey.length <= 0) return nil;
    SEL sel = NSSelectorFromString(sortKey);
    if (!sel) return nil;
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger count = [[collation sectionTitles] count];
    NSMutableArray <NSMutableDictionary <MNContactLocalizedKey, id>*>*sections = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSInteger index = 0; index < count; index++) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        dic[MNContactLocalizedDataKey] = array;
        dic[MNContactLocalizedIndexedKey] = @"";
        [sections addObject:dic];
    }
    
    /// 对联系人分类
    for (id model in contacts) {
        if (![model respondsToSelector:sel]) continue;
        NSInteger number = [collation sectionForObject:model collationStringSelector:sel];
        if (sections.count <= number) continue;
        NSString *title = collation.sectionTitles[number];
        NSMutableDictionary *section = sections[number];
        section[MNContactLocalizedIndexedKey] = title;
        [section[MNContactLocalizedDataKey] addObject:model];
    }
    
    /// 对已分类的联系人排序并祛除空数组
    NSMutableArray *emptyArray = [NSMutableArray arrayWithCapacity:0];
    [sections enumerateObjectsUsingBlock:^(NSMutableDictionary<MNContactLocalizedKey, id> * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = section[MNContactLocalizedDataKey];
        NSString *key = section[MNContactLocalizedIndexedKey];
        if (array.count <= 0 || key.length <= 0) {
            [emptyArray addObject:section];
        } else {
            NSArray *sortedArray = [collation sortedArrayFromArray:array collationStringSelector:sel];
            section[MNContactLocalizedDataKey] = [NSMutableArray arrayWithArray:sortedArray];
        }
    }];
    [sections removeObjectsInArray:emptyArray];
    
    return sections.copy;
}

+ (NSArray *)SortFirstChar:(NSArray *)firstChararry {
    
    //数组去重复
    
    NSMutableArray *noRepeat = [[NSMutableArray alloc]initWithCapacity:8];
    
    NSMutableSet *set = [[NSMutableSet alloc]initWithArray:firstChararry];
    
    [set enumerateObjectsUsingBlock:^(id obj , BOOL *stop){
        
        
        [noRepeat addObject:obj];
        
    }];
    
    //字母排序
    NSArray *resultkArrSort1 = [noRepeat sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    //把”#“放在最后一位
    NSMutableArray *resultkArrSort2 = [[NSMutableArray alloc]initWithArray:resultkArrSort1];
    if ([resultkArrSort2 containsObject:@"#"]) {
        [resultkArrSort2 removeObject:@"#"];
        [resultkArrSort2 addObject:@"#"];
    }
    return resultkArrSort2;
}

#pragma mark - 权限查询
+ (void)requestAuthorizationStatusWithHandler:(void(^)(BOOL allowed))handler {
    if (UIDevice.currentDevice.systemVersion.floatValue >= 9.f) {
        if (@available(iOS 9.0, *)) {
            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            if (status == CNAuthorizationStatusNotDetermined) {
                __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
                [[CNContactStore new] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (isMainThread) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (handler) handler(granted);
                        });
                    } else {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            if (handler) handler(granted);
                        });
                    }
                }];
            } else {
                if (handler) handler(status == CNAuthorizationStatusAuthorized);
            }
        } else {
            if (handler) handler(NO);
        }
    } else {
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        if (status == kABAuthorizationStatusNotDetermined) {
            __block BOOL isMainThread = [[NSThread currentThread] isMainThread];
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (isMainThread) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (handler) handler(granted);
                    });
                } else {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        if (handler) handler(granted);
                    });
                }
            });
        } else {
            if (handler) handler(status == kABAuthorizationStatusAuthorized);
        }
    }
}

@end
#pragma clang diagnostic pop
