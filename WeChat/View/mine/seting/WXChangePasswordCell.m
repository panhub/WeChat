//
//  WXChangePasswordCell.m
//  MNChat
//
//  Created by Vincent on 2019/8/5.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXChangePasswordCell.h"
#import "WXDataValueModel.h"

@interface WXChangePasswordCell () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@end

@implementation WXChangePasswordCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 95.f, 17.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.88f];
        
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(self.titleLabel.right_mn, 0.f, self.contentView.width_mn - self.titleLabel.right_mn - self.titleLabel.left_mn, self.contentView.height_mn)
                                                            font:[UIFont systemFontOfSize:17.f]
                                                     placeholder:@""
                                                        delegate:self];
        textField.tintColor = THEME_COLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.keyboardType = UIKeyboardTypeNamePhonePad;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeNever;
        textField.performActions = MNTextFieldActionNone;
        textField.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.95f];
        textField.placeholderFont = [UIFont systemFontOfSize:17.f];
        textField.placeholderColor = [[UIColor grayColor] colorWithAlphaComponent:.8f];
        [self.contentView addSubview:textField];
        self.textField = textField;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, self.titleLabel.left_mn, 0.f, 0.f);
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model row:(NSInteger)row {
    _model = model;
    self.titleLabel.text = model.title;
    self.textField.text = model.value;
    self.textField.placeholder = model.desc;
    self.titleLabel.textColor = row > 0 ? self.textField.textColor : self.textField.placeholderColor;
    self.textField.userInteractionEnabled = row > 0;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    _model.userInfo = @(YES);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    _model.userInfo = @(NO);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _model.value = textField.text;
    _model.userInfo = @(NO);
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
