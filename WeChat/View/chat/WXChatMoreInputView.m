//
//  WXChatMoreInputView.m
//  WeChat
//
//  Created by Vincent on 2019/3/31.
//  Copyright © 2019 Vincent. All rights reserved.
// MNScrollView

#import "WXChatMoreInputView.h"

@interface WXChatMoreInputView ()<UIScrollViewDelegate, MNPageControlDelegate>
@property (nonatomic, strong) MNScrollView *scrollView;
@property (nonatomic, strong) MNPageControl *pageControl;
@end

@implementation WXChatMoreInputView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:UIScreen.mainScreen.bounds]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    
    MNScrollView *scrollView = [[MNScrollView alloc] initWithFrame:self.bounds];
    scrollView.delegate = self;
    scrollView.scrollDirection = MNScrollViewDirectionHorizontal;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn, MN_SEPARATOR_HEIGHT)];
    separator.backgroundColor = [UIColor.darkTextColor colorWithAlphaComponent:.15f];
    separator.clipsToBounds = YES;
    [self addSubview:separator];

    CGFloat x = 23.f;
    CGFloat w = 63.f;
    CGFloat y = 17.f;
    CGFloat vm = 35.f;
    NSInteger row = 2;
    NSInteger columns = 4;
    CGFloat hm = floor((self.width_mn - x*2.f - w*4.f)/3.f);
    __block CGFloat h = 0.f;
    NSArray <NSArray <NSString *>*>*imgs = [@[@"wx_chat_album", @"wx_chat_camera", @"wx_chat_video", @"wx_chat_location", @"wx_chat_redpacket", @"wx_chat_transfer", @"wx_chat_speech", @"wx_chat_favorites", @"wx_chat_card"] componentArrayByCapacity:row*columns];
    NSArray <NSArray <NSString *>*>*titles = [@[@"照片", @"拍摄", @"视频通话", @"位置", @"红包", @"转账", @"语音输入", @"收藏", @"个人名片"] componentArrayByCapacity:row*columns];
    [imgs enumerateObjectsUsingBlock:^(NSArray<NSString *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [UIView gridLayoutWithInitial:CGRectMake(x + scrollView.width_mn*idx, y, w, w) offset:UIOffsetMake(hm, vm) count:obj.count rows:columns handler:^(CGRect rect, NSUInteger i, BOOL *s) {
            
            if (i >= obj.count) {
                *s = YES;
                return;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = rect;
            button.tag = row*columns*idx + i;
            [button setBackgroundImage:[UIImage imageNamed:@"chat_tool_more"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"chat_tool_moreHL"] forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(moreInputButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:button];
            
            UIImageView *imageView = [UIImageView imageViewWithFrame:button.bounds image:[UIImage imageNamed:obj[i]]];
            imageView.userInteractionEnabled = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button addSubview:imageView];
            
            UILabel *label = [UILabel labelWithFrame:CGRectZero
                                                text:titles[idx][i]
                                       alignment:NSTextAlignmentCenter
                                           textColor:[UIColor.darkTextColor colorWithAlphaComponent:.5f]
                                                font:[UIFont systemFontOfSize:12.f]];
            label.numberOfLines = 1;
            [label sizeToFit];
            label.top_mn = button.bottom_mn + 5.f;
            label.centerX_mn = button.centerX_mn;
            [scrollView addSubview:label];
            
            h = MAX(label.bottom_mn, h);
        }];
    }];
    
    MNPageControl *pageControl = [[MNPageControl alloc] initWithFrame:CGRectMake(0.f, h + 23.f, 50.f, 7.f)];
    pageControl.delegate = self;
    pageControl.pageInterval = 10.f;
    pageControl.pageSize = CGSizeMake(pageControl.height_mn, pageControl.height_mn);
    pageControl.direction = MNPageControlDirectionHorizontal;
    pageControl.touchInset = UIEdgeInsetsMake(-5.f, 0.f, -5.f, 0.f);
    pageControl.pageTouchInset = UIEdgeInsetsMake(-5.f, -5.f, -5.f, -5.f);
    pageControl.pageIndicatorTintColor = [UIColor.grayColor colorWithAlphaComponent:.37f];
    pageControl.currentPageIndicatorTintColor = [UIColor.grayColor colorWithAlphaComponent:.95f];
    pageControl.numberOfPages = imgs.count;
    pageControl.centerX_mn = self.width_mn/2.f;
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    self.height_mn = pageControl.bottom_mn + 23.f + MN_TAB_SAFE_HEIGHT;
    scrollView.numberOfPages = imgs.count;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPageIndex = ((MNScrollView *)scrollView).currentPageIndex;
}

#pragma mark - MNPageControlDelegate
- (void)pageControl:(MNPageControl *)pageControl didSelectPageOfIndex:(NSUInteger)index {
    [self.scrollView setContentOffset:CGPointMake(index*self.scrollView.width_mn, 0.f) animated:YES];
}

- (void)moreInputButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(moreInputView:didSelectButtonAtIndex:)]) {
        [self.delegate moreInputView:self didSelectButtonAtIndex:sender.tag];
    }
}

@end
