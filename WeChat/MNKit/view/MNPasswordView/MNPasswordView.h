//
//  MNPasswordView.h
//  MNKit
//
//  Created by Vincent on 2018/10/24.
//  Copyright © 2018年 小斯. All rights reserved.
//  密码输入

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MNPasswordViewType) {
    MNPasswordViewTypeGrid,
    MNPasswordViewTypeLine
};

@class MNPasswordView;

@protocol MNPasswordViewDelegate <NSObject>
@optional
- (BOOL)passwordViewShouldBeginEditing:(MNPasswordView *)passwordView;
- (BOOL)passwordViewShouldReturn:(MNPasswordView *)passwordView;
- (void)passwordViewDidEndEditing:(MNPasswordView *)passwordView;
- (void)passwordView:(MNPasswordView *)passwordView didChangePassword:(NSString *)password;
- (UIRectEdge)passwordView:(MNPasswordView *)passwordView itemBorderEdgeOfIndex:(NSUInteger)index;
@end

@interface MNPasswordView : UIView
@property (nonatomic, weak) id<MNPasswordViewDelegate> delegate;
/**密码位数*/
@property (nonatomic) NSUInteger capacity;
/**是否密文*/
@property (nonatomic) BOOL secureTextEntry;
/**知否显示未填项*/
@property (nonatomic) BOOL animated;
/**密码*/
@property (nonatomic, copy, readonly) NSString *password;
/**类型(default MNPasswordViewTypeGrid<方格型>)*/
@property (nonatomic) MNPasswordViewType type;
/**边框宽度*/
@property (nonatomic) CGFloat borderWidth;
/**正常<未填项>颜色*/
@property (nonatomic, strong) UIColor *normalColor;
/**高亮颜色*/
@property (nonatomic, strong) UIColor *highlightColor;
/**密码颜色*/
@property (nonatomic, strong) UIColor *textColor;
/**密码字体<明文>*/
@property (nonatomic, strong) UIFont *font;
/**return键类型 default is UIReturnKeyDone*/
@property(nonatomic) UIReturnKeyType returnKeyType;
/**键盘类型 default is UIKeyboardTypeASCIICapable*/
@property(nonatomic) UIKeyboardType keyboardType;
/**键盘*/
@property(nonatomic, strong) __kindof UIView *inputView;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithFrame:(CGRect)frame capacity:(NSUInteger)capacity;

/**
 立即刷新密码
 */
- (void)updatePassword;

/**
 删除密码
 */
- (void)deleteAllPassword;

/**
 向前删除密码
 */
- (void)deleteBackward;

/**
 增加密码
 @param character 密码字符
 @return 是否增加成功
 */
- (BOOL)shouldInputPasswordCharacter:(NSString *)character;

@end



@interface MNPasswordItem : NSObject

/**序号*/
@property (nonatomic) NSUInteger index;
/**指示线*/
@property (nonatomic, weak) CALayer *shadow;
/**密文密码*/
@property (nonatomic, weak) CALayer *mask;
/**明文密码*/
@property (nonatomic, weak) UILabel *label;
/**边框*/
@property (nonatomic, weak) CAShapeLayer *border;

@end

