//
//  TEMemoryLabel.h
//  TodayExtension
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//  存储信息

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TEMemoryLabelType) {
    TEMemoryLabelMemory = 0,
    TEMemoryLabelDisk
};

@interface TEMemoryLabel : UIView

@property (nonatomic) TEMemoryLabelType type;

- (void)loadData;

@end

