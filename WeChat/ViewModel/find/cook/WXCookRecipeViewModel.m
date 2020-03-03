//
//  WXCookRecipeViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRecipeViewModel.h"

@interface WXCookRecipeViewModel ()

@end

@implementation WXCookRecipeViewModel
- (instancetype)initWithRecipeModel:(WXCookRecipe *)model {
    if (self = [super init]) {
        self.model = model;
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)loadData {
    if (self.prepareLoadDataHandler) {
        self.prepareLoadDataHandler();
    }
    dispatch_async_default(^{
        NSMutableArray <WXCookMethodViewModel *>*dataSource = [NSMutableArray arrayWithCapacity:self.model.methods.count];
        [self.model.methods enumerateObjectsUsingBlock:^(WXCookMethod * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            WXCookMethodViewModel *viewModel = [[WXCookMethodViewModel alloc] initWithMethod:obj];
            [dataSource addObject:viewModel];
        }];
        dispatch_async_main(^{
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dataSource.copy];
            if (self.reloadTableHandler) {
                self.reloadTableHandler();
            }
            if (self.didLoadDataHandler) {
                self.didLoadDataHandler();
            }
        });
    });
}

- (NSArray <UIImage *>*)shareImages {
    NSMutableArray <UIImage *>*images = [NSMutableArray arrayWithCapacity:0];
    UIImage *image = [UIImage imageWithObject:self.model.img];
    if (image) [images addObject:image];
    [self.model.methods enumerateObjectsUsingBlock:^(WXCookMethod * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *img = [UIImage imageWithObject:obj.img];
        if (img) [images addObject:img];
    }];
    return images.copy;
}

@end
