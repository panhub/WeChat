//
//  WXCardMessageCell.m
//  MNChat
//
//  Created by Vincent on 2020/1/21.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXCardMessageCell.h"
#import "WXCardMessageViewModel.h"

@interface WXCardMessageCell ()
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@end

@implementation WXCardMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.image = [UIImage imageWithColor:[UIColor whiteColor]];
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        UIImageView *avatarView = [[UIImageView alloc] init];
        avatarView.clipsToBounds = YES;
        avatarView.layer.cornerRadius = 4.f;
        avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self.imgView addSubview:avatarView];
        self.avatarView = avatarView;
        
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.userInteractionEnabled = NO;
        [self.titleLabel removeFromSuperview];
        [self.imgView addSubview:self.titleLabel];
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.userInteractionEnabled = NO;
        [self.detailLabel removeFromSuperview];
        [self.imgView addSubview:self.detailLabel];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
        separator.backgroundColor = SEPARATOR_COLOR;
        [self.imgView addSubview:separator];
        self.separator = separator;
        
        UILabel *typeLabel = [UILabel labelWithFrame:CGRectZero
                                                text:@"个人名片"
                                           textColor:UIColorWithAlpha(UIColor.darkGrayColor, .5f)
                                                font:[UIFont systemFontOfSize:12.f]];
        [typeLabel sizeToFit];
        typeLabel.height_mn = typeLabel.font.pointSize;
        [self.imgView addSubview:typeLabel];
        self.typeLabel = typeLabel;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    WXCardMessageViewModel *vm = (WXCardMessageViewModel *)viewModel;
    
    self.imgView.frame = vm.imageViewModel.frame;
    
    self.avatarView.frame = vm.avatarViewModel.frame;
    self.avatarView.image = vm.avatarViewModel.content;
    
    self.titleLabel.frame = vm.textLabelModel.frame;
    self.titleLabel.attributedText = vm.textLabelModel.content;
    
    self.detailLabel.frame = vm.detailLabelModel.frame;
    self.detailLabel.attributedText = vm.detailLabelModel.content;
    
    self.separator.frame = vm.separatorViewModel.frame;
    
    self.typeLabel.frame = vm.typeLabelModel.frame;
    self.typeLabel.attributedText = vm.typeLabelModel.content;
    
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
