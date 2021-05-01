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
FOUNDATION_EXPORT void MNExceptionEmailSetRecipient (NSString *_Nullable);

/**UncaughtException*/
FOUNDATION_EXPORT void MNInstallUncaughtExceptionHandler(void);
FOUNDATION_EXPORT void MNUninstallUncaughtExceptionHandler(void);

/**SignalException*/
FOUNDATION_EXPORT void MNInstallSignalExceptionHandler(void);

@end
