//
//  WXMomentPreview.m
//  MNChat
//
//  Created by Vincent on 2019/9/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentPreview.h"
#import "WXMoment.h"

@interface WXMomentPreview ()
@property (nonatomic, strong) WXMoment *moment;
@end

@implementation WXMomentPreview
- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super initWithFrame:CGRectMake(0.f, 0.f, SCREEN_WIDTH, 0.f)]) {
        self.backgroundColor = UIColorWithAlpha(UIColor.blackColor, .3f);
        self.moment = moment;
        [self createView];
    }
    return self;
}

- (void)createView {
    
    UIFont *contentFont = UIFontWithNameSize(MNFontNameMedium, 13.f);
    
    NSMutableAttributedString *contentString = self.moment.content.attributedString.mutableCopy;
    contentString.font = contentFont;
    contentString.color = [UIColor whiteColor];
    contentString.lineBreakMode = NSLineBreakByCharWrapping;
    contentString.alignment = NSTextAlignmentLeft;
    contentString.lineSpacing = -3.f;
    
    [contentString matchingEmojiWithFont:contentFont];
    
    YYTextContainer *contentContainer = [YYTextContainer containerWithSize:CGSizeMake(self.width_mn - 20.f, MAXFLOAT)];
    contentContainer.maximumNumberOfRows = 5;
    
    YYTextLayout *contentLayout = [YYTextLayout layoutWithContainer:contentContainer text:contentString.copy];
    
    YYLabel *contentLabel = [[YYLabel alloc] initWithFrame:CGRectMake(10.f, 5.f, contentLayout.textBoundingSize.width, contentLayout.textBoundingSize.height)];
    /// 垂直方向顶部对齐
    contentLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    /// 异步渲染和布局
    contentLabel.displaysAsynchronously = NO;
    /// 利用textLayout来设置text、font、textColor...
    contentLabel.ignoreCommonProperties = YES;
    contentLabel.fadeOnAsynchronouslyDisplay = NO;
    contentLabel.fadeOnHighlight = NO;
    contentLabel.textLayout = contentLayout;
    [self addSubview:contentLabel];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, contentLabel.bottom_mn + 7.f, self.width_mn, 40.f + UITabSafeHeight())];
    bottomBar.backgroundColor = UIColorWithSingleRGB(46.f);
    [self addSubview:bottomBar];
    self.height_mn = bottomBar.bottom_mn;
    
    /// 左侧文字
    NSArray <NSString *>*imgs = @[@"wx_moment_like", @"wx_moment_comment"];
    NSArray <NSString *>*titles = @[@"赞    ", @"评论"];
    UIFont *font = UITabSafeHeight() > 0.f ? UIFontRegular(12.f) : UIFontRegular(13.f);
    NSMutableAttributedString *leftAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:obj];
        attachment.bounds = CGRectMake(-2.f, font.descender, font.lineHeight, font.lineHeight);
        [leftAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [leftAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:titles[idx]]];
    }];
    [leftAttributedString addAttribute:NSFontAttributeName value:font range:leftAttributedString.rangeOfAll];
    [leftAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:leftAttributedString.rangeOfAll];
    
    UILabel *leftBarLabel = [UILabel labelWithFrame:CGRectMake(contentLabel.left_mn + 2.f, MEAN(bottomBar.height_mn - font.lineHeight - UITabSafeHeight()), 130.f, font.lineHeight)
                                                 text:leftAttributedString
                                            textColor:nil
                                                 font:nil];
    [bottomBar addSubview:leftBarLabel];
    
    /// 右侧文字
    NSString *likedCount = self.moment.likes.count > 0 ? NSStringWithFormat(@"%@ ", @(self.moment.likes.count)) : @" ";
    NSString *commentCount = self.moment.comments.count > 0 ? NSStringWithFormat(@"%@", @(self.moment.comments.count)) : @"";
    titles = @[likedCount, commentCount];
    NSMutableAttributedString *rightAttributedString = [[NSMutableAttributedString alloc] initWithString:@""];
    [imgs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:obj];
        attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
        [rightAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        [rightAttributedString appendAttributedString:[[NSAttributedString alloc] initWithString:titles[idx]]];
    }];
    [rightAttributedString addAttribute:NSFontAttributeName value:font range:rightAttributedString.rangeOfAll];
    [rightAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:rightAttributedString.rangeOfAll];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    [rightAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:rightAttributedString.rangeOfAll];
    
    UILabel *rightBarLabel = [UILabel labelWithFrame:leftBarLabel.frame
                                                  text:rightAttributedString
                                             textColor:nil
                                                  font:nil];
    rightBarLabel.width_mn = 150.f;
    rightBarLabel.right_mn = self.width_mn - leftBarLabel.left_mn;
    rightBarLabel.userInteractionEnabled = YES;
    rightBarLabel.touchInset = UIEdgeInsetWith(-10.f);
    [bottomBar addSubview:rightBarLabel];
}

@end
