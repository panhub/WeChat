//
//  WXCookRecipeCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCookRecipeCell.h"

@implementation WXCookRecipeCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    return [self cellWithTableView:tableView style:UITableViewCellStyleDefault];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style {
    WXCookRecipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.cook.recipe.cell.id"];
    if (!cell) {
        cell = [[WXCookRecipeCell alloc] initWithStyle:style reuseIdentifier:@"com.wx.cook.recipe.cell.id"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.titleLabel.numberOfLines = 0;
        
        self.imgView.clipsToBounds = YES;
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.userInteractionEnabled = YES;
        [self.imgView addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTap:), nil)];
    }
    return self;
}

- (void)setViewModel:(WXCookMethodViewModel *)viewModel {
    _viewModel = viewModel;
    self.imgView.frame = viewModel.imageViewFrame;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:viewModel.img]];
    self.titleLabel.frame = viewModel.textLabelFrame;
    self.titleLabel.attributedText = viewModel.attributedString;
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
    [browser presentInView:self.viewController.view fromAsset:assent animated:YES completion:nil];
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
