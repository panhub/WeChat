//
//  WXMapHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMapHeaderView.h"

@interface WXMapHeaderView ()
@property (nonatomic, strong) UITextField *textField;
@end

@implementation WXMapHeaderView
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 3.f;
        self.layer.shadowOpacity = 1.f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowColor = [UIColorWithAlpha([UIColor grayColor], .3f) CGColor];
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:self.layer.bounds] CGPath];
        
        /// 返回按钮
        /// MN_R_G_B(51.f, 133.f, 255.f)
        UIButton *backButton = [UIButton buttonWithFrame:CGRectMake(kNavItemMargin - self.left_mn, MEAN(self.height_mn - kNavItemSize), kNavItemSize, kNavItemSize)
                                                   image:UIImageWithUnicode(MNFontUnicodeBack, [UIColor darkTextColor], kNavItemSize)
                                                   title:nil
                                              titleColor:nil
                                                    titleFont:nil];
        backButton.touchInset = UIEdgeInsetWith(-5.f);
        [backButton addTarget:self action:@selector(backButtoncClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backButton];
        
        /*
        /// 路线
        UIButton *pathButton = [UIButton buttonWithFrame:CGRectMake(self.width_mn - backButton.right_mn, backButton.top_mn, backButton.width_mn, backButton.height_mn)
                                                   image:UIImageNamed(@"wx_map_path")
                                                   title:nil
                                              titleColor:nil
                                                    titleFont:nil];
        pathButton.tag = 1;
        pathButton.touchInset = UIEdgeInsetWith(-5.f);
        [pathButton addTarget:self action:@selector(backButtoncClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:pathButton];
        */
        
        /// 提示信息
        UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(backButton.right_mn, 0.f, self.width_mn - backButton.right_mn*2.f, self.height_mn)
                                                            font:UIFontRegular(17.f)
                                                     placeholder:@"搜索附近车站、酒店、地点"
                                                        delegate:nil];
        textField.textColor = UIColorWithAlpha([UIColor darkTextColor], .85f);
        textField.userInteractionEnabled = NO;
        textField.borderStyle = UITextBorderStyleNone;
        textField.placeholderColor = UIColorWithAlpha([UIColor grayColor], .4f);
        textField.backgroundColor = [UIColor whiteColor];
        //textField.layer.cornerRadius = 4.f;
        //textField.clipsToBounds = YES;
        [self addSubview:textField];
        self.textField = textField;
        
        /// 手势
        [self addGestureRecognizer:UITapGestureRecognizerCreate(self, @selector(handTapEvent), nil)];
    }
    return self;
}

- (void)backButtoncClicked:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(headerView:buttonClickedEvent:)]) {
        [_delegate headerView:self buttonClickedEvent:sender];
    }
}

- (void)handTapEvent {
    if ([_delegate respondsToSelector:@selector(headerViewClickedEvent:)]) {
        [_delegate headerViewClickedEvent:self];
    }
}

- (void)setText:(NSString *)text {
    self.textField.text = text;
}

- (NSString *)text {
    return self.textField.text;
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectMake(10.f, MN_STATUS_BAR_HEIGHT, MN_SCREEN_WIDTH - 20.f, MN_NAV_BAR_HEIGHT);
    [super setFrame:frame];
}

@end
