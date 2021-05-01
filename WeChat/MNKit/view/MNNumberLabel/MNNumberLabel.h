//
//  MNNumberLabel.h
//  MNKit
//
//  Created by Vincent on 2018/12/13.
//  Copyright © 2018年 小斯. All rights reserved.
//  数字动画Label

#import <UIKit/UIKit.h>

typedef void (^MNNumberLabelCompletionCallback)(void);
typedef NSString * (^MNNumberLabelFormatCallback)(CGFloat value);
typedef NSAttributedString * (^MNNumberLabelAttributedFormatCallback)(CGFloat value);

@interface MNNumberLabel : UILabel

@property (nonatomic, copy) NSString *format;
@property (nonatomic, assign, readonly) CGFloat currentValue;
@property (nonatomic, copy) MNNumberLabelFormatCallback formatCallback;
@property (nonatomic, copy) MNNumberLabelAttributedFormatCallback attributedFormatCallback;
@property (nonatomic, copy) MNNumberLabelCompletionCallback completionCallback;

- (void)runFrom:(CGFloat)fromValue
             to:(CGFloat)toValue
       duration:(NSTimeInterval)duration;

- (void)runFrom:(CGFloat)fromValue
               to:(CGFloat)toValue
         duration:(NSTimeInterval)duration
       completion:(MNNumberLabelCompletionCallback)completion;

@end

