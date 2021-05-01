//
//  WXSession.m
//  WeChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "SESession.h"

@interface SESession ()

@end

@implementation SESession
+ (instancetype)sessionWithDictionary:(NSDictionary *)dic {
    SESession *session = SESession.new;
    session.uid = dic[@"com.ext.share.session.uid"];
    session.name = dic[@"com.ext.share.session.name"];
    session.identifier = dic[@"com.ext.share.session.identifier"];
    NSData *imageData = dic[@"com.ext.share.session.avatar"];
    session.avatar = imageData ? [UIImage imageWithData:imageData] : [UIImage imageNamed:@"ext_share_avatar"];
    return session;
}


@end
