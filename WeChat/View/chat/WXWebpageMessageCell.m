//
//  WXWebpageMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/21.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXWebpageMessageCell.h"
#import "WXWebpageMessageViewModel.h"

@interface WXWebpageMessageCell ()
@property (nonatomic, strong) UIImageView *thumbnailView;
@end

@implementation WXWebpageMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.userInteractionEnabled = NO;
        //self.detailLabel.backgroundColor = [UIColor yellowColor];
        [self.detailLabel removeFromSuperview];
        [self.imgView addSubview:self.detailLabel];
        
        self.imgView.image = [UIImage imageWithColor:[UIColor whiteColor]];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *thumbnailView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        //thumbnailView.layer.borderColor = [[UIColor darkTextColor] CGColor];
        //thumbnailView.layer.borderWidth = 1.f;
        [self.imgView addSubview:thumbnailView];
        self.thumbnailView = thumbnailView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    WXWebpageMessageViewModel *vm = (WXWebpageMessageViewModel *)viewModel;
    
    self.imgView.frame = vm.imageViewModel.frame;
    
    self.titleLabel.frame = vm.textLabelModel.frame;
    self.titleLabel.attributedText = vm.textLabelModel.content;
    
    self.detailLabel.frame = vm.detailLabelModel.frame;
    self.detailLabel.attributedText = vm.detailLabelModel.content;
    
    self.thumbnailView.frame = vm.thumbnailViewModel.frame;
    self.thumbnailView.image = vm.thumbnailViewModel.content;
    
    self.maskImageView.frame = (CGRect){CGPointZero, viewModel.imageViewModel.frame.size};
    self.maskImageView.image = viewModel.borderModel.content;
    self.imgView.layer.mask = self.maskImageView.layer;
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
