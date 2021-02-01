//
//  WXCookSort.h
//  MNChat
//
//  Created by Vincent on 2019/6/19.
//  Copyright © 2019 Vincent. All rights reserved.
//  菜谱类别

#import <Foundation/Foundation.h>

@interface WXCookMenu : NSObject
/**ID*/
@property (nonatomic, strong) NSString *cid;
/**标题*/
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *parent;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end

@interface WXCookSort : NSObject
/**ID*/
@property (nonatomic, copy) NSString *cid;
/**标题*/
@property (nonatomic, copy) NSString *title;
/**菜单*/
@property (nonatomic, copy) NSArray <WXCookMenu *>*list;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *parent;
@property (nonatomic, strong) NSArray <WXCookMenu *>*sorts;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end
