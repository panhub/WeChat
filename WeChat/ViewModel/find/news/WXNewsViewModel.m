//
//  WXNewsViewModel.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsViewModel.h"
#import "WXNewsDataModel.h"
#import "WXExtendViewModel.h"

@implementation WXNewsViewModel
- (instancetype)initWithDataModel:(WXNewsDataModel *)dataModel {
    if (self = [super init]) {
        
        self.dataModel = dataModel;
        
        CGFloat x = 16.f;
        CGFloat y = 17.f;
        CGFloat maxW = MN_SCREEN_MIN - x*2.f;
        
        // 标题
        NSMutableAttributedString *title = dataModel.title.attributedString.mutableCopy;
        [title addAttribute:NSFontAttributeName value:UIFontRegular(17.f) range:title.rangeOfAll];
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor.darkTextColor colorWithAlphaComponent:.93f] range:title.rangeOfAll];
        CGSize titleSize = [title sizeOfLimitWidth:maxW];
        titleSize.width = maxW;
        CGRect titleFrame = CGRectZero;
        titleFrame.origin = CGPointMake(x, y);
        titleFrame.size = titleSize;
        WXExtendViewModel *titleViewModel = WXExtendViewModel.new;
        titleViewModel.frame = titleFrame;
        titleViewModel.content = title.copy;
        self.titleViewModel = titleViewModel;
        
        // 缩略图
        CGFloat m = 13.f;
        CGFloat w = floor((maxW - m*2.f)/3.f);
        CGFloat top = CGRectGetMaxY(titleViewModel.frame);
        CGFloat append = CGRectGetHeight(titleViewModel.frame) > 0.f ? 16.f : 0.f;
        NSMutableArray <WXExtendViewModel *>*imageViewModels = @[].mutableCopy;
        [UIView gridLayoutWithInitial:CGRectMake(x, 0.f, w, floor(w/3.f*2.f)) offset:UIOffsetMake(m, 0.f) count:dataModel.imgs.count rows:dataModel.imgs.count handler:^(CGRect rect, NSUInteger idx, BOOL * _Nonnull stop) {
            rect.origin.y = top + append;
            WXExtendViewModel *m = WXExtendViewModel.new;
            m.frame = rect;
            m.content = dataModel.imgs[idx];
            [imageViewModels addObject:m];
        }];
        self.imageViewModels = imageViewModels;
        
        WXExtendViewModel *vm = imageViewModels.count ? imageViewModels.firstObject : titleViewModel;
        
        // 作者
        NSMutableAttributedString *author = dataModel.author.attributedString.mutableCopy;
        [author addAttribute:NSFontAttributeName value:UIFontRegular(14.f) range:author.rangeOfAll];
        [author addAttribute:NSForegroundColorAttributeName value:[UIColor.darkGrayColor colorWithAlphaComponent:.75f] range:author.rangeOfAll];
        CGSize authorSize = [author sizeOfLimitWidth:maxW];
        CGRect authorFrame = CGRectZero;
        authorFrame.origin = CGPointMake(x, (CGRectGetMaxY(vm.frame) + (CGRectGetHeight(vm.frame) > 0.f ? 16.f : 0.f)));
        authorFrame.size = authorSize;
        WXExtendViewModel *authorViewModel = WXExtendViewModel.new;
        authorViewModel.frame = authorFrame;
        authorViewModel.content = author.copy;
        self.authorViewModel = authorViewModel;
        
        // 日期
        NSMutableAttributedString *date = dataModel.date.attributedString.mutableCopy;
        [date addAttribute:NSFontAttributeName value:UIFontRegular(14.f) range:date.rangeOfAll];
        [date addAttribute:NSForegroundColorAttributeName value:[UIColor.darkGrayColor colorWithAlphaComponent:.75f] range:date.rangeOfAll];
        CGSize dateSize = [date sizeOfLimitWidth:maxW];
        CGRect dateFrame = CGRectZero;
        dateFrame.origin = CGPointMake(x + maxW - dateSize.width, CGRectGetMidY(authorViewModel.frame) - dateSize.height/2.f);
        dateFrame.size = dateSize;
        WXExtendViewModel *dateViewModel = WXExtendViewModel.new;
        dateViewModel.frame = dateFrame;
        dateViewModel.content = date.copy;
        self.dateViewModel = dateViewModel;
        
        CGFloat rowHeight = MAX(CGRectGetMaxY(authorViewModel.frame), CGRectGetMaxY(dateViewModel.frame)) + y;
        self.rowHeight = ceil(rowHeight);
    }
    return self;
}

@end
