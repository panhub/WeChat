//
//  MNLogModel.m
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLogModel.h"

#define MNLogOutputMargin   10.f

@implementation MNLogModel

+ (instancetype)modelWithLog:(NSString *)log {
    MNLogModel *model = [MNLogModel new];
    model.log = log;
    return model;
}

- (void)setLog:(NSString *)log {
    _log = log.copy;
    if (_log.length <= 0) {
        self->_height = 0.f;
        self->_contentRect = CGRectZero;
        self->_attributedLog = nil;
        return;
    }
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:_log attributes:MNLogOutputAttributed()];
    CGSize size = [string sizeOfLimitWidth:MN_SCREEN_WIDTH - MNLogOutputMargin*2.f];
    self->_contentRect = CGRectMake(MNLogOutputMargin, MNLogOutputMargin, size.width, size.height);
    self->_height = size.height + MNLogOutputMargin*2.f;
    self->_attributedLog = string.copy;
}

static NSDictionary * MNLogOutputAttributed (void) {
    static NSDictionary *_logOutputAttributed;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineSpacing = 1.f;
        _logOutputAttributed = @{NSFontAttributeName:[UIFont systemFontOfSize:13.f], NSForegroundColorAttributeName:[[UIColor darkTextColor] colorWithAlphaComponent:.88f], NSParagraphStyleAttributeName:paragraph};
    });
    return _logOutputAttributed;
}

@end
