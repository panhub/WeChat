//
//  WXTextMessageController.m
//  MNChat
//
//  Created by Vincent on 2019/7/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTextMessageController.h"

@interface WXTextMessageController ()
@property (nonatomic, copy) NSAttributedString *attributedText;
@end

@implementation WXTextMessageController
- (instancetype)initWithAttributedMessage:(NSAttributedString *)message {
    if (self = [super init]) {
        NSMutableAttributedString *attributedText = message.mutableCopy;
        attributedText.font = [UIFont systemFontOfSize:20.f];
        attributedText.color = [[UIColor darkTextColor] colorWithAlphaComponent:.9f];
        self.attributedText = attributedText.copy;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    return self;
}
- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    CGFloat y = UIStatusBarHeight() + 20.f;
    UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(25.f, y, self.contentView.width_mn - 50.f, self.contentView.height_mn - y*2.f) text:self.attributedText textAlignment:NSTextAlignmentCenter textColor:UIColorWithAlpha([UIColor darkTextColor], .9f) font:[UIFont systemFontOfSize:20.f]];
    textLabel.numberOfLines = 0;
    textLabel.userInteractionEnabled = NO;
    [self.contentView addSubview:textLabel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

- (MNTransitionAnimator *)pushTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSoluble];
}

- (MNTransitionAnimator *)popTransitionAnimator {
    return [MNTransitionAnimator animatorWithType:MNControllerTransitionTypeSoluble];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
