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
/**
 制作邮件
 @param recipients 收件人
 @param copier 抄送人
 @param subject 主题
 @param body 内容
 @return 邮件实例
 */
MNEmail* MNEmailCreate(NSString *recipients, NSString *copier, NSString *subject, NSString *body) {
    MNEmail *email = [MNEmail new];
    email.recipients = recipients;
    email.copier = copier;
    email.subject = subject;
    email.body = body;
    return email;
}

/**
 发送邮件
 */
- (void)send {
    if (![MFMailComposeViewController canSendMail]) return;
    if (_recipients.length <= 0 || _body.length <= 0) return;
    if (_subject.length <= 0) _subject = @"MNKit Email";
    NSMutableString *string = [[NSMutableString alloc]init];
    [string appendFormat:@"mailto:%@",_recipients];
    [string appendFormat:@"?subject=%@",_subject];
    [string appendFormat:@"&body=%@",_body];
    if (_copier.length > 0) [string appendFormat:@"&cc=%@",_copier];
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
    if (email.recipients.length <= 0 || email.body.length <= 0) return;
    if (email.subject.length <= 0) email.subject = @"MNKit Email";
    // 邮件服务器
    MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
    [compose setMailComposeDelegate:self];//代理
    [compose setSubject:email.subject]; //主题
    [compose setToRecipients:[email.recipients componentsSeparatedByString:@","]];//收件人
    if (email.copier.length >= 0) {
        [compose setCcRecipients:[email.copier componentsSeparatedByString:@","]];//抄送人
    }
    [compose setMessageBody:email.body isHTML:NO];
    /**HTML格式*/
    //@"<html><body><p>Hello</p><p>World！</p></body></html>"
    
    /*
     UIImage *image = [UIImage imageNamed:@"image"];
     NSData *imageData = UIImagePNGRepresentation(image);
     [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"custom.png"];
     
     NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"pdf"];
     NSData *pdf = [NSData dataWithContentsOfFile:file];
     [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"7天精通IOS233333"];
     */
    [self presentViewController:compose animated:YES completion:nil];
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



