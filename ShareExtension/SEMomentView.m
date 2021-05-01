//
//  SEMomentView.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/24.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SEMomentView.h"
#import "SETextView.h"
#import "UIView+MNLayout.h"

@interface SEMomentView ()<UITextViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SETextView *textView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SEMomentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:243.f/255.f alpha:1.f];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, 180.f)];
        backgroundView.backgroundColor = UIColor.whiteColor;
        [self addSubview:backgroundView];
        
        UIView *linkView = [[UIView alloc] initWithFrame:CGRectMake(15.f, 0.f, backgroundView.width_mn - 30.f, 57.f)];
        linkView.bottom_mn = backgroundView.height_mn - 15.f;
        linkView.backgroundColor = self.backgroundColor;
        [backgroundView addSubview:linkView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.f, 7.f, linkView.height_mn - 14.f, linkView.height_mn - 14.f)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageNamed:@"ext_share_link"];
        [linkView addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.left_mn = imageView.right_mn + imageView.left_mn;
        titleLabel.top_mn = imageView.top_mn;
        titleLabel.height_mn = imageView.height_mn;
        titleLabel.width_mn = linkView.width_mn - titleLabel.left_mn - imageView.left_mn;
        titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.8f];
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15.f];
        titleLabel.numberOfLines = 2;
        [linkView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        SETextView *textView = [[SETextView alloc] initWithFrame:CGRectMake(linkView.left_mn, 15.f, linkView.width_mn, linkView.top_mn - 30.f)];
        textView.delegate = self;
        textView.placeholder = @"这一刻的想法...";
        textView.placeholderColor = [UIColor.darkGrayColor colorWithAlphaComponent:.6f];
        textView.font = [UIFont systemFontOfSize:17.f];
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.tintColor = [UIColor colorWithRed:7.f/255.f green:192.f/255.f blue:96.f/255.f alpha:1.f];
        textView.backgroundColor = UIColor.whiteColor;
        textView.showsVerticalScrollIndicator = NO;
        textView.showsHorizontalScrollIndicator = NO;
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
        textView.keyboardType = UIKeyboardTypeDefault;
        textView.returnKeyType = UIReturnKeyDone;
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.textContainer.lineFragmentPadding = 0.f;
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            if ([textView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
        #endif
        [backgroundView addSubview:textView];
        self.textView = textView;
    }
    return self;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] || [text isEqualToString:@"\r"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

#pragma mark - Getter
- (UIImage *)image {
    return self.imageView.image;
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (NSString *)text {
    return self.textView.text ? : @"";
}

#pragma mark - Overwrite
- (BOOL)resignFirstResponder {
    return [self.textView resignFirstResponder];
}

@end
