//
//  WXImageCropModel.h
//  WeChat
//
//  Created by Vincent on 2019/12/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXImageCropModel : NSObject

@property (nonatomic) CGSize size;

@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
