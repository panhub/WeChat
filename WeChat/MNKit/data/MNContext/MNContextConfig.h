//
//  MNContextConfig.h
//  MNKit
//
//  Created by Vincent on 2019/8/8.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNContextConfig : NSObject

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) UIColor *strokeColor;

@property (nonatomic) CGFloat lineWidth;

@property (nonatomic) CGLineCap lineCap;

@property (nonatomic) CGLineJoin lineJoin;

@property (nonatomic) CGFloat phase;

@property (nonatomic) CGFloat *lengths;

@property (nonatomic) size_t count;

@end
