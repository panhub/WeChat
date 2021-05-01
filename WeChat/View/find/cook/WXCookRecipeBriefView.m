//
//  WXCookRecipeBriefView.m
//  WeChat
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRecipeBriefView.h"
#import "WXCook.h"

@interface WXCookRecipeBriefView ()
@property (nonatomic, strong) WXCookRecipe *model;
@end

@implementation WXCookRecipeBriefView
+ (instancetype)viewWithRecipeModel:(WXCookRecipe *)model {
    WXCookRecipeBriefView *headerView = [[WXCookRecipeBriefView alloc] initWithFrame:CGRectMake(0.f, 0.f, MN_SCREEN_WIDTH, 0.f)];
    headerView.model = model;
    return headerView;
}

- (void)setModel:(WXCookRecipe *)model {
    _model = model;
    __block CGFloat height = 0.f;
    if (model.sumary.length) {
        NSMutableAttributedString *sumary = model.sumary.attributedString.mutableCopy;
        sumary.color = [UIColor darkTextColor];
        sumary.font = [UIFont systemFontOfSize:17.f];
        sumary.lineSpacing = 4.f;
        CGSize size = [sumary sizeOfLimitWidth:self.width_mn - 24.f];
        UILabel *sumaryLabel = [UILabel labelWithFrame:CGRectMake(12.f, 15.f, size.width, size.height) text:sumary alignment:NSTextAlignmentLeft textColor:nil font:nil];
        sumaryLabel.numberOfLines = 0;
        [self addSubview:sumaryLabel];
        height = sumaryLabel.bottom_mn;
    }
    [model.ingredients enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableAttributedString *ingredients = obj.attributedString.mutableCopy;
        ingredients.color = [[UIColor darkTextColor] colorWithAlphaComponent:.7f];
        ingredients.font = [UIFont systemFontOfSize:16.f];;
        ingredients.lineSpacing = 1.f;
        CGSize size = [ingredients sizeOfLimitWidth:self.width_mn - 24.f];
        UILabel *ingredientLabel = [UILabel labelWithFrame:CGRectMake(12.f, (idx == 0 ? (height + 15.f) : (height + 7.f)), size.width, size.height) text:ingredients alignment:NSTextAlignmentLeft textColor:nil font:nil];
        ingredientLabel.numberOfLines = 0;
        [self addSubview:ingredientLabel];
        height = ingredientLabel.bottom_mn;
    }];
    self.height_mn = height + 15.f;
}

@end
