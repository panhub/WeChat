//
//  MNCapturingController.h
//  MNChat
//
//  Created by Vincent on 2019/6/12.
//  Copyright © 2019 Vincent. All rights reserved.
//  资源获取<视频录制/拍照>

#import "MNBaseViewController.h"
@class MNCapturingController, MNAssetPickConfiguration;

@protocol MNCapturingControllerDelegate <NSObject>
@optional;
- (void)capturingControllerDidCancel:(MNCapturingController *)capturingController;
- (void)capturingController:(MNCapturingController *)capturingController didFinishWithContentOfFile:(NSString *)filePath;
- (void)capturingController:(MNCapturingController *)capturingController didFinishWithStillImage:(UIImage *)image;
- (void)capturingController:(MNCapturingController *)capturingController didFinishWithContent:(id)content;
@end

@interface MNCapturingController : MNBaseViewController

@property (nonatomic, copy) NSString *filePath;

@property (nonatomic, weak) id<MNCapturingControllerDelegate> delegate;

@property (nonatomic, strong) MNAssetPickConfiguration *configuration;

@end
