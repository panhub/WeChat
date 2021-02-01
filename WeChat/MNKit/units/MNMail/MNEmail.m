//
//  MNEmail.m
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNEmail.h"

@interface MNEmail ()

@end

@implementation MNEmail

MNEmail* MNEmailCreate(NSArray<NSString *> *recipients, NSArray<NSString *> *copiers, NSString *subject, NSString *body) {
    MNEmail *email = [MNEmail new];
    email.recipients = recipients;
    email.copiers = copiers;
    email.subject = subject;
    email.body = body;
    return email;
}

/**
 发送邮件
 */
- (void)send {
    if (![MFMailComposeViewController canSendMail]) return;
    if (!self.recipients || self.recipients.count <= 0 || self.body.length <= 0) return;
    if (self.subject.length <= 0) self.subject = @"MNKit Email";
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendFormat:@"mailto:%@", [self.recipients componentsJoinedByString:@","]];
    [string appendFormat:@"?subject=%@", self.subject];
    [string appendFormat:@"&body=%@", self.body];
    if (self.copiers.copy) [string appendFormat:@"&cc=%@", [self.copiers componentsJoinedByString:@","]];
    NSString *url = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:url];
    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

@end


@implementation UIViewController (MNEmail)
/**
 发送邮件
 @param email 邮件实例
 */
- (void)sendEmail:(MNEmail *)email {
    if (![MFMailComposeViewController canSendMail]) return;
    if (email.recipients.count <= 0 || email.body.length <= 0) return;
    if (email.subject.length <= 0) email.subject = @"MNKit Email";
    // 邮件服务器
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setMailComposeDelegate:self];//代理
    [mailController setSubject:email.subject]; //主题
    [mailController setToRecipients:email.recipients];//收件人
    if (email.copiers.count) [mailController setCcRecipients:email.copiers]; // 抄送人
    [mailController setMessageBody:email.body isHTML:NO]; // 内容
    /**HTML格式*/
    //@"<html><body><p>Hello</p><p>World！</p></body></html>"
    /*
     UIImage *image = [UIImage imageNamed:@"image"];
     NSData *imageData = UIImagePNGRepresentation(image);
     [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"custom.png"];
     
     NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
     NSData *pdf = [NSData dataWithContentsOfFile:file];
     [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"7天精通"];
     */
    [self presentViewController:mailController animated:YES completion:nil];
}

///代理回调
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled:
        {
            NSLog(@"用户取消编辑");
        } break;
        case MFMailComposeResultSaved:
        {
            NSLog(@"用户保存邮件");
        } break;
        case MFMailComposeResultSent:
        {
            NSLog(@"用户点击发送");
        } break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"发送邮件失败: error: %@", [error localizedDescription]);
        } break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end



