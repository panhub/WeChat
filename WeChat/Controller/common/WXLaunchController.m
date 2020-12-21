//
//  WXLaunchController.m
//  TeamAlbum
//
//  Created by Vicent on 2020/10/27.
//

#import "WXLaunchController.h"

@interface WXLaunchController ()

@end

@implementation WXLaunchController

- (void)createView {
    [super createView];
    // Do any additional setup after loading the view.
    
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    UIImageView *imageView = [UIImageView imageViewWithFrame:self.contentView.bounds image:[UIImage imageNamed:@"LaunchImage"]];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = UIColor.whiteColor;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:imageView];
}

#pragma mark - Super
- (MNContentEdges)contentEdges {
    return MNContentEdgeNone;
}

@end
