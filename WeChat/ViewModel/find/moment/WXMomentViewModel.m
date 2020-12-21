//
//  WXMomentViewModel.m
//  MNChat
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

@interface WXMomentViewModel ()
@property (nonatomic) CGSize content_size;
@property (nonatomic, strong) WXMoment *moment;
@property (nonatomic, strong) NSMutableArray <WXMomentItemViewModel *>*dataSource;
@end

#define WXMomentContentExpandedLimitHeight  143.f

@implementation WXMomentViewModel

- (instancetype)initWithMoment:(WXMoment *)moment {
    if (self = [super init]) {
        self.moment = moment;
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
        
        CGFloat x = WXMomentContentLeftOrRightMargin;
        CGFloat y = WXMomentAvatarTopMargin;
        CGFloat x2 = x + WXMomentAvatarWH + WXMomentTextLeftMargin;
        CGFloat width = WXMomentContentWidth();
        
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
            self.nicknameViewModel.frame = (CGRect){x2, y, [string sizeOfLimitWidth:WXMomentContentWidth()]};
        } else {
            self.nicknameViewModel.frame = CGRectMake(x2, y, 0.f, WXMomentNicknameFont.pointSize);
        }
        
        /// 正文
        if (moment.content.length > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moment.content];
            [string matchingEmojiWithFont:WXMomentContentTextFont];
            [string addAttribute:NSFontAttributeName value:WXMomentContentTextFont range:string.rangeOfAll];
            [string addAttribute:NSForegroundColorAttributeName value:WXMomentContentTextColor range:string.rangeOfAll];
            self.contentViewModel.content = string.copy;
            self.content_size = [moment.content boundingSize:CGSizeMake(width, CGFLOAT_MAX) attributes:@{NSFontAttributeName:WXMomentContentTextFont, NSForegroundColorAttributeName:WXMomentContentTextColor}];
        }

        /// 分享网页
        self.webViewFrame = CGRectMake(x2, 0.f, width, (self.moment.webpage ? WXMomentWebpageHeight : 0.f));
        
        /// 图片
        self.pictureViewFrame = (CGRect){CGPointMake(x2, 0.f), [self pictureViewSize]};
        
        /// 更多
        self.moreButtonFrame = CGRectMake(x2 + width - WXMomentMoreButtonWidth, 0.f, WXMomentMoreButtonWidth, WXMomentMoreButtonHeight);
        
        /// 位置
        if (moment.location.length > 0) {
            NSArray *components = [moment.location componentsSeparatedByString:WXDataSeparatedSign];
            if (components.count > 0) {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[components firstObject]];
                string.font = WXMomentContentInnerFont;
                string.color = WXMomentLocationTextColor;
                self.locationViewModel.content = string.copy;
                self.locationViewModel.frame = (CGRect){x2, 0.f, [string sizeOfLimitWidth:WXMomentContentWidth()]};
                if (components.count >= 3) {
                    /// 位置描述
                    self.locationViewModel.extend = [WXMapLocation pointWithLatitude:[components[1] doubleValue] longitude:[components[2] doubleValue]];
                }
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
            self.sourceViewModel.frame = (CGRect){CGPointZero, [string sizeOfLimitWidth:WXMomentContentWidth()]};
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
            self.deleteViewModel.frame = (CGRect){CGPointZero, [string sizeOfLimitWidth:WXMomentContentWidth()]};
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
            [moment.comments enumerateObjectsUsingBlock:^(WXMomentComment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                WXMomentCommentViewModel *viewModel = [[WXMomentCommentViewModel alloc] initWithComment:obj];
                [self.dataSource addObject:viewModel];
            }];
        }
        
        /// 约束子视图
        [self updateLayout];
    }
    return self;
}

/// 配图尺寸
- (CGSize)pictureViewSize {
    NSUInteger count = self.moment.pictures.count;
    if (self.moment.pictures.count <= 0) return CGSizeZero;
    CGFloat width = WXMomentPictureItemWidth();
    if (count == 1) {
        CGSize picSize = CGSizeZero;
        CGFloat maxWidth = WXMomentSinglePictureMaxWidth();
        CGFloat maxHeight = WXMomentSinglePictureMaxHeight;
        WXMomentPicture *pic = self.moment.pictures.firstObject;
        CGSize size = pic.image.size;
        if (size.width < size.height) {
            picSize.height = maxHeight;
            picSize.width = (float)size.width/(float)size.height*maxHeight;
        } else {
            picSize.width = maxWidth;
            picSize.height = (float)size.height/(float)size.width*maxWidth;
        }
        return picSize;
    }
    /// 大于1的情况 统统显示 九宫格样式
    NSUInteger maxCols = WXMomentPictureMaxCols(count);
    // 总列数
    NSUInteger totalCols = count >= maxCols ?  maxCols : count;
    // 总行数
    NSUInteger totalRows = (count + maxCols - 1)/maxCols;
    // 计算尺寸
    CGFloat W = totalCols*width + (totalCols - 1)*WXMomentPictureItemInnerMargin;
    CGFloat H = totalRows*width + (totalRows - 1)*WXMomentPictureItemInnerMargin;
    return CGSizeMake(W, H);
}

- (void)updateLayout {
    CGFloat x = WXMomentContentLeftOrRightMargin + WXMomentAvatarWH + WXMomentTextLeftMargin;
    if (self.isExpand) {
        /// 展开状态时, 直接显示
        self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.content_size.width, self.content_size.height);
        NSMutableAttributedString *expandString = [[NSMutableAttributedString alloc] initWithString:@"收起"];
        expandString.font = WXMomentExpandButtonTitleFont;
        expandString.color = WXMomentNicknameTextColor;
        self.expandViewModel.content = expandString.copy;
        self.expandViewModel.frame = (CGRect){x, CGRectGetMaxY(self.contentViewModel.frame) + WXMomentInnerViewMargin, [expandString sizeOfLimitWidth:WXMomentContentWidth()]};
    } else {
        /// 判断内容高度是否超过标准, 需要显示 全文/收起 按钮
        if (self.content_size.height > WXMomentContentExpandedLimitHeight) {
            /// 全文
            self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.content_size.width, WXMomentContentExpandedLimitHeight);
            NSMutableAttributedString *expandString = [[NSMutableAttributedString alloc] initWithString:@"全文"];
            expandString.font = WXMomentExpandButtonTitleFont;
            expandString.color = WXMomentNicknameTextColor;
            self.expandViewModel.content = expandString.copy;
            self.expandViewModel.frame = (CGRect){x, CGRectGetMaxY(self.contentViewModel.frame) + WXMomentInnerViewMargin, [expandString sizeOfLimitWidth:WXMomentContentWidth()]};
        } else {
            /// 隐藏
            self.contentViewModel.frame = CGRectMake(x, CGRectGetMaxY(self.nicknameViewModel.frame) + WXMomentContentTopMargin, self.content_size.width, self.content_size.height);
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
    margin = self.pictureViewFrame.size.height > 0.f ? WXMomentLocationTopMargin : 0.f;
    temp.origin.y = CGRectGetMaxY(self.pictureViewFrame) + margin;
    self.locationViewModel.frame = temp;
    /// 时间
    self.timeViewModel.content = self.createdTimeString;
    temp = [self.timeViewModel.content boundingRectWithSize:CGSizeMake(WXMomentContentWidth(), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    margin = self.locationViewModel.frame.size.height > 0.f ? WXMomentInnerViewMargin : 0.f;
    temp.origin.x = x;
    temp.origin.y = CGRectGetMaxY(self.locationViewModel.frame) + margin;
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
    if (!replyModel.indexPath || replyModel.content.length <= 0) return;
    NSInteger row = replyModel.indexPath.row;
    if (row == NSIntegerMin) {
        /// 评论模型
        WXMomentComment *comment = [WXMomentComment new];
        comment.from_uid = replyModel.from_user.uid;
        comment.to_uid = replyModel.to_user.uid;
        comment.content = replyModel.content;
        comment.identifier = [MNFileHandle fileName];
        comment.date = [NSDate timestamps];
        [self.moment.comments addObject:comment];
        /// 评论视图模型
        WXMomentCommentViewModel *vm = [[WXMomentCommentViewModel alloc] initWithComment:comment];
        [self.dataSource addObject:vm];
        /// 更新约束信息
        [self updateLayout];
        /// 回调刷新数据
        if (self.reloadMomentEventHandler) {
            self.reloadMomentEventHandler(self, NO);
        }
        /// 向数据库插入评论模型
        NSString *identifier = comment.identifier;
        [MNDatabase insertToTable:WXMomentCommentTableName model:comment completion:^(BOOL succeed) {
            if (!succeed) return;
            if (self.moment.comment.length > 0) {
                /// 添加评论id
                NSMutableString *string = self.moment.comment.mutableCopy;
                [string appendString:WXDataSeparatedSign];
                [string appendString:identifier];
                self.moment.comment = string.copy;
            } else {
                self.moment.comment = comment.identifier;
            }
            /// 更新数据库内朋友圈数据
            [MNDatabase updateTable:WXMomentTableName
                               where:[@{@"identifier":sql_pair(self.moment.identifier)} componentString]
                              fields:@{@"comment":self.moment.comment}
                          completion:nil];
            /// 回调数据, 便于添加提醒事项
            dispatch_async_main(^{
                if (self.moment.isMine && self.didInsertCommentEventHandler) {
                    self.didInsertCommentEventHandler(self, comment);
                }
            });
        }];
    } else if (row < self.dataSource.count) {
        /// 回复
        WXMomentComment *comment = [WXMomentComment new];
        comment.from_uid = replyModel.from_user.uid;
        comment.to_uid = replyModel.to_user.uid;
        comment.content = replyModel.content;
        comment.identifier = [MNFileHandle fileName];
        comment.date = [NSDate timestamps];
        NSInteger rows = row;
        if (self.moment.likes.count <= 0) rows ++;
        [self.moment.comments insertObject:comment atIndex:rows];
        WXMomentCommentViewModel *vm = [[WXMomentCommentViewModel alloc] initWithComment:comment];
        [self.dataSource insertObject:vm atIndex:(row + 1)];
        /// 更新约束信息
        [self updateLayout];
        /// 回调刷新数据
        if (self.reloadMomentEventHandler) {
            self.reloadMomentEventHandler(self, NO);
        }
        /// 向数据库插入评论模型
        NSString *identifier = comment.identifier;
        [MNDatabase insertToTable:WXMomentCommentTableName model:comment completion:^(BOOL succeed) {
            if (!succeed) return;
            if (self.moment.comment.length > 0) {
                /// 添加评论id
                NSMutableArray *array = [self.moment.comment componentsSeparatedByString:WXDataSeparatedSign].mutableCopy;
                if (array.count > row) {
                    [array insertObject:identifier atIndex:rows];
                } else {
                    [array addObject:identifier];
                }
                self.moment.comment = [array componentsJoinedByString:WXDataSeparatedSign];
            } else {
                self.moment.comment = comment.identifier;
            }
            /// 更新数据库内朋友圈数据
            [MNDatabase updateTable:WXMomentTableName
                               where:[@{@"identifier":sql_pair(self.moment.identifier)} componentString]
                              fields:@{@"comment":self.moment.comment}
                          completion:nil];
            /// 回调数据, 便于添加提醒事项
            dispatch_async_main(^{
                if (self.moment.isMine && ![comment.from_uid isEqualToString:[[WXUser shareInfo] uid]] && self.didInsertCommentEventHandler) {
                    self.didInsertCommentEventHandler(self, comment);
                }
            });
        }];
    }
}

#pragma mark - 删除评论
- (void)deleteCommentAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataSource.count) return;
    WXMomentItemViewModel *model = self.dataSource[indexPath.row];
    if (model.type == WXMomentItemTypeLiked) return;
    WXMomentCommentViewModel *viewModel = (WXMomentCommentViewModel *)model;
    [self.dataSource removeObjectAtIndex:indexPath.row];
    if (self.moment.likes.count > 0) {
        if (indexPath.row > 0 && self.moment.comments.count > (indexPath.row - 1)) {
            [self.moment.comments removeObjectAtIndex:(indexPath.row - 1)];
        }
    } else {
        if (self.moment.comments.count > indexPath.row) {
            [self.moment.comments removeObjectAtIndex:indexPath.row];
        }
    }
    /// 更新约束信息
    [self updateLayout];
    /// 回调刷新数据
    if (self.reloadMomentEventHandler) {
        self.reloadMomentEventHandler(self, NO);
    }
    if (self.moment.comment.length <= 0) return;
    NSMutableArray <NSString *>*array = [self.moment.comment componentsSeparatedByString:WXDataSeparatedSign].mutableCopy;
    if ([array containsObject:viewModel.comment.identifier]) {
        [array removeObject:viewModel.comment.identifier];
    }
    if (array.count > 0) {
        self.moment.comment = [array.copy componentsJoinedByString:WXDataSeparatedSign];
    } else {
        self.moment.comment = @"";
    }
    /// 更新数据库内朋友圈数据
    [MNDatabase updateTable:WXMomentTableName
                       where:[@{@"identifier":sql_pair(self.moment.identifier)} componentString]
                      fields:@{@"comment":self.moment.comment}
                  completion:nil];
    /// 回调数据, 便于删除提醒事项
    if (self.moment.isMine && self.didDeleteCommentEventHandler) {
        self.didDeleteCommentEventHandler(self, viewModel.comment);
    }
}

#pragma mark - 点赞
- (void)insertLikesWithCount:(NSUInteger)count {
    if (count <= 0) return;
    NSMutableArray <NSString *>*likes = self.moment.likes.mutableCopy;
    NSMutableArray <NSString *>*uids = [NSMutableArray arrayWithCapacity:count];
    [[[WechatHelper helper] contacts] enumerateObjectsUsingBlock:^(WXUser * _Nonnull user, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![likes containsObject:user.uid]) [uids addObject:user.uid];
        if (uids.count >= count) {
            *stop = YES;
        }
    }];
    if (uids.count <= 0) return;
    [likes addObjectsFromArray:uids];
    [self replacingLikes:likes.copy];
}

- (void)replacingLikeUsers:(NSArray <WXUser *>*)users {
    NSMutableArray <NSString *>*uids = @[].mutableCopy;
    [users enumerateObjectsUsingBlock:^(WXUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![uids containsObject:obj.uid]) [uids addObject:obj.uid];
    }];
    [self replacingLikes:uids.copy];
}

- (void)replacingLikes:(NSArray <NSString *>*)uids {
    if (!uids) uids = @[];
    NSString *like = [uids.copy componentsJoinedByString:WXDataSeparatedSign];
    if (!like) like = @"";
    if ([like isEqualToString:self.moment.like]) return;
    // 记录原点赞数据
    NSArray <NSString *>*likes = self.moment.likes.copy;
    // 替换新的点赞数据
    self.moment.like = like;
    [self.moment.likes removeAllObjects];
    [self.moment.likes addObjectsFromArray:uids];
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
    /// 更新数据库信息
    [MNDatabase updateTable:WXMomentTableName
                       where:@{@"identifier":sql_pair(self.moment.identifier)}.componentString
                      fields:@{@"like":self.moment.like}
                  completion:nil];
    /// 自己的朋友圈还要分析新增和删除的点赞人, 刷新提醒事项
    if (self.moment.isMine && self.didUpdateLikesEventHandler) {
        self.didUpdateLikesEventHandler(self, likes);
    }
}

#pragma mark - 全文/收起
- (void)expandContentIfNeeded {
    self.expand = !self.isExpand;
    [self updateLayout];
    /// 回调刷新数据
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
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[WechatHelper momentCreatedTimeWithTimestamp:self.moment.timestamp]];
    string.font = WXMomentContentInnerFont;
    string.color = WXMomentCreatedTimeTextColor;
    return string.copy;
}

@end
