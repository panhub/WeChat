//
//  WXMomentViewModel.m
//  WeChat
//
//  Created by Vincent on 2019/4/30.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentViewModel.h"
#import "WechatHelper.h"
#import "WXMomentLikedViewModel.h"
#import "WXMomentCommentViewModel.h"
#import "WXMomentReplyViewModel.h"
#import "WXUser.h"
#import "WXLocation.h"
#import "WXTimeline.h"

@interface WXMomentViewModel ()
@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) WXMoment *moment;
@property (nonatomic, strong) NSMutableArray <WXMomentEventViewModel *>*dataSource;
@end

#define WXMomentContentExpandedLimitHeight  143.f

@implementation WXMomentViewModel

- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super init]) {
        self.moment = moment;
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
        
        CGFloat x = WXMomentContentLeftOrRightMargin;
        CGFloat y = WXMomentAvatarTopMargin;
        CGFloat x2 = x + WXMomentAvatarWH + WXMomentContentLeftMargin;
        CGFloat width = WXMomentContentWidth;
        
        WXUser *user = [[WechatHelper helper] userForUid:moment.uid];
        
        /// 头像
        self.avatarViewModel.frame = CGRectMake(x, y, WXMomentAvatarWH, WXMomentAvatarWH);
        self.avatarViewModel.content = moment.user.avatar;
        
        /// 昵称
        if (user) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:user.name];
            string.font = WXMomentNicknameFont;
            string.color = WXMomentNicknameTextColor;
            self.nicknameViewModel.content = string.copy;
            self.nicknameViewModel.frame = (CGRect){x2, y, [string sizeOfLimitWidth:WXMomentContentWidth]};
        } else {
            self.nicknameViewModel.frame = CGRectMake(x2, y, 0.f, WXMomentNicknameFont.pointSize);
        }
        
        /// 正文
        if (moment.content.length > 0) {
            //moment.content
            //NSString *s = @"啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊\n啊啊啊啊啊啊";
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moment.content];
            [string matchingEmojiWithFont:WXMomentContentTextFont];
            [string addAttribute:NSFontAttributeName value:WXMomentContentTextFont range:string.rangeOfAll];
            [string addAttribute:NSForegroundColorAttributeName value:WXMomentContentTextColor range:string.rangeOfAll];
            self.contentViewModel.content = string.copy;
            CGSize contentSize = [string sizeOfLimitWidth:width];
            contentSize.width = width;
            contentSize.height = ceil(contentSize.height);
            self.contentSize = contentSize;
        }

        /// 分享网页
        self.webViewFrame = CGRectMake(x2, 0.f, width, (self.moment.webpage ? WXMomentWebpageHeight : 0.f));
        
        /// 图片
        self.pictureViewFrame = (CGRect){CGPointMake(x2, 0.f), WXMomentPictureViewSize(self.moment.profiles)};
        
        /// 更多
        self.moreButtonFrame = CGRectMake(x2 + width - WXMomentMoreButtonWidth, 0.f, WXMomentMoreButtonWidth, WXMomentMoreButtonHeight);
        
        /// 位置
        if (moment.location.length > 0) {
            WXLocation *location = moment.location.locationValue;
            if (location) {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:location.debugDescription];
                string.font = WXMomentContentInnerFont;
                string.color = WXMomentLocationTextColor;
                self.locationViewModel.content = string.copy;
                self.locationViewModel.frame = (CGRect){x2, 0.f, [string sizeOfLimitWidth:WXMomentContentWidth]};
                self.locationViewModel.extend = location;
            } else {
                self.locationViewModel.frame = CGRectZero;
            }
        } else {
            self.locationViewModel.frame = CGRectZero;
        }
        
        /// 来源
        if (moment.source.length > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moment.source];
            string.font = WXMomentContentInnerFont;
            string.color = WXMomentSourceTextColor;
            self.sourceViewModel.content = string.copy;
            self.sourceViewModel.frame = (CGRect){CGPointZero, [string sizeOfLimitWidth:WXMomentContentWidth]};
        } else {
            self.sourceViewModel.frame = CGRectZero;
        }
    
        /// 隐私
        if (moment.isMine && moment.isPrivacy) {
            self.privacyViewModel.frame = CGRectMake(0.f, 0.f, WXMomentPrivacyViewWH, WXMomentPrivacyViewWH);
        } else {
            self.privacyViewModel.frame = CGRectMake(0.f, 0.f, 0.f, WXMomentPrivacyViewWH);
        }
        
        /// 删除
        if (moment.isMine) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"删除"];
            string.font = WXMomentContentInnerFont;
            string.color = WXMomentDeleteTextColor;
            self.deleteViewModel.content = string.copy;
            self.deleteViewModel.frame = (CGRect){CGPointZero, [string sizeOfLimitWidth:WXMomentContentWidth]};
        } else {
            self.deleteViewModel.frame = CGRectZero;
        }
        
        /// 点赞
        if (moment.likes.count > 0) {
            WXMomentLikedViewModel *viewModel = [[WXMomentLikedViewModel alloc] initWithMoment:moment];
            [self.dataSource addObject:viewModel];
        }
        
        /// 评论
        if (moment.comments.count > 0) {
            [moment.comments enumerateObjectsUsingBlock:^(WXComment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WXMomentCommentViewModel *viewModel = [[WXMomentCommentViewModel alloc] initWithComment:obj];
                [self.dataSource addObject:viewModel];
            }];
        }
        
        /// 约束子视图
        [self updateLayout];
    }
    return self;
}

- (void)updateLayout {
    CGFloat x = WXMomentContentLeftOrRightMargin + WXMomentAvatarWH + WXMomentContentLeftMargin;
    if (self.isExpand) {
        /// 展开状态时, 直接显示
        self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.contentSize.width, self.contentSize.height);
        NSMutableAttributedString *expandString = [[NSMutableAttributedString alloc] initWithString:@"收起"];
        expandString.font = WXMomentExpandButtonTitleFont;
        expandString.color = WXMomentNicknameTextColor;
        self.expandViewModel.content = expandString.copy;
        self.expandViewModel.frame = (CGRect){x, CGRectGetMaxY(self.contentViewModel.frame) + WXMomentInnerViewMargin, [expandString sizeOfLimitWidth:WXMomentContentWidth]};
    } else {
        /// 判断内容高度是否超过标准, 需要显示 全文/收起 按钮
        if (self.contentSize.height > WXMomentContentExpandedLimitHeight) {
            /// 全文
            self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.contentSize.width, WXMomentContentExpandedLimitHeight);
            NSMutableAttributedString *expandString = [[NSMutableAttributedString alloc] initWithString:@"全文"];
            expandString.font = WXMomentExpandButtonTitleFont;
            expandString.color = WXMomentNicknameTextColor;
            self.expandViewModel.content = expandString.copy;
            self.expandViewModel.frame = (CGRect){x, CGRectGetMaxY(self.contentViewModel.frame) + WXMomentInnerViewMargin, [expandString sizeOfLimitWidth:WXMomentContentWidth]};
        } else {
            /// 隐藏
            self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.contentSize.width, self.contentSize.height);
            self.expandViewModel.content = [[NSAttributedString alloc] initWithString:@""];
            self.expandViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.contentViewModel.frame) + WXMomentInnerViewMargin, 0.f, 0.f);
        }
    }
    // 网页分享
    CGRect temp = self.webViewFrame;
    CGFloat margin = self.expandViewModel.frame.size.height > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.y = CGRectGetMaxY(self.expandViewModel.frame) + margin;
    self.webViewFrame = temp;
    /// 配图<配图与分享一般只用其一>
    temp = self.pictureViewFrame;
    margin = self.webViewFrame.size.height > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.y = CGRectGetMaxY(self.webViewFrame) + margin;
    self.pictureViewFrame = temp;
    /// 位置
    temp = self.locationViewModel.frame;
    margin = (self.webViewFrame.size.height + self.pictureViewFrame.size.height > 0.f) ? WXMomentLocationTopMargin : 0.f;
    temp.origin.y = (self.webViewFrame.size.height > 0.f ? CGRectGetMaxY(self.webViewFrame) : CGRectGetMaxY(self.pictureViewFrame)) + margin;
    self.locationViewModel.frame = temp;
    /// 时间
    self.timeViewModel.content = self.createdTimeString;
    temp = [self.timeViewModel.content boundingRectWithSize:CGSizeMake(WXMomentContentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    temp.origin.x = x;
    if (self.locationViewModel.frame.size.height > 0.f) {
        temp.origin.y = CGRectGetMaxY(self.locationViewModel.frame) + WXMomentInnerViewMargin;
    } else {
        margin = (self.webViewFrame.size.height + self.pictureViewFrame.size.height > 0.f) ? WXMomentInnerViewMargin : 0.f;
        temp.origin.y = (self.webViewFrame.size.height > 0.f ? CGRectGetMaxY(self.webViewFrame) : CGRectGetMaxY(self.pictureViewFrame)) + margin;
    }
    self.timeViewModel.frame = temp;
    /// 来源
    temp = self.sourceViewModel.frame;
    margin = self.timeViewModel.frame.size.width > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.x = CGRectGetMaxX(self.timeViewModel.frame) + margin;
    temp.origin.y = CGRectGetMinY(self.timeViewModel.frame);
    self.sourceViewModel.frame = temp;
    /// 隐私
    temp = self.privacyViewModel.frame;
    margin = self.sourceViewModel.frame.size.width > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.x = CGRectGetMaxX(self.sourceViewModel.frame) + margin;
    temp.origin.y = CGRectGetMinY(self.timeViewModel.frame) + (self.timeViewModel.frame.size.height - temp.size.height)/2.f;
    self.privacyViewModel.frame = temp;
    /// 删除
    temp = self.deleteViewModel.frame;
    margin = self.privacyViewModel.frame.size.width > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.x = CGRectGetMaxX(self.privacyViewModel.frame) + margin;
    temp.origin.y = CGRectGetMinY(self.timeViewModel.frame);
    self.deleteViewModel.frame = temp;
    /// 更多按钮
    temp = self.moreButtonFrame;
    temp.origin.y = CGRectGetMinY(self.timeViewModel.frame) + (CGRectGetHeight(self.timeViewModel.frame) - CGRectGetHeight(self.moreButtonFrame))/2.f;
    self.moreButtonFrame = temp;
    /// 箭头
    if (self.dataSource.count > 0) {
        self.arrowViewFrame = CGRectMake(x, CGRectGetMaxY(self.moreButtonFrame) + WXMomentArrowViewTopMargin, WXMomentArrowViewWidth, WXMomentArrowViewHeight);
    } else {
        self.arrowViewFrame = CGRectMake(x, CGRectGetMaxY(self.moreButtonFrame), WXMomentArrowViewWidth, 0.f);
    }
    /// 视图高度
    self.height = CGRectGetMaxY(self.arrowViewFrame);
}

#pragma mark - 评论或回复
- (void)replyMomentWithModel:(WXMomentReplyViewModel *)replyModel {
    if (replyModel.content.length <= 0) return;
    // 评论数据模型
    WXComment *comment = [WXComment new];
    comment.from_uid = replyModel.fromUser.uid;
    comment.to_uid = replyModel.toUser ? replyModel.toUser.uid : @"";
    comment.content = replyModel.content;
    comment.identifier = NSDate.shortTimestamps;
    comment.timestamp = NSDate.timestamps;
    comment.moment = self.moment.identifier;
    // 添加数据库
    if ([MNDatabase.database insertToTable:WXMomentCommentTableName model:comment]) {
        // 添加数据
        [self.moment.comments addObject:comment];
        // 评论视图模型
        WXMomentCommentViewModel *vm = [[WXMomentCommentViewModel alloc] initWithComment:comment];
        [self.dataSource addObject:vm];
        // 更新约束信息
        [self updateLayout];
        // 回调刷新
        if (self.reloadMomentEventHandler) {
            self.reloadMomentEventHandler(self, NO);
        }
        if (self.moment.isMine && comment.to_uid.length <= 0 && ![comment.from_uid isEqualToString:WXUser.shareInfo.uid]) {
            if (self.didInsertCommentEventHandler) self.didInsertCommentEventHandler(comment);
        }
    }
}

#pragma mark - 删除评论
- (void)deleteComment:(WXMomentCommentViewModel *)viewModel {
    if (!viewModel || viewModel.type != WXMomentEventTypeComment) return;
    WXComment *comment = viewModel.comment;
    if ([MNDatabase.database deleteRowFromTable:WXMomentCommentTableName where:@{sql_field(comment.identifier):sql_pair(comment.identifier)}.sqlQueryValue]) {
        [self.dataSource removeObject:viewModel];
        [self.moment.comments removeObject:viewModel.comment];
        /// 更新约束信息
        [self updateLayout];
        /// 回调刷新数据
        if (self.reloadMomentEventHandler) {
            self.reloadMomentEventHandler(self, NO);
        }
        /// 回调数据, 便于删除提醒事项
        if (self.moment.isMine && comment.to_uid.length <= 0 && ![comment.from_uid isEqualToString:WXUser.shareInfo.uid]) {
            if (self.didDeleteCommentEventHandler) self.didDeleteCommentEventHandler(comment);
        }
    }
}

#pragma mark - 点赞
- (void)updateLike {
    NSArray <WXLike *>*likes = [self.moment.likes.copy filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", WXUser.shareInfo.uid]];
    if (likes.count) {
        [likes enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([MNDatabase.database deleteRowFromTable:WXMomentLikeTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue]) {
                [self.moment.likes removeObject:obj];
            }
        }];
    } else {
        WXLike *like = [[WXLike alloc] initWithUid:WXUser.shareInfo.uid];
        like.moment = self.moment.identifier;
        if ([MNDatabase.database insertToTable:WXMomentLikeTableName model:like]) {
            [self.moment.likes insertObject:like atIndex:0];
        }
    }
    // 修改视图模型
    if (self.moment.likes.count) {
        WXMomentLikedViewModel *vm = [[WXMomentLikedViewModel alloc] initWithMoment:self.moment];
        if (self.dataSource.count <= 0) {
            /// 没有数据直接添加即可
            [self.dataSource addObject:vm];
        } else {
            /// 判断已有数据模型
            if ([self.dataSource.firstObject isKindOfClass:WXMomentLikedViewModel.class]) {
                [self.dataSource replaceObjectAtIndex:0 withObject:vm];
            } else {
                [self.dataSource insertObject:vm atIndex:0];
            }
        }
    } else {
        if (self.dataSource.count > 0 && [self.dataSource.firstObject isKindOfClass:WXMomentLikedViewModel.class]) {
            [self.dataSource removeObjectAtIndex:0];
        }
    }
    /// 更新约束信息
    [self updateLayout];
    /// 回调刷新视图
    if (self.reloadMomentEventHandler) {
        self.reloadMomentEventHandler(self, NO);
    }
}

- (void)reloadLikes:(NSArray <WXUser *>*)array {
    NSMutableArray <WXLike *>*dels = @[].mutableCopy;
    NSMutableArray <WXLike *>*adds = @[].mutableCopy;
    NSMutableArray <WXUser *>*users = array.mutableCopy;
    NSMutableArray <WXUser *>*deletes = @[].mutableCopy;
    [self.moment.likes.copy enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray <WXUser *>*result = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.uid == %@", obj.uid]];
        if (result.count) {
            [deletes addObjectsFromArray:result];
        } else {
            [dels addObject:obj];
        }
    }];
    [dels enumerateObjectsUsingBlock:^(WXLike * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([MNDatabase.database deleteRowFromTable:WXMomentLikeTableName where:@{sql_field(obj.identifier):sql_pair(obj.identifier)}.sqlQueryValue]) {
            [self.moment.likes removeObject:obj];
        }
    }];
    [users removeObjectsInArray:deletes];
    [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WXLike *like = [[WXLike alloc] initWithUid:obj.uid];
        like.moment = self.moment.identifier;
        if ([MNDatabase.database insertToTable:WXMomentLikeTableName model:like]) {
            [adds insertObject:like atIndex:0];
        }
    }];
    [self.moment.likes insertObjects:adds fromIndex:0];
    
    // 修改视图模型
    if (self.dataSource.count) {
        if (self.dataSource.firstObject.type == WXMomentEventTypeLiked) {
            if (self.moment.likes.count) {
                [((WXMomentLikedViewModel *)self.dataSource.firstObject) updateLayout];
            } else {
                [self.dataSource removeObjectAtIndex:0];
            }
        } else {
            if (self.moment.likes.count) {
                [self.dataSource insertObject:[[WXMomentLikedViewModel alloc] initWithMoment:self.moment] atIndex:0];
            }
        }
    } else {
        if (self.moment.likes.count) {
            [self.dataSource addObject:[[WXMomentLikedViewModel alloc] initWithMoment:self.moment]];
        }
    }
    
    /*
    if (self.moment.likes.count) {
        WXMomentLikedViewModel *vm = [[WXMomentLikedViewModel alloc] initWithMoment:self.moment];
        if (self.dataSource.count <= 0) {
            // 没有数据直接添加即可
            [self.dataSource addObject:vm];
        } else {
            // 判断已有数据模型
            if ([self.dataSource.firstObject isKindOfClass:WXMomentLikedViewModel.class]) {
                [self.dataSource replaceObjectAtIndex:0 withObject:vm];
            } else {
                [self.dataSource insertObject:vm atIndex:0];
            }
        }
    } else {
        if (self.dataSource.count > 0 && [self.dataSource.firstObject isKindOfClass:WXMomentLikedViewModel.class]) {
            [self.dataSource removeObjectAtIndex:0];
        }
    }
    */
    
    /// 更新约束信息
    [self updateLayout];
    /// 回调刷新视图
    if (self.reloadMomentEventHandler) {
        self.reloadMomentEventHandler(self, NO);
    }
    /// 自己的朋友圈还要分析新增和删除的点赞人, 刷新提醒事项
    if (self.moment.isMine && self.didUpdateLikesEventHandler) {
        self.didUpdateLikesEventHandler(self);
    }
}

#pragma mark - 全文/收起
- (void)expandContentIfNeeded {
    self.expand = !self.isExpand;
    // 更新约束
    [self updateLayout];
    // 回调刷新数据
    if (self.reloadMomentEventHandler) {
        self.reloadMomentEventHandler(self, NO);
    }
}

#pragma mark - Getter
- (WXExtendViewModel *)avatarViewModel {
    if (!_avatarViewModel) {
        _avatarViewModel = [WXExtendViewModel new];
        _avatarViewModel.content = self.moment.user.avatar;
    }
    return _avatarViewModel;
}

- (WXExtendViewModel *)nicknameViewModel {
    if (!_nicknameViewModel) {
        _nicknameViewModel = [WXExtendViewModel new];
    }
    return _nicknameViewModel;
}

- (WXExtendViewModel *)contentViewModel {
    if (!_contentViewModel) {
        _contentViewModel = [WXExtendViewModel new];
    }
    return _contentViewModel;
}

- (WXExtendViewModel *)expandViewModel {
    if (!_expandViewModel) {
        _expandViewModel = [WXExtendViewModel new];
    }
    return _expandViewModel;
}

- (WXExtendViewModel *)locationViewModel {
    if (!_locationViewModel) {
        _locationViewModel = [WXExtendViewModel new];
    }
    return _locationViewModel;
}

- (WXExtendViewModel *)timeViewModel {
    if (!_timeViewModel) {
        _timeViewModel = [WXExtendViewModel new];
    }
    return _timeViewModel;
}

- (WXExtendViewModel *)sourceViewModel {
    if (!_sourceViewModel) {
        _sourceViewModel = [WXExtendViewModel new];
    }
    return _sourceViewModel;
}

- (WXExtendViewModel *)privacyViewModel {
    if (!_privacyViewModel) {
        _privacyViewModel = [WXExtendViewModel new];
    }
    return _privacyViewModel;
}

- (WXExtendViewModel *)deleteViewModel {
    if (!_deleteViewModel) {
        _deleteViewModel = [WXExtendViewModel new];
    }
    return _deleteViewModel;
}

- (NSAttributedString *)createdTimeString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[WechatHelper momentTimeWithTimestamp:self.moment.timestamp]];
    string.font = WXMomentContentInnerFont;
    string.color = WXMomentCreatedTimeTextColor;
    return string.copy;
}

@end
