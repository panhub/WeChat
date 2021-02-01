//
//  MNEmail.h
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//  邮件发送者

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface MNEmail : NSObject

/**收件人(多位用","分割)*/
@property (nonatomic, copy) NSArray<NSString *> *recipients;
/**抄送人*/
@property (nonatomic, copy, nullable) NSArray<NSString *> *copiers;
/**主题*/
@property (nonatomic, copy, nullable) NSString *subject;
/**内容*/
@property (nonatomic, copy) NSString *body;

/**
 制作邮件
 @param recipients 收件人
 @param copiers 抄送人
 @param subject 主题
 @param body 内容
 @return 邮件实例
 */
FOUNDATION_EXPORT MNEmail * MNEmailCreate(NSArray<NSString *> *recipients, NSArray<NSString *> *copiers, NSString *subject, NSString *body);

/**发送邮件*/
- (void)send;

@end



@interface UIViewController (MNEmail)<MFMailComposeViewControllerDelegate>

/**发送邮件*/
- (void)sendEmail:(MNEmail *)email;

@end

NS_ASSUME_NONNULL_END
