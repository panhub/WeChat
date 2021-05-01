//
//  WXEditUserInfoCell.m
//  WeChat
//
//  Created by Vincent on 2019/3/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXEditUserInfoCell.h"
#import "WXDataValueModel.h"

@interface WXEditUserInfoCell () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@end

@implementation WXEditUserInfoCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(15.f, 0.f, self.contentView.width_mn - 30.f, self.contentView.height_mn)
                                                            font:UIFontRegular(16.5f)
                                                     placeholder:@""
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.performActions = MNTextFieldActionNone;
        textField.textColor = UIColorWithAlpha([UIColor darkTextColor], .9f);
        textField.placeholderFont = [UIFont systemFontOfSize:16.5f];
        textField.placeholderColor = UIColorWithAlpha([UIColor darkTextColor], .4f);
        [self.contentView addSubview:textField];
        self.textField = textField;
    }
    return self;
}

#pragma mark - set model
- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.textField.text = model.value;
    self.textField.placeholder = model.desc;
    self.textField.keyboardType = [model.userInfo integerValue];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _model.user_info = @(YES);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    _model.user_info = @(NO);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _model.value = textField.text;
    _model.user_info = @(NO);
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
