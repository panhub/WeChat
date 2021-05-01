//
//  WXMyMomentYearModel.m
//  WeChat
//
//  Created by Vicent on 2021/4/18.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXMyMomentYearModel.h"
#import "WXMyMomentViewModel.h"
#import "WXMoment.h"
#import "WXMyMoment.h"

@interface WXMyMomentYearModel ()
@property (nonatomic, strong) NSMutableArray <WXMyMomentViewModel *>*dataSource;
@end

@implementation WXMyMomentYearModel
- (instancetype)init {
    if (self = [super init]) {
        self.dataSource = @[].mutableCopy;
    }
    return self;
}

- (instancetype)initWithYear:(NSString *)year {
    if (self = [self init]) {
        self.year = year;
        
        NSString *date = [NSDate stringValueWithTimestamp:NSDate.date format:@"yyyy"];
        
        if (year.integerValue != date.integerValue) {
            
            self.headerHeight = 100.f;
            
            NSString *title = [year stringByAppendingString:@"年"];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
            [string addAttribute:NSFontAttributeName value:WXMyMomentYearFont range:string.rangeOfAll];
            [string addAttribute:NSForegroundColorAttributeName value:WXMyMomentYearTextColor range:string.rangeOfAll];
            
            CGSize size = [string sizeOfLimitWidth:MN_SCREEN_MIN];
            
            WXExtendViewModel *yearViewModel = WXExtendViewModel.new;
            yearViewModel.frame = CGRectMake(WXMyMomentLeftMargin, self.headerHeight - ceil(size.height) - 28.f, ceil(size.width), ceil(size.height));
            yearViewModel.content = string.copy;
            self.yearViewModel = yearViewModel;
        }
    }
    return self;
}

- (void)addMoment:(WXMoment *)moment {
    WXMyMomentViewModel *viewModel = [[WXMyMomentViewModel alloc] initWithMoment:moment];
    NSArray <WXMyMomentViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@ && self.day == %@", viewModel.month, viewModel.day]];
    [result setValue:@(NO) forKey:sql_field(viewModel.last)];
    viewModel.last = YES;
    viewModel.first = result.count <= 0;
    viewModel.touchEventHandler = self.touchEventHandler;
    [viewModel layoutSubviews];
    if (result.count) {
        // 更新位置
        WXMyMomentViewModel *vm = result.firstObject;
        if (vm.moment.location.length <= 0 && moment.location.length) {
            vm.moment.location = moment.location;
            [vm layoutSubviews];
        }
        // 插入到指定位置
        [self.dataSource insertObject:viewModel atIndex:[self.dataSource indexOfObject:result.lastObject] + 1];
    } else {
        // 往后添加
        [self.dataSource addObject:viewModel];
    }
}

- (void)insertMoment:(WXMoment *)moment {
    WXMyMomentViewModel *viewModel = [[WXMyMomentViewModel alloc] initWithMoment:moment];
    NSArray <WXMyMomentViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@ && self.day == %@", viewModel.month, viewModel.day]];
    NSArray <WXMyMomentViewModel *>*news = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.moment.isNewMoment == YES"]];
    if (news.count) {
        // 通常到这里
        news.lastObject.last = NO;
        viewModel.last = result.count == news.count;
        [self.dataSource insertObject:viewModel atIndex:[self.dataSource indexOfObject:news.lastObject] + 1];
        WXMyMomentViewModel *vm = news.firstObject;
        if (vm.moment.location.length <= 0 && moment.location.length) {
            vm.moment.location = moment.location;
            [vm layoutSubviews];
        }
    } else {
        // 插入到起始位置
        viewModel.first = YES;
        if (result.count) {
            NSArray <WXMyMomentViewModel *>*firsts = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.first == YES"]];
            if (firsts.count) {
                [firsts setValue:@(NO) forKey:sql_field(viewModel.first)];
                [firsts makeObjectsPerformSelector:@selector(layoutSubviews)];
            }
            if (moment.location.length <= 0) {
                [result enumerateObjectsUsingBlock:^(WXMyMomentViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.moment.location.length) {
                        moment.location = obj.moment.location;
                        *stop = YES;
                    }
                }];
            }
            [self.dataSource insertObject:viewModel atIndex:[self.dataSource indexOfObject:result.firstObject]];
        } else {
            viewModel.first = YES;
            viewModel.last = YES;
            NSArray <WXMyMomentViewModel *>*vms = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.moment.timestamp < %@", moment.timestamp]];
            [self.dataSource insertObject:viewModel atIndex:(vms.count ? [self.dataSource indexOfObject:vms.firstObject] : 0)];
        }
    }
    viewModel.touchEventHandler = self.touchEventHandler;
    [viewModel layoutSubviews];
}

- (BOOL)del:(WXProfile *)picture {
    NSArray <NSString *>*components = [[NSDate stringValueWithTimestamp:picture.timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"];
    NSString *month = components[1];
    NSString *day = components.lastObject;
    NSArray <WXMyMomentViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@ && self.day == %@", month, day]];
    if (result.count <= 0) return NO;
    NSArray <WXMyMomentViewModel *>*vms = [result filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.moment.identifier == %@", picture.moment]];
    if (vms.count <= 0) return NO;
    WXMyMomentViewModel *vm = vms.lastObject;
    // 操作朋友圈
    WXMoment *moment = vm.moment;
    // 删除图片后
    [moment.profiles.copy enumerateObjectsUsingBlock:^(WXProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToProfile:picture]) {
            [moment.profiles removeObject:obj];
            *stop = YES;
        }
    }];
    if (moment.profiles.count <= 0 && moment.content.length <= 0) {
        // 删除视图模型及朋友圈
        if (result.count > 1) {
            NSInteger index = [result indexOfObject:vm];
            if (index == 0) {
                result[1].first = YES;
                [result[1] layoutSubviews];
            } else if (index == result.count - 1) {
                result[result.count - 2].last = YES;
            }
        }
        [self.dataSource removeObject:vm];
    } else {
        // 更新视图模型及朋友圈
        [vm layoutSubviews];
    }
    [moment cleanMemory];
    return YES;
}

@end
