//
//  WXCookRecipeHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/6/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRecipeHeaderView.h"
#import "WXCookModel.h"

@interface WXCookRecipeHeaderView ()
@property (nonatomic, strong) WXCookRecipe *model;
@end

@implementation WXCookRecipeHeaderView
+ (instancetype)headerWithRecipeModel:(WXCookRecipe *)model {
    WXCookRecipeHeaderView *headerView = [[WXCookRecipeHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, MN_SCREEN_WIDTH, 0.f)];
    headerView.userInteractionEnabled = YES;
    [headerView.imageView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
    headerView.model = model;
    return headerView;
}

- (void)setModel:(WXCookRecipe *)model {
    _model = model;
    @weakify(self);
    [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:model.img] options:kNilOptions progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self);
        if (!image) image = [UIImage imageNamed:@"cook_banner-4"];
        CGSize size = image.size;
        if (size.height > size.width) {
            image = [image cropImageInRect:CGRectMake(0.f, MEAN(size.height - size.width), size.width, size.width)];
        }
        size = CGSizeMultiplyToWidth(image.size, self.width_mn);
        self.height_mn = size.height;
        self.imageView.image = image;
        if (self.didLoadHandler) {
            self.didLoadHandler(self);
        }
    }];
}

- (void)handTap:(UITapGestureRecognizer *)recognizer {
    if (![recognizer.view isKindOfClass:UIImageView.class]) return;
    UIImageView *imageView = (UIImageView *)(recognizer.view);
    if (!imageView.image) return;
    MNAsset *assent = [MNAsset assetWithContent:imageView.image];
    assent.containerView = imageView;
    MNAssetBrowser *browser = [MNAssetBrowser new];
    browser.assets = @[assent];
    browser.backgroundColor = UIColor.blackColor;
    [browser presentInView:self.viewController.view fromIndex:0 animated:YES completion:nil];
}

@end
