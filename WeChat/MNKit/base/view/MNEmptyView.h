//
//  MNEmptyView.h
//  MNKit
//
//  Created by Vincent on 2017/8/3.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MNEmptyView;

typedef NS_ENUM(NSInteger, MNEmptyEventType) {
    MNEmptyEventTypeReload,
    MNEmptyEventTypeLoad,
    MNEmptyEventTypeOther
};

@protocol MNEmptyViewDelegate <NSObject>
@optional

- (void)dataEmptyViewButtonClicked:(MNEmptyView *)emptyView;

@end

@interface MNEmptyView : UIView

@property(nonatomic) MNEmptyEventType type;

@property(nonatomic, weak) id<MNEmptyViewDelegate> delegate;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *buttonTitle;

@property (nonatomic, copy) UIColor *textColor;

@property (nonatomic, copy) UIColor *buttonTitleColor;

- (void)show;

- (void)dismiss;

@end
