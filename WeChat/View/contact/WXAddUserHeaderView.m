//
//  WXAddUserHeaderView.m
//  MNChat
//
//  Created by Vincent on 2019/4/6.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAddUserHeaderView.h"

@interface WXAddUserHeaderView ()
@property (nonatomic, weak) UIButton *headButton;
@end

@implementation WXAddUserHeaderView
- (void)createView {
    [super createView];
    
    UIButton *headButton = [UIButton buttonWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 65.f), 25.f, 65.f, 65.f)
                                               image:[UIImage imageNamed:@"wx_contacts_avatar_add"]
                                               title:nil
                                          titleColor:nil
                                                titleFont:nil];
    UIViewSetCornerRadius(headButton, 5.f);
    [headButton addTarget:self action:@selector(headButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:headButton];
    self.headButton = headButton;
    
    UILabel *hintLabel = [UILabel labelWithFrame:CGRectMake(MEAN(self.contentView.width_mn - 100.f), headButton.bottom_mn + 10.f, 100.f, 13.f)
                                            text:@"添加头像"
                                   textAlignment:NSTextAlignmentCenter
                                       textColor:UIColorWithAlpha([UIColor darkTextColor], .6f)
                                            font:UIFontRegular(13.f)];
    [self.contentView addSubview:hintLabel];
    
    self.height_mn = hintLabel.bottom_mn + 5.f;
}

- (void)headButtonClicked {
    MNActionSheet *actionSheet = [MNActionSheet actionSheetWithTitle:nil cancelButtonTitle:@"取消" handler:^(MNActionSheet *sheet, NSInteger buttonIndex) {
        if (buttonIndex == sheet.cancelButtonIndex) return;
        if (buttonIndex == 2) {
            self.headButton.selected = NO;
        } else {
            MNAssetPicker *picker = [[MNAssetPicker alloc] initWithType:buttonIndex];
            picker.configuration.cropScale = 1.f;
            picker.configuration.exportPixel = 100.f;
            picker.configuration.allowsCapturing = NO;
            picker.configuration.allowsEditing = YES;
            picker.configuration.allowsPickingGif = NO;
            picker.configuration.allowsPickingVideo = NO;
            picker.configuration.allowsPickingLivePhoto = NO;
            [picker presentWithPickingHandler:^(NSArray<MNAsset *> *assets) {
                if (assets.count <= 0) return;
                UIImage *image = assets.firstObject.content;
                if (image) {
                    self.headButton.selected = YES;
                    [self.headButton setBackgroundImage:image forState:UIControlStateSelected];
                } else {
                    [self.viewController.view showInfoDialog:@"获取图片资源出错"];
                }
            } cancelHandler:nil];
        }
    } otherButtonTitles:@"打开相册", @"打开相机", (self.headButton.selected ? @"删除头像" : nil), nil];
    if (self.headButton.selected) {
        [actionSheet setButtonTitleColor:BADGE_COLOR ofIndex:2];
    }
    [actionSheet show];
}

@end
