//
//  WXNewsCell.m
//  WeChat
//
//  Created by Vicent on 2021/1/31.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXNewsCell.h"
#import "WXNewsViewModel.h"
#import "WXExtendViewModel.h"
#import "UIImageView+WebCache.h"

@interface WXNewsCell ()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, copy) NSArray <UIImageView *>*imageViews;
@end

@implementation WXNewsCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = UIColor.whiteColor;
        self.contentView.backgroundColor = UIColor.whiteColor;
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.autoresizingMask = UIViewAutoresizingNone;
        
        self.detailLabel.numberOfLines = 1;
        
        UILabel *dateLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        dateLabel.numberOfLines = 1;
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        NSMutableArray <UIImageView *>*imageViews = @[].mutableCopy;
        for (NSInteger idx = 0; idx < 3; idx++) {
            UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
            imageView.tag = idx;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.layer.cornerRadius = 4.f;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(imageViewTouchUpInside:), nil)];
            [self.contentView addSubview:imageView];
            [imageViews addObject:imageView];
        }
        self.imageViews = imageViews;
        
        UIView *separator = UIView.new;
        separator.width_mn = self.contentView.width_mn;
        separator.height_mn = MN_IS_LOW_SCALE ? 1.f : .7f;
        separator.bottom_mn = self.contentView.height_mn;
        separator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        separator.backgroundColor = [UIColor.grayColor colorWithAlphaComponent:.15f];
        [self.contentView addSubview:separator];
        self.separator = separator;
    }
    return self;
}

- (void)setViewModel:(WXNewsViewModel *)viewModel {
    _viewModel = viewModel;
    
    self.titleLabel.frame = viewModel.titleViewModel.frame;
    self.titleLabel.attributedText = viewModel.titleViewModel.content;
    
    self.detailLabel.frame = viewModel.authorViewModel.frame;
    self.detailLabel.attributedText = viewModel.authorViewModel.content;
    
    self.dateLabel.frame = viewModel.dateViewModel.frame;
    self.dateLabel.attributedText = viewModel.dateViewModel.content;
    
    [self.imageViews setValue:@(YES) forKey:@"hidden"];
    [viewModel.imageViewModels enumerateObjectsUsingBlock:^(WXExtendViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIImageView *imageView = self.imageViews[idx];
        imageView.frame = obj.frame;
        imageView.hidden = NO;
        [imageView sd_setImageWithURL:[NSURL URLWithString:obj.content] placeholderImage:nil];
    }];
}

- (void)imageViewTouchUpInside:(UITapGestureRecognizer *)recognizer {
    UIImageView *imageView = (UIImageView *)recognizer.view;
    if (!imageView.image) return;
    NSArray <UIImageView *>*result = [self.imageViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.hidden == NO && self.image != nil"]];
    if (result.count <= 0 || ![result containsObject:imageView]) return;
    NSMutableArray <MNAsset *>*assets = @[].mutableCopy;
    [result enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MNAsset *m = MNAsset.new;
        m.thumbnail = obj.image;
        m.content = obj.image;
        m.type = MNAssetTypePhoto;
        m.containerView = obj;
        [assets addObject:m];
    }];
    MNAssetBrowser *browser = [[MNAssetBrowser alloc] initWithAssets:assets];
    browser.statusBarHidden = NO;
    browser.backgroundColor = UIColor.blackColor;
    browser.statusBarStyle = UIStatusBarStyleLightContent;
    [browser presentFromIndex:[result indexOfObject:imageView] animated:YES];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
