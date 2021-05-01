//
//  WXDataValueCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXDataValueCell.h"
#import "WXDataValueModel.h"

@interface WXDataValueCell ()
@property (nonatomic, strong) UISwitch *switchButton;
@end

@implementation WXDataValueCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.left_mn = 15.f;
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        self.imgView.image = [UIImage imageNamed:@"wx_common_list_arrow"];
        self.imgView.height_mn = 25.f;
        [self.imgView sizeFitToHeight];
        self.imgView.right_mn = self.contentView.width_mn - 10.f;
        self.imgView.centerY_mn = self.contentView.height_mn/2.f;
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .5f);
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];;
        
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
        switchButton.right_mn = self.imgView.right_mn - 5.f;
        switchButton.centerY_mn = self.contentView.height_mn/2.f;
        switchButton.userInteractionEnabled = YES;
        switchButton.tintColor = [UIColor whiteColor];
        switchButton.onTintColor = THEME_COLOR;
        UIViewSetBorderRadius(switchButton, MEAN(switchButton.height_mn), 2.f, VIEW_COLOR);
        [switchButton addTarget:self action:@selector(switchButtonValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:switchButton];
        self.switchButton = switchButton;
    }
    return self;
}

#pragma mark - ValueChanged
- (void)switchButtonValueChanged:(UISwitch *)switchButton {
    _model.value = NSStringFromNumber(@(switchButton.isOn));
    if (self.valueChangedHandler) {
        self.valueChangedHandler(self.index_path, switchButton.isOn);
    }
}

#pragma mark - Setter
- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.detailLabel.text = model.desc;
    self.switchButton.on = [model.value boolValue];
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY_mn = self.contentView.height_mn/2.f;
    [self.detailLabel sizeToFit];
    self.detailLabel.width_mn = MIN(self.detailLabel.width_mn, self.imgView.left_mn - self.titleLabel.right_mn - 10.f);
    self.detailLabel.centerY_mn = self.contentView.height_mn/2.f;
    self.detailLabel.right_mn = self.imgView.left_mn;
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
