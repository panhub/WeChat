//
//  WXAlbumProfileViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumProfileViewModel.h"
#import "WXMoment.h"

@interface WXAlbumProfileViewModel ()
{
    NSMutableDictionary <NSNumber *, NSMutableArray *>*album_year_dictionary;
    NSMutableDictionary <NSNumber *, NSMutableArray *>*album_month_dictionary;
}
@end

@implementation WXAlbumProfileViewModel
- (instancetype)init {
    if (self = [super init]) {
        album_year_dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
        album_month_dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return self;
}

#pragma mark - 加载相册
- (void)loadData {
    [MNDatabase selectRowsModelFromTable:WXMomentTableName class:WXMoment.class completion:^(NSArray<WXMoment *> * _Nonnull rows) {
        [self sortAlbumWithMoments:rows];
    }];
}

- (void)sortAlbumWithMoments:(NSArray<WXMoment *> *)moments {
    dispatch_async_default(^{
        [album_year_dictionary.allValues makeObjectsPerformSelector:@selector(removeAllObjects)];
        /// 对朋友圈按年份分类
        [moments enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.pictures.count <= 0) return;
            NSString *year = [NSDate dateStringWithTimestamp:obj.timestamp format:@"yyyy"];
            if (year.length <= 0) return;
            [[self arrayWithYear:year.unsignedIntegerValue] addObject:obj];
        }];
        /// 对朋友圈按月份分类
        NSMutableArray <WXAlbumViewModel *>*dataSource = [NSMutableArray arrayWithCapacity:5];
        [[self valuesSortedByDictionary:album_year_dictionary] enumerateObjectsUsingBlock:^(NSArray <WXMoment *>*array, NSUInteger idx, BOOL * _Nonnull stop) {
            WXMoment *moment = [array firstObject];
            NSString *year = [NSDate dateStringWithTimestamp:moment.timestamp format:@"yyyy"];
            [album_month_dictionary.allValues makeObjectsPerformSelector:@selector(removeAllObjects)];
            [array enumerateObjectsUsingBlock:^(WXMoment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *month = [NSDate dateStringWithTimestamp:obj.timestamp format:@"MM"];
                if (month.length <= 0) return;
                [[self arrayWithMonth:month.unsignedIntegerValue] addObjectsFromArray:obj.pictures];
            }];
            NSArray <NSNumber *>*keys = [self keysSortedByDictionary:album_month_dictionary];
            [keys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *value = [album_month_dictionary objectForKey:key];
                if (value.count > 0) {
                    WXAlbumViewModel *viewModel = [[WXAlbumViewModel alloc] initWithPictures:value];
                    viewModel.year = year;
                    viewModel.month = key.stringValue;
                    viewModel.date = [year stringByAppendingFormat:@"/%@", key.stringValue];
                    [dataSource addObject:viewModel];
                }
            }];
        }];
        self.dataSource = dataSource.copy;
        dispatch_async_main(^{
            if (self.reloadTableHandler) {
                self.reloadTableHandler();
            }
        });
    });
}

#pragma mark - Getter
- (NSMutableArray *)arrayWithYear:(NSUInteger)year {
    NSMutableArray *array = [album_year_dictionary objectForKey:@(year)];
    if (!array) {
        array = [NSMutableArray arrayWithCapacity:0];
        [album_year_dictionary setObject:array forKey:@(year)];
    }
    return array;
}

- (NSMutableArray *)arrayWithMonth:(NSUInteger)month {
    NSMutableArray *array = [album_month_dictionary objectForKey:@(month)];
    if (!array) {
        array = [NSMutableArray arrayWithCapacity:0];
        [album_month_dictionary setObject:array forKey:@(month)];
    }
    return array;
}

#pragma mark - 字典排序
- (NSArray <NSNumber *>*)keysSortedByDictionary:(NSDictionary <NSNumber *, NSArray *>*)dic {
    return [[[dic allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }] reverseObjects];
}

- (NSArray <NSArray *>*)valuesSortedByDictionary:(NSDictionary <NSNumber *, NSArray *>*)dic {
    NSArray <NSNumber *>*keys = [self keysSortedByDictionary:dic];
    NSMutableArray <NSArray *>*values = [NSMutableArray arrayWithCapacity:keys.count];
    [keys enumerateObjectsUsingBlock:^(NSNumber * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *value = [dic objectForKey:key];
        if (value.count > 0) [values addObject:value];
    }];
    return values.copy;
}

@end
