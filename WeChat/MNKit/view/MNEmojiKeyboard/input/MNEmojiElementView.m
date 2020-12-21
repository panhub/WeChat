//
//  MNEmojiElementView.m
//  JLChat
//
//  Created by Vincent on 2020/2/13.
//  Copyright © 2020 AiZhe. All rights reserved.
//

#import "MNEmojiElementView.h"
#import "MNEmojiButton.h"
#import "MNEmojiKeyboardConfiguration.h"

@interface MNEmojiElementView ()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) MNEmojiButton *deleteButton;

@property (nonatomic, strong) MNEmojiButton *returnButton;

@end

@implementation MNEmojiElementView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectZero]) {
        
        self.backgroundColor = UIColor.clearColor;
        
        UIView *contentView = [[UIView alloc] initWithFrame:self.bounds];
        contentView.backgroundColor = UIColor.clearColor;
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView = contentView];
        
        UIImage *image = [MNBundle imageForResource:@"keyboard_delete"];
        CGSize imageSize = CGSizeMultiplyToHeight(image.size, 15.f);
        MNEmojiButton *deleteButton = [[MNEmojiButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)];
        deleteButton.backgroundColor = UIColor.whiteColor;
        deleteButton.layer.cornerRadius = 6.f;
        deleteButton.clipsToBounds = YES;
        deleteButton.image = image;
        deleteButton.imageInset = UIEdgeInsetsMake((deleteButton.height_mn - imageSize.height)/2.f, (deleteButton.width_mn - imageSize.width)/2.f, (deleteButton.height_mn - imageSize.height)/2.f, (deleteButton.width_mn - imageSize.width)/2.f);
        [deleteButton fixedImageSize];
        [contentView addSubview:deleteButton];
        self.deleteButton = deleteButton;
        
        MNEmojiButton *returnButton = [[MNEmojiButton alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 100.f)];
        returnButton.tag = 1;
        returnButton.backgroundColor = UIColor.whiteColor;
        returnButton.layer.cornerRadius = 6.f;
        returnButton.clipsToBounds = YES;
        returnButton.titleInset = UIEdgeInsetsMake(6.f, 6.f, 6.f, 6.f);
        [returnButton fixedTitleSize];
        [contentView addSubview:returnButton];
        self.returnButton = returnButton;
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat inset = 6.f;
    CGFloat width = (self.contentView.width_mn - inset)/2.f;
    CGFloat height = self.contentView.height_mn;
    self.deleteButton.size_mn = self.returnButton.size_mn = CGSizeMake(width, height);
    self.deleteButton.left_mn = 0.f;
    self.returnButton.left_mn = self.deleteButton.right_mn + inset;
    self.deleteButton.centerY_mn = self.returnButton.centerY_mn = self.contentView.height_mn/2.f;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    for (UIView *obj in self.contentView.subviews) {
        if (![obj isKindOfClass:MNEmojiButton.class]) continue;
        UIButton *button = (UIButton *)obj;
        [button addTarget:target action:action forControlEvents:controlEvents];
    }
}

#pragma mark - Setter
- (void)setConfiguration:(MNEmojiKeyboardConfiguration *)configuration {
    _configuration = configuration;
    self.returnButton.title = self.returnButtonTitle;
    self.returnButton.titleColor = configuration.returnKeyTitleColor;
    self.returnButton.titleFont = configuration.returnKeyTitleFont;
    self.returnButton.backgroundColor = configuration.returnKeyColor;
}

#pragma mark - Getter
- (NSString *)returnButtonTitle {
    NSArray <NSString *>*buttonTitles = @[@"换行", @"前往", @"Google", @"加入", @"下一项", @"路线", @"搜索", @"发送", @"Yahoo", @"确定", @"紧急", @"继续"];
    if (self.configuration.returnKeyType >= buttonTitles.count) return @"确定";
    return buttonTitles[self.configuration.returnKeyType];
}

@end
