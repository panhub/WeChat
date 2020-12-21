//
//  MNWebUserContentController.m
//  SQB_ScreenShot
//
//  Created by Vincent on 2019/2/14.
//  Copyright © 2019年 AiZhe. All rights reserved.
//

#import "MNWebUserContentController.h"

@interface MNWebUserContentController ()

@property (nonatomic, strong)  NSMutableArray <NSString *>*messageNames;

@end

@implementation MNWebUserContentController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageNames = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)addScriptMessageToController:(WKUserContentController *)controller name:(NSString *)name {
    if (!controller || name.length <= 0) return;
    [self removeScriptMessageInController:controller name:name];
    [self.messageNames addObject:name];
    [controller addScriptMessageHandler:self name:name];
}

- (void)removeScriptMessageInController:(WKUserContentController *)controller name:(NSString *)name {
    if (!controller || name.length <= 0) return;
    if ([self.messageNames containsObject:name]) {
        [self.messageNames removeObject:name];
        [controller removeScriptMessageHandlerForName:name];
    }
}

- (void)removeAllScriptMessageInController:(WKUserContentController *)controller {
    if (self.messageNames.count <= 0 || !controller) return;
    [self.messageNames enumerateObjectsUsingBlock:^(NSString * _Nonnull message, NSUInteger idx, BOOL * _Nonnull stop) {
        [controller removeScriptMessageHandlerForName:message];
    }];
    [self.messageNames removeAllObjects];
    [controller removeAllUserScripts];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
