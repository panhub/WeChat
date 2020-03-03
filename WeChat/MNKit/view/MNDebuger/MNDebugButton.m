//
//  MNDebugButton.m
//  MNFoundation
//
//  Created by Vincent on 2019/9/19.
//  Copyright © 2019 XiaoSi. All rights reserved.
//

#import "MNDebugButton.h"

const CGFloat MNDebugButtonWH = 60.f;
const CGFloat MNDebugAnimationDuration = .21f;

@interface MNDebugButton ()
@property (nonatomic) CGRect rect;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic) MNDebugButtonType type;
@end

@implementation MNDebugButton

- (instancetype)init {
    return [self initWithType:MNDebugButtonTypeMain];
}

+ (instancetype)buttonWithType:(MNDebugButtonType)type {
    return [[MNDebugButton alloc] initWithType:type];
}

- (instancetype)initWithType:(MNDebugButtonType)type {
    if (self = [super init]) {
        
        self.type = type;
        
        NSArray <NSString *>*titles = @[@"返回", @"日志", @"FPS", @"流量"];
        NSArray <NSString *>*imgs = @[@"icon_mainHL", @"icon_debug_log", @"icon_debug_fps", @"icon_debug_stream"];
        
        NSString *title = titles[type];
        UIImage *image = [MNBundle imageForResource:imgs[type]];

        UIImageView *selectedImageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, MNDebugButtonWH, MNDebugButtonWH) image:nil];
        selectedImageView.userInteractionEnabled = NO;
        [self addSubview:selectedImageView];
        self.selectedImageView = selectedImageView;
        
        CGSize size = image.size;
        size = size.width >= size.height ? CGSizeMultiplyToWidth(size, 55.f) : CGSizeMultiplyToHeight(size, 55.f);
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:(type == MNDebugButtonTypeMain ? image : [image templateImage])];
        imageView.tintColor = [UIColor whiteColor];
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, imageView.bottom_mn + 5.f, MNDebugButtonWH, 15.f)
                                                 text:title
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor whiteColor]
                                                 font:UIFontLight(15.f)];
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *selectedLabel = titleLabel.viewCopy;
        [self insertSubview:selectedLabel belowSubview:titleLabel];
        self.selectedLabel = selectedLabel;
        
        self.size_mn = CGSizeMake(MNDebugButtonWH, MAX(titleLabel.bottom_mn, MNDebugButtonWH));
        
        CGFloat y = MEAN(self.height_mn - titleLabel.bottom_mn);
        imageView.top_mn = y;
        imageView.centerX_mn = self.width_mn/2.f;
        selectedLabel.top_mn = titleLabel.top_mn = imageView.bottom_mn + 5.f;
        
        if (type == MNDebugButtonTypeMain) {
            selectedLabel.textColor = [UIColor whiteColor];
            selectedImageView.image = [MNBundle imageForResource:@"icon_main"];
        } else {
            selectedImageView.frame = imageView.frame;
            selectedImageView.image = image.templateImage;
            selectedLabel.textColor = UIColorWithRGB(0.f, 122.f, 254.f);
        }
        
        selectedImageView.tintColor = selectedLabel.textColor;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    if (self = [super init]) {
        
        CGSize size = image.size;
        size = size.width >= size.height ? CGSizeMultiplyToWidth(size, 55.f) : CGSizeMultiplyToHeight(size, 55.f);
        
        UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(0.f, 0.f, size.width, size.height) image:image];
        imageView.userInteractionEnabled = NO;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectMake(0.f, imageView.bottom_mn + 5.f, size.width, 15.f)
                                                 text:title
                                        textAlignment:NSTextAlignmentCenter
                                            textColor:[UIColor whiteColor]
                                                 font:UIFontLight(15.f)];
        titleLabel.userInteractionEnabled = NO;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        self.size_mn = CGSizeMake(size.width, titleLabel.bottom_mn);
    }
    return self;
}

- (void)makeTitleHidden {
    self.titleLabel.alpha = self.selectedLabel.alpha = 0.f;
}

- (void)show {
    self.alpha = 1.f;
    self.frame = self.rect;
    self.selected = self.type == MNDebugButtonTypeMain ? NO : self.selected;
    self.userInteractionEnabled = YES;
}

- (void)dismiss {
    self.top_mn = 0.f;
    self.centerX_mn = self.superview.width_mn/2.f;
    self.alpha = self.type == MNDebugButtonTypeMain ? 1.f : 0.f;
    self.selected = self.type == MNDebugButtonTypeMain ? YES : self.selected;
    self.userInteractionEnabled = NO;
}

#pragma mark - Setter
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    CGFloat alpha = selected ? 1.f : 0.f;
    self.titleLabel.alpha = self.imageView.alpha = 1.f - alpha;
    self.selectedLabel.alpha = self.selectedImageView.alpha = alpha;
}

#pragma mark - Super
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && CGRectIsEmpty(self.rect)) {
        self.rect = self.frame;
        [self dismiss];
        [self makeTitleHidden];
    }
}

@end
