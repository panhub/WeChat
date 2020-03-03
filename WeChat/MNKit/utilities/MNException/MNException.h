//
//  MNExceptionHandler.h
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNException : NSObject

/**设置异常邮件的收件人*/
void MNExceptionEmailSetRecipients (NSString *recipients);

/**UncaughtException*/
void MNInstallUncaughtExceptionHandler(void);
void MNUninstallUncaughtExceptionHandler(void);

/**SignalException*/
void MNInstallSignalExceptionHandler(void);



@end
