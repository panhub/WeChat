//
//  WXPaySetingListCell.m
//  WeChat
//
//  Created by Vincent on 2019/6/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXPaySetingListCell.h"
#import "WXDataValueModel.h"

@interface WXPaySetingListCell ()
@property (nonatomic, strong) UISwitch *switchButton;
@end

@implementation WXPaySetingListCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 120.f, 17.f);
        self.titleLabel.textColor = UIColorWithAlpha([UIColor darkTextColor], .9f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        self.imgView.frame = CGRectMake(self.contentView.width_mn - size.width - 12.f, 0.f, size.width, size.height);
        self.imgView.image = image;
        self.imgView.centerY_mn = self.titleLabel.centerY_mn;
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn + 10.f, self.titleLabel.top_mn, self.imgView.left_mn - self.titleLabel.right_mn - 10.f, self.titleLabel.height_mn);
        self.detailLabel.textColor = UIColorWithAlpha([UIColor darkGrayColor], .7f);
        self.detailLabel.font = self.titleLabel.font;
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0.f, 0.f, 0.f, 30.f)];
        switchButton.right_mn = self.imgView.right_mn - 3.f;
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

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    id value = model.value;
    if (!value) {
        self.imgView.hidden = NO;
        self.detailLabel.hidden = self.switchButton.hidden = YES;
    } else if ([value isKindOfClass:NSString.class]) {
        self.switchButton.hidden = YES;
        self.imgView.hidden = self.detailLabel.hidden = NO;
        self.detailLabel.text = value;
    } else if ([value isKindOfClass:NSNumber.class]) {
        self.switchButton.hidden = NO;
        self.imgView.hidden = self.detailLabel.hidden = YES;
        self.switchButton.on = kTransform(NSNumber *, value).boolValue;
    }
}

- (void)switchButtonValueChanged:(UISwitch *)sender {
    if (self.valueDidChangeHandler) {
        self.valueDidChangeHandler(sender.isOn);
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
