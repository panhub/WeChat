//
//  WXLivePhotoController.m
//  MNChat
//
//  Created by Vincent on 2019/12/14.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLivePhotoController.h"
#if __has_include(<PhotosUI/PHLivePhotoView.h>)
#import "MNLivePhoto.h"
#import <PhotosUI/PHLivePhotoView.h>
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@interface WXLivePhotoController ()<PHLivePhotoViewDelegate, MNAssetBrowseDelegate>
@property (nonatomic, strong) MNLivePhoto *livePhoto;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@end

@implementation WXLivePhotoController
- (instancetype)initWithLivePhoto:(MNLivePhoto *)livePhoto {
    if (self = [super init]) {
        self.title = @"LivePhoto";
        self.livePhoto = livePhoto;
    }
    return self;
}

- (void)createView {
    [super createView];
    
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowColor = UIColor.whiteColor;
    self.navigationBar.backgroundColor = UIColor.whiteColor;
    
    self.contentView.backgroundColor = VIEW_COLOR;
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.livePhoto.imageURL.path];
    CGSize displaySize = self.contentView.size_mn;
    displaySize.height -= (MN_TAB_SAFE_HEIGHT + 30.f);
    CGSize naturalSize = image.size;
    if (naturalSize.width >= naturalSize.height) {
        // 横向视频比例按钮放下面
        naturalSize = CGSizeMultiplyToWidth(naturalSize, displaySize.width);
        if (naturalSize.height > displaySize.height) {
            naturalSize = CGSizeMultiplyToHeight(naturalSize, displaySize.height);
        }
    } else {
        // 纵向视频比例按钮放左侧
        naturalSize = CGSizeMultiplyToHeight(naturalSize, displaySize.height);
        if (naturalSize.width > displaySize.width) {
            naturalSize = CGSizeMultiplyToWidth(naturalSize, displaySize.width);
        }
    }
    
    PHLivePhotoView *livePhotoView = [[PHLivePhotoView alloc] initWithFrame:CGRectFillToSize(naturalSize)];
    livePhotoView.centerX_mn = self.contentView.width_mn/2.f;
    livePhotoView.centerY_mn = (self.contentView.height_mn - MN_TAB_SAFE_HEIGHT)/2.f;
    livePhotoView.delegate = self;
    livePhotoView.clipsToBounds = YES;
    livePhotoView.livePhoto = self.livePhoto.content;
    livePhotoView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:livePhotoView];
    self.livePhotoView = livePhotoView;
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:livePhotoView.frame image:image];
    imageView.frame = livePhotoView.frame;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    UITapGestureRecognizer *tap = UITapGestureRecognizerCreate(self, @selector(handTap:), nil);
    [livePhotoView addGestureRecognizer:tap];
    
    [livePhotoView.playbackGestureRecognizer requireGestureRecognizerToFail:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Event
- (void)handTap:(UITapGestureRecognizer *)tap {
    self.livePhotoView.hidden = YES;
    MNAsset *asset = MNAsset.new;
    asset.containerView = self.imageView;
    asset.type = MNAssetTypeLivePhoto;
    asset.content = self.livePhoto.content;
    asset.thumbnail = self.imageView.image;
    MNAssetBrowser *browser = [[MNAssetBrowser alloc] initWithFrame:self.view.bounds];
    browser.delegate = self;
    browser.assets = @[asset];
    browser.statusBarHidden = NO;
    browser.statusBarStyle = UIStatusBarStyleLightContent;
    browser.backgroundColor = UIColor.blackColor;
    [browser presentInView:self.view fromIndex:0 animated:YES completion:nil];
}

#pragma mark - PHLivePhotoViewDelegate
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.imageView.hidden = YES;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.imageView.hidden = NO;
}

#pragma mark - MNAssetBrowseDelegate
- (void)assetBrowserWillPresent:(MNAssetBrowser *)assetBrowser {
    self.livePhotoView.hidden = YES;
}

- (void)assetBrowserDidDismiss:(MNAssetBrowser *)assetBrowser {
    self.livePhotoView.hidden = NO;
}

#pragma mark - MNNavigationBarDelegate
- (UIView *)navigationBarShouldCreateRightBarItem {
    UIButton *rightBarItem = [UIButton buttonWithFrame:CGRectMake(0.f, 0.f, 55.f, 30.f)
                                                 image:nil
                                                 title:@"保存"
                                            titleColor:UIColor.whiteColor
                                             titleFont:UIFontSystem(15.f)];
    rightBarItem.backgroundColor = THEME_COLOR;
    UIViewSetCornerRadius(rightBarItem, 4.f);
    [rightBarItem addTarget:self action:@selector(navigationBarRightBarItemTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    return rightBarItem;
}

- (void)navigationBarRightBarItemTouchUpInside:(UIView *)rightBarItem {
    [self.view showWechatDialog];
    [MNAssetHelper writeLivePhotoWithImagePath:self.livePhoto.imageURL videoPath:self.livePhoto.videoURL completion:^(NSString * _Nullable identifier, NSError * _Nullable error) {
        dispatch_async_main(^{
            if (identifier.length <= 0) {
                @weakify(self);
                [self.view showCompletedDialog:@"已保存至系统相册" completionHandler:^{
                    @strongify(self);
                    [self.livePhotoView stopPlayback];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            } else {
                [self.view showInfoDialog:error.localizedDescription];
            }
        });
    }];
}

#pragma mark - Super
- (void)dealloc {
    [self.livePhoto removeContents];
}

@end
#pragma clang diagnostic pop
