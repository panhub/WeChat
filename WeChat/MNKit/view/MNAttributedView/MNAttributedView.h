//
//  MNAttributedView.h
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/18.
//  Copyright © 2019年 AiZhe. All rights reserved.
//  富文本视图<用户协议>

#import <UIKit/UIKit.h>

typedef void(^MNAttributedViewHandler)(NSURL *URL, NSRange range);

@protocol MNAttributedViewDelegate <NSObject>

- (void)attributedViewDidInteractWithURL:(NSURL *)URL range:(NSRange)range;

@end

@interface MNAttributedView : UIView

@property (nonatomic, weak) id<MNAttributedViewDelegate> delegate;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSAttributedString *attributedText;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *attributes;
@property (nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *linkTextAttributes;

+ (instancetype)attributedViewWithFrame:(CGRect)frame
                                handler:(MNAttributedViewHandler)handler;

+ (instancetype)attributedViewWithFrame:(CGRect)frame
                                   text:(NSString *)text
                                handler:(MNAttributedViewHandler)handler;

+ (instancetype)attributedViewWithFrame:(CGRect)frame
                         attributedText:(NSAttributedString *)attributedText
                                handler:(MNAttributedViewHandler)handler;

@end
