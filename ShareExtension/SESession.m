//
//  WXSession.m
//  MNChat
//
//  Created by Vincent on 2019/3/24.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "SESession.h"

@interface SESession ()

@end

@implementation SESession
+ (instancetype)sessionWithSandboox:(NSDictionary *)dic {
    SESession *session = SESession.new;
    session.notename = dic[@"com.ext.share.session.name"];
    session.identifier = dic[@"com.ext.share.session.identifier"];
    session.avatar = [UIImage imageWithData:dic[@"com.ext.share.session.avatar"]];
    return session;
}


@end
