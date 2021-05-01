//
//  WXShakeSetingCell.m
//  WeChat
//
//  Created by Vincent on 2020/2/1.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "WXShakeSetingCell.h"
#import "WXDataValueModel.h"

@interface WXShakeSetingCell ()
@property (nonatomic, strong) UISwitch *switchButton;
@end

@implementation WXShakeSetingCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.left_mn = 15.f;
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        self.imgView.image = UIImageNamed(@"wx_common_list_arrow");
        self.imgView.size_mn = CGSizeMultiplyToWidth(self.imgView.image.size, 25.f);
        self.imgView.centerY_mn = self.contentView.height_mn/2.f;
        self.imgView.right_mn = self.contentView.width_mn - self.titleLabel.left_mn;
        
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
        switchButton.right_mn = self.imgView.right_mn;
        switchButton.centerY_mn = self.contentView.height_mn/2.f;
        switchButton.userInteractionEnabled = YES;
        switchButton.tintColor = [UIColor whiteColor];
        switchButton.onTintColor = THEME_COLOR;
        UIViewSetBorderRadius(switchButton, MEAN(switchButton.height_mn), 2.f, VIEW_COLOR);
        [switchButton addTarget:self action:@selector(switchButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switchButton];
        self.switchButton = switchButton;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

#pragma mark - Setter
- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.height_mn = self.titleLabel.font.pointSize;
    self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
    self.imgView.hidden = model.desc.boolValue;
    self.switchButton.hidden = [model.userInfo boolValue];
    [self.switchButton setOn:[model.value boolValue] animated:NO];
}

#pragma mark - ValueChanged
- (void)switchButtonValueChanged:(UISwitch *)switchButton {
    _model.value = NSStringFromNumber(@(switchButton.isOn));
    if (self.valueChangedHandler) {
        self.valueChangedHandler(switchButton.isOn);
    }
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
