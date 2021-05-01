//
//  WXYearViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXYearViewModel.h"
#import "WXAlbum.h"

@interface WXYearViewModel ()
@property (nonatomic, strong) NSMutableArray <WXMonthViewModel *>*dataSource;
@end

@implementation WXYearViewModel
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
            
            self.headerHeight = 77.f;
            
            NSString *title = [year stringByAppendingString:@"年"];
            
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:title];
            [string addAttribute:NSFontAttributeName value:WXAlbumTextFont range:string.rangeOfAll];
            [string addAttribute:NSForegroundColorAttributeName value:WXAlbumTextColor range:string.rangeOfAll];
            
            CGSize size = [string sizeOfLimitWidth:MN_SCREEN_MIN];
            
            WXExtendViewModel *yearViewModel = WXExtendViewModel.new;
            yearViewModel.frame = CGRectMake(WXAlbumMonthLeftMargin, self.headerHeight - ceil(size.height) - 17.f, ceil(size.width), ceil(size.height));
            yearViewModel.content = string.copy;
            self.yearViewModel = yearViewModel;
        }
    }
    return self;
}

- (void)addMoment:(WXMoment *)moment {
    NSString *month = [[NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"][1];
    NSArray <WXMonthViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@", month]];
    WXMonthViewModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        viewModel = [[WXMonthViewModel alloc] initWithTimestamp:moment.timestamp];
        viewModel.touchEventHandler = self.touchEventHandler;
        [self.dataSource addObject:viewModel];
    }
    [viewModel.pictures addObjectsFromArray:moment.profiles];
    [viewModel layoutSubviews];
}

- (void)insertMoment:(WXMoment *)moment {
    NSString *month = [[NSDate stringValueWithTimestamp:moment.timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"][1];
    NSArray <WXMonthViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@", month]];
    WXMonthViewModel *viewModel;
    if (result.count) {
        viewModel = result.lastObject;
    } else {
        viewModel = [[WXMonthViewModel alloc] initWithTimestamp:moment.timestamp];
        viewModel.touchEventHandler = self.touchEventHandler;
        NSArray <WXMonthViewModel *>*months = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month < %@", month]];
        [self.dataSource insertObject:viewModel atIndex:(months.count ? [self.dataSource indexOfObject:months.firstObject] : 0)];
    }
    NSArray <WXProfile *>*pictures = [viewModel.pictures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.timestamp < %@", moment.profiles.firstObject.timestamp]];
    [viewModel.pictures insertObjects:moment.profiles fromIndex:(pictures.count ? [viewModel.pictures indexOfObject:pictures.firstObject] : 0)];
    [viewModel.dataSource removeAllObjects];
    [viewModel layoutSubviews];
}

- (BOOL)del:(WXProfile *)picture {
    NSString *month = [[NSDate stringValueWithTimestamp:picture.timestamp format:@"yyyy-M-d"] componentsSeparatedByString:@"-"][1];
    NSArray <WXMonthViewModel *>*result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.month == %@", month]];
    if (result.count <= 0) return NO;
    WXMonthViewModel *vm = result.lastObject;
    __block WXProfile *pic;
    [vm.pictures enumerateObjectsUsingBlock:^(WXProfile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToProfile:picture]) {
            pic = obj;
            *stop = YES;
        }
    }];
    if (pic) {
        [vm.pictures removeObject:pic];
        [vm.dataSource removeAllObjects];
        [vm layoutSubviews];
        if (vm.dataSource.count <= 0) [self.dataSource removeObject:vm];
        return YES;
    }
    return NO;
}

@end
