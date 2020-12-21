//
//  WXMomentRemindViewModel.m
//  MNChat
//
//  Created by Vincent on 2019/7/23.
//  Copyright © 2019 AiZhe. All rights reserved.
//

#import "WXMomentRemindViewModel.h"
#import "WXMoment.h"

 CGFloat const WXMomentRemindCellHeight = 75.f;

@interface WXMomentRemindViewModel ()
@property (nonatomic, strong) WXMoment *moment;
@property (nonatomic, strong) WXMomentRemind *model;
@property (nonatomic, strong) WXExtendViewModel *headViewModel;
@property (nonatomic, strong) WXExtendViewModel *nameLabelModel;
@property (nonatomic, strong) WXExtendViewModel *timeLabelModel;
@property (nonatomic, strong) WXExtendViewModel *textLabelModel;
@property (nonatomic, strong) WXExtendViewModel *briefViewModel;
@end

@implementation WXMomentRemindViewModel
- (instancetype)initWithModel:(WXMomentRemind *)model {
    if (self = [super init]) {
        self.model = model;
        NSArray <WXMoment *>*rows = [[MNDatabase database] selectRowsModelFromTable:WXMomentTableName where:[@{sql_field(model.identifier):sql_pair(model.moment)} componentString] limit:NSRangeZero class:WXMoment.class];
        if (rows.count <= 0) return nil;
        WXMoment *moment = rows.firstObject;
        self.moment = moment;
        /// 字体大小
        CGFloat fontSize = 14.f;
        /// 顶部, 左右间距
        CGFloat margin = 10.f;
        /// 纵向间隔
        CGFloat interval = (WXMomentRemindCellHeight - 7.f - margin - (fontSize + 2.f)*3.f)/2.f;
        
        WXUser *from_user = [[WechatHelper helper] userForUid:model.from_uid];
        
        self.headViewModel.frame = CGRectMake(margin, margin, 45.f, 45.f);
        self.headViewModel.content = from_user.avatar;
        
        NSMutableAttributedString *attributedString;
        self.briefViewModel.frame = CGRectMake(MN_SCREEN_WIDTH - (WXMomentRemindCellHeight - margin*2.f) - margin, margin, WXMomentRemindCellHeight - margin*2.f, WXMomentRemindCellHeight - margin*2.f);
        if (moment.pictures.count > 0) {
            /// 内容图片
            WXMomentPicture *pic = moment.pictures.firstObject;
            self.briefViewModel.content = pic.image;
        } else if (moment.webpage) {
            attributedString = moment.webpage.title.attributedString.mutableCopy;
            attributedString.font = [UIFont systemFontOfSize:fontSize];
            attributedString.color = UIColorWithAlpha([UIColor darkTextColor], .85f);
            self.briefViewModel.content = attributedString.copy;
        } else {
            attributedString = moment.content.attributedString.mutableCopy;
            attributedString.font = [UIFont systemFontOfSize:fontSize];
            attributedString.color = UIColorWithAlpha([UIColor darkTextColor], .85f);
            [attributedString matchingEmojiWithFont:[UIFont systemFontOfSize:fontSize]];
            self.briefViewModel.content = attributedString.copy;
        }
        
        self.nameLabelModel.frame = CGRectMake(CGRectGetMaxX(self.headViewModel.frame) + margin, CGRectGetMinY(self.headViewModel.frame), CGRectGetMinX(self.briefViewModel.frame) - CGRectGetMaxX(self.headViewModel.frame) - margin*2.f, fontSize + 2.f);
        attributedString = from_user.name.attributedString.mutableCopy;
        attributedString.font = UIFontMedium(fontSize);
        attributedString.color = WXMomentNicknameTextColor;
        self.nameLabelModel.content = attributedString.copy;
        
        if (model.content.length) {
            /// 评论 或是 回复
            attributedString = model.content.attributedString.mutableCopy;
            attributedString.font = [UIFont systemFontOfSize:fontSize];
            attributedString.color = UIColorWithAlpha([UIColor darkTextColor], .85f);
            [attributedString matchingEmojiWithFont:[UIFont systemFontOfSize:fontSize]];
            
            if (model.to_uid.length && ![model.to_uid isEqualToString:[[WXUser shareInfo] uid]]) {
                /// 回复
                [attributedString insertString:@":" atIndex:0];
                WXUser *to_user = [[WechatHelper helper] userForUid:model.to_uid];
                NSMutableAttributedString *name = to_user.name.attributedString.mutableCopy;
                name.color = WXMomentNicknameTextColor;
                name.font = UIFontMedium(fontSize);
                [attributedString insertAttributedString:name.copy atIndex:0];
                NSMutableAttributedString *reply = @"回复了".attributedString.mutableCopy;
                reply.font = [UIFont systemFontOfSize:fontSize];
                reply.color = UIColorWithAlpha([UIColor darkTextColor], .85f);
                [attributedString insertAttributedString:reply atIndex:0];
            }
        } else {
            /// 点赞
            UIFont *font = [UIFont systemFontOfSize:fontSize];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageWithCGImage:UIImageNamed(@"wx_moment_liked").CGImage scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
            attachment.bounds = CGRectMake(0.f, font.descender, font.lineHeight, font.lineHeight);
            attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
        self.textLabelModel.content = attributedString.copy;
        CGRect textFrame = self.nameLabelModel.frame;
        textFrame.origin.y = CGRectGetMaxY(textFrame) + interval;
        self.textLabelModel.frame = textFrame;
        
        NSString *timeString =  [WechatHelper momentCreatedTimeWithTimestamp:model.date];
        attributedString = timeString.attributedString.mutableCopy;
        attributedString.font = [UIFont systemFontOfSize:fontSize];
        attributedString.color = UIColorWithAlpha([UIColor darkGrayColor], .75f);
        self.timeLabelModel.content = attributedString.copy;
        CGRect timeFrame = self.textLabelModel.frame;
        timeFrame.origin.y = CGRectGetMaxY(timeFrame) + interval;
        self.timeLabelModel.frame = timeFrame;
    }
    return self;
}

#pragma mark - Getter
- (WXExtendViewModel *)headViewModel {
    if (!_headViewModel) {
        _headViewModel = [WXExtendViewModel new];
    }
    return _headViewModel;
}

- (WXExtendViewModel *)nameLabelModel {
    if (!_nameLabelModel) {
        _nameLabelModel = [WXExtendViewModel new];
    }
    return _nameLabelModel;
}

- (WXExtendViewModel *)textLabelModel {
    if (!_textLabelModel) {
        _textLabelModel = [WXExtendViewModel new];
    }
    return _textLabelModel;
}

- (WXExtendViewModel *)timeLabelModel {
    if (!_timeLabelModel) {
        _timeLabelModel = [WXExtendViewModel new];
    }
    return _timeLabelModel;
}

- (WXExtendViewModel *)briefViewModel {
    if (!_briefViewModel) {
        _briefViewModel = [WXExtendViewModel new];
    }
    return _briefViewModel;
}

@end
