//
//  MCTBaseTableViewCell.m
//  MNKit
//
//  Created by Vincent on 2017/6/16.
//  Copyright © 2017年 小斯. All rights reserved.
//

#import "MNTableViewCell.h"
#import "UIView+MNFrame.h"
#import "MNTableViewCellEditView.h"

@interface MNTableViewCell () <MNTableViewCellEditViewDelegate>
@property (nonatomic, getter=isEdit) BOOL edit;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, weak) UIView *nextEditView;
@property (nonatomic, weak) MNTableViewCellEditView *editView;
@end

#define MNTableViewCellObservedKeyPath  @"frame"
#define MNTableViewCellRecognizerKey   @"com.mn.table.view.cell.pan.recognizer.key"

@implementation MNTableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier size:size]) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame {
    if (self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier size:frame.size]) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size
{
    if (self = [self initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.size_mn = size;
        self.contentView.frame = self.bounds;
    }
    return self;
}

#pragma mark - 开启编辑
- (void)setAllowsEditing:(BOOL)allowsEditing {
    if (allowsEditing == _allowsEditing) return;
    _allowsEditing = allowsEditing;
    if (allowsEditing) {
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handPan:)];
        recognizer.user_info = MNTableViewCellRecognizerKey;
        recognizer.delegate = self;
        if (self.failToGestureRecognizer) [recognizer requireGestureRecognizerToFail:self.failToGestureRecognizer];
        [self.contentView addGestureRecognizer:recognizer];
        [self.contentView safelyAddObserver:self
                                 forKeyPath:MNTableViewCellObservedKeyPath
                                    options:NSKeyValueObservingOptionNew
                                    context:nil];
    } else {
        [self.tableView endEditingWithAnimated:YES];
        __block UIPanGestureRecognizer *recognizer;
        [self.contentView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UIPanGestureRecognizer.class] && [obj.user_info isEqualToString:MNTableViewCellRecognizerKey]) {
                recognizer = obj;
            }
        }];
        if (recognizer) [self.contentView removeGestureRecognizer:recognizer];
        [self.contentView safelyRemoveObserver:self forKeyPath:MNTableViewCellObservedKeyPath];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context  {
    if ([keyPath isEqualToString:MNTableViewCellObservedKeyPath] && _editView) {
        _editView.left_mn = self.contentView.right_mn;
    }
}

- (void)handPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:recognizer.view];
    UIGestureRecognizerState state = recognizer.state;
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    /// 判断状态
    if (state == UIGestureRecognizerStateBegan) {
        /// 判断有无二次编辑视图
        if (_nextEditView) {
            /// 复原二级编辑视图带来的宽度改变
            _editView.width_mn = _editView.totalWidth;
            /// 先适应子视图是为了解决动画过程中拖拽导致的闪烁问题
            [_editView autoresizing:_nextEditView.width_mn];
            [_editView.contentViews setValue:@(NO) forKeyPath:@"hidden"];
            [_nextEditView removeFromSuperview];
        }
    } else if (state == UIGestureRecognizerStateChanged) {
        CGRect frame = self.contentView.frame;
        /// 为了优化滑动效果
        CGFloat x = 0.f - _editView.totalWidth;
        if (frame.origin.x + point.x < x) {
            /// 超过最优距离, 加阻尼, 减缓拖拽效果
            CGFloat hindrance = point.x/4.f;
            if (frame.origin.x + hindrance <= x) {
                frame.origin.x += hindrance;
            } else {
                /// 解决滑动过快时闪烁问题
                frame.origin.x = x;
            }
        } else {
            /// 未到最大距离，正常拖拽
            frame.origin.x += (point.x/5.f*4.f);
        }
        /// 不允许右滑
        if (frame.origin.x > 0.f) {
            frame.origin.x = 0.f;
        }
        self.contentView.frame = frame;
        [_editView autoresizing:-frame.origin.x];
    } else if (state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        if (self.contentView.frame.origin.x == 0.f) {
            self.edit = NO;
            [_editView removeContentViews];
        } else if (self.contentView.frame.origin.x > 5.f) {
            [self endEditingUsingAnimation];
        } else if (fabs(self.contentView.frame.origin.x) >= 40.f && velocity.x <= 0.f) {
            [self setEdit:YES animated:YES];
        } else {
            [self setEdit:NO animated:YES];
        }
    } else if (state == UIGestureRecognizerStateCancelled) {
        [self.tableView endEditingWithAnimated:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    /// 判断手势, 便于子类接受自己的手势
    if (![recognizer isKindOfClass:UIPanGestureRecognizer.class]) return NO;
    if (![recognizer.user_info isEqualToString:MNTableViewCellRecognizerKey]) return NO;
    /// 判断方向
    CGPoint translation = [recognizer translationInView:recognizer.view];
    BOOL shouldBegin = fabs(translation.y) <= fabs(translation.x);
    if (!shouldBegin) return NO;
    // 询问代理是否需要侧滑
    if ([_delegate respondsToSelector:@selector(tableViewCell:canEditRowAtIndexPath:)]) {
        shouldBegin = [_delegate tableViewCell:self canEditRowAtIndexPath:self.index_path];
    }
    if (!shouldBegin) return NO;
    /// 先判断方向是为了方向不对时, 其它编辑视图不影响
    if ([recognizer.view.superview isKindOfClass:[MNTableViewCell class]]) {
        MNTableViewCell *cell = (MNTableViewCell *)recognizer.view.superview;
        /// 已经是编辑状态
        if (cell.isEdit) return YES;
    }
    /// 无响应编辑按钮不可编辑
    if (![_delegate respondsToSelector:@selector(tableViewCell:editingActionsForRowAtIndexPath:)]) return NO;
    /// 获取编辑按钮
    NSArray <MNTableViewCellEditAction *>*actions = [_delegate tableViewCell:self editingActionsForRowAtIndexPath:self.index_path];
    if (actions.count <= 0) return NO;
    /// 关闭其它编辑状态
    [self.tableView endEditingWithAnimated:YES];
    /// 设置编辑视图
    [self.editView updateContentViews:actions];
    self.editView.frame = CGRectMake(self.contentView.right_mn, self.contentView.top_mn, self.editView.totalWidth, self.contentView.height_mn);
    return YES;
}

#pragma mark - MNTableViewCellEditViewDelegate
- (void)tableViewCellEditView:(MNTableViewCellEditView *)editView didClickAction:(MNTableViewCellEditAction *)action {
    if (_nextEditView) [_nextEditView removeFromSuperview];
    /// 隐藏其他编辑状态
    [self.tableView endEditingExceptCell:self animated:YES];
    if ([_delegate respondsToSelector:@selector(tableViewCell:commitEditingAction:forRowAtIndexPath:)]) {
        UIView *nextEditView = [_delegate tableViewCell:self commitEditingAction:action forRowAtIndexPath:self.index_path];
        if (nextEditView) {
            /// 设置下一步编辑视图
            nextEditView.height_mn = _editView.height_mn;
            UIView *view = _editView.contentViews.count > action.index ? _editView.contentViews[action.index] : [_editView.contentViews lastObject];
            nextEditView.origin_mn = view.origin_mn;
            nextEditView.hidden = YES;
            [_editView addSubview:_nextEditView = nextEditView];
            /// 展示
            [UIView animateWithDuration:.7f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _nextEditView.hidden = NO;
                _nextEditView.origin_mn = CGPointZero;
                _editView.width_mn = _nextEditView.width_mn;
                [_editView autoresizing:_nextEditView.width_mn];
                self.contentView.left_mn = -_nextEditView.width_mn;
            } completion:^(BOOL finished) {
                [_editView.contentViews setValue:@(YES) forKeyPath:@"hidden"];
            }];
        }
    }
}

#pragma mark - 修改编辑状态
- (void)setEdit:(BOOL)editing animated:(BOOL)animated {
    self.edit = editing;
    if (editing) {
        [self willBeginEditingWithAnimated:animated];
        [UIView animateWithDuration:(animated ? .7f : 0.f) delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.left_mn = -_editView.width_mn;
            [self.editView resetting];
        } completion:^(BOOL finished) {
            [self didBeginEditingWithAnimated:YES];
        }];
    } else {
        if (self.contentView.frame.origin.x == 0.f) return;
        [self willEndEditingWithAnimated:animated];
        [UIView animateWithDuration:(animated ? .3f : 0.f) delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.contentView.left_mn = 0.f;
        } completion:^(BOOL finished) {
            [_editView removeContentViews];
            [self didEndEditingWithAnimated:animated];
        }];
    }
}

- (void)endEditingUsingAnimation {
    [self setEdit:NO animated:YES];
}

- (void)willBeginEditingWithAnimated:(BOOL)animated {}
- (void)didBeginEditingWithAnimated:(BOOL)animated {}
- (void)willEndEditingWithAnimated:(BOOL)animated {}
- (void)didEndEditingWithAnimated:(BOOL)animated {}

#pragma mark - Super
- (void)layoutSubviews {
    CGFloat x = self.isEdit ? self.contentView.frame.origin.x : 0.f;
    [super layoutSubviews];
    if (self.isEdit) self.contentView.left_mn = x;
    self.contentView.width_mn = self.width_mn;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.isEdit) [self setEdit:NO animated:NO];
}

#pragma mark - Setter
- (void)setFailToGestureRecognizer:(UIGestureRecognizer *)failToGestureRecognizer {
    if (!failToGestureRecognizer) return;
    __block UIGestureRecognizer *recognizer;
    [self.contentView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.user_info isEqualToString:MNTableViewCellRecognizerKey]) {
            recognizer = obj;
            *stop = YES;
        }
    }];
    if (recognizer) {
        [recognizer requireGestureRecognizerToFail:failToGestureRecognizer];
    } else {
        _failToGestureRecognizer = failToGestureRecognizer;
    }
}

#pragma mark - Getter
- (UIImageView *)imgView {
    if (!_imgView) {
        UIImageView *imgView = [UIImageView imageViewWithFrame:CGRectZero image:nil];
        imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView = imgView];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [UILabel labelWithFrame:CGRectZero
                                                 text:nil
                                            textColor:[UIColor darkTextColor]
                                                 font:UIFontRegular(15.f)];
        [self.contentView addSubview:_titleLabel = titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        UILabel *detailLabel = [UILabel labelWithFrame:CGRectZero
                                                  text:nil
                                             textColor:[UIColor darkGrayColor]
                                                  font:UIFontRegular(14.f)];
        [self.contentView addSubview:_detailLabel = detailLabel];
    }
    return _detailLabel;
}

- (MNTableViewCellEditView *)editView {
    if (!_editView) {
        MNTableViewCellEditView *editView = [MNTableViewCellEditView new];
        editView.delegate = self;
        [self insertSubview:_editView = editView belowSubview:self.contentView];
    }
    return _editView;
}

- (UIView *)editingView {
    return _editView;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.contentView safelyRemoveObserver:self forKeyPath:MNTableViewCellObservedKeyPath];
}

@end


@implementation UITableView (MNEditing)
- (BOOL)isEdit {
    for (UITableViewCell *c in self.visibleCells) {
        if (![c isKindOfClass:MNTableViewCell.class]) continue;
        MNTableViewCell *cell = (MNTableViewCell *)c;
        if (cell.isEdit) return YES;
    }
    return NO;
}

- (void)endEditingWithAnimated:(BOOL)animated {
    for (UITableViewCell *c in self.visibleCells) {
        if (![c isKindOfClass:MNTableViewCell.class]) continue;
        MNTableViewCell *cell = (MNTableViewCell *)c;
        if (!cell.isEdit) continue;
        [cell setEdit:NO animated:animated];
    }
}

- (void)endEditingExceptCell:(UITableViewCell *)cell animated:(BOOL)animated {
    for (UITableViewCell *c in self.visibleCells) {
        if (![c isKindOfClass:MNTableViewCell.class] || c == cell) continue;
        MNTableViewCell *_cell = (MNTableViewCell *)c;
        if (!_cell.isEdit) continue;
        [_cell setEdit:NO animated:animated];
    }
}

@end
