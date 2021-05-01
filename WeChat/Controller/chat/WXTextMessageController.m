//
//  WXTextMessageController.m
//  WeChat
//
//  Created by Vincent on 2019/7/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXTextMessageController.h"

@interface WXTextMessageController ()
@property (nonatomic, copy) NSString *message;
@end

@implementation WXTextMessageController
- (instancetype)initWithMessage:(NSString *)message {
    if (self = [super init]) {
        self.message = message;
    }
    return self;
}
- (void)createView {
    [super createView];
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    NSMutableAttributedString *attributedText = self.message.attributedString.mutableCopy;
    [attributedText matchingEmojiWithFont:[UIFont systemFontOfSize:21.f]];
    attributedText.font = [UIFont systemFontOfSize:21.f];
    attributedText.color = [[UIColor darkTextColor] colorWithAlphaComponent:.9f];
    NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
    style.alignment = NSTextAlignmentCenter;
    style.lineSpacing = 3.f;
    attributedText.paragraphStyle = style;
    
    CGSize size = [attributedText sizeOfLimitWidth:self.contentView.width_mn - 60.f];
    
    UILabel *textLabel = [UILabel labelWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) text:attributedText textColor:nil font:nil];
    textLabel.center_mn = self.contentView.bounds_center;
    textLabel.numberOfLines = 0;
    textLabel.userInteractionEnabled = NO;
    [self.contentView addSubview:textLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
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
