//
//  WXLocationMessageCell.m
//  WeChat
//
//  Created by Vincent on 2019/5/19.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocationMessageCell.h"
#import "WXLocationMessageViewModel.h"

@interface WXLocationMessageCell ()
@property (nonatomic, strong) UIImageView *locationView;
@end

@implementation WXLocationMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.image = [UIImage imageWithColor:[UIColor whiteColor]];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.userInteractionEnabled = NO;
        [self.detailLabel removeFromSuperview];
        [self.imgView addSubview:self.detailLabel];
        
        UIImageView *locationView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        [self.imgView addSubview:locationView];
        self.locationView = locationView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    WXLocationMessageViewModel *vm = (WXLocationMessageViewModel *)viewModel;
    
    self.imgView.frame = vm.imageViewModel.frame;
    
    self.titleLabel.frame = vm.textLabelModel.frame;
    self.titleLabel.attributedText = vm.textLabelModel.content;
    
    self.detailLabel.frame = vm.detailLabelModel.frame;
    self.detailLabel.attributedText = vm.detailLabelModel.content;
    
    self.locationView.frame = vm.locationViewModel.frame;
    self.locationView.image = vm.locationViewModel.content;
    
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
