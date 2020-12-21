//
//  MNEmail.h
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//  邮件发送者

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MNEmail : NSObject

/**收件人(多位用","分割)*/
@property (nonatomic, copy, readwrite) NSString *recipients;
/**抄送人*/
@property (nonatomic, copy, readwrite) NSString *copier;
/**主题*/
@property (nonatomic, copy, readwrite) NSString *subject;
/**内容*/
@property (nonatomic, copy, readwrite) NSString *body;

/**快速构建*/

MNEmail* MNEmailCreate(NSString *recipients, NSString *copier, NSString *subject, NSString *body);

/**发送邮件*/
- (void)send;

@end



@interface UIViewController (MNEmail)<MFMailComposeViewControllerDelegate>

/**发送邮件*/
- (void)sendEmail:(MNEmail *)email;

@end

