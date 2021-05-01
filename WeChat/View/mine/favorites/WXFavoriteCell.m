//
//  WXFavoriteCell.m
//  WeChat
//
//  Created by Vicent on 2021/3/20.
//  Copyright © 2021 Vincent. All rights reserved.
//

#import "WXFavoriteCell.h"
#import "WXFavoriteViewModel.h"

@interface WXFavoriteCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *sourceLabel;
@property (nonatomic, strong) UIImageView *labelView;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation WXFavoriteCell
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXFavoriteViewModel *)model delegate:(id<MNTableViewCellDelegate>)delegate {
    NSString *cls = [NSStringFromClass(model.class) stringByReplacingOccurrencesOfString:@"ViewModel" withString:@"Cell"];
    WXFavoriteCell *cell = [tableView dequeueReusableCellWithIdentifier:cls];
    if (!cell) {
        cell = [[NSClassFromString(cls) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cls];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (delegate) {
            cell.editDelegate = delegate;
            cell.allowsEditing = YES;
        }
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = VIEW_COLOR;
        self.contentView.backgroundColor = VIEW_COLOR;
        
        UIView *containerView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        containerView.backgroundColor = UIColor.whiteColor;
        containerView.layer.cornerRadius = 5.f;
        containerView.clipsToBounds = YES;
        [self.contentView addSubview:containerView];
        self.containerView = containerView;
        
        self.imgView.clipsToBounds = YES;
        self.imgView.userInteractionEnabled = YES;
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.userInteractionEnabled = NO;
        
        self.detailLabel.numberOfLines = 1;
        self.detailLabel.userInteractionEnabled = NO;
        
        UILabel *timeLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        timeLabel.numberOfLines = 1;
        timeLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        UILabel *sourceLabel = [UILabel labelWithFrame:CGRectZero text:nil textColor:nil font:nil];
        sourceLabel.numberOfLines = 1;
        sourceLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:sourceLabel];
        self.sourceLabel = sourceLabel;
        
        UIImageView *labelView = [UIImageView imageViewWithFrame:CGRectZero image:[UIImage imageNamed:@"favorite_label"]];
        labelView.clipsToBounds = YES;
        labelView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:labelView];
        self.labelView = labelView;
    
        @weakify(self);
        [self.containerView handLongPressConfiguration:^(UILongPressGestureRecognizer * _Nonnull recognizer) {
            recognizer.minimumPressDuration = .3f;
        } eventHandler:^(UIGestureRecognizer *_Nonnull recognizer) {
            @strongify(self);
            if (recognizer.state == UIGestureRecognizerStateBegan) {
                if (self.viewModel.backgroundLongPressHandler) {
                    self.viewModel.backgroundLongPressHandler(self.viewModel);
                }
            }
        }];
        
        [self.imgView handTapEventHandler:^(id  _Nonnull sender) {
            @strongify(self);
            if (self.viewModel.imageViewClickedHandler) {
                self.viewModel.imageViewClickedHandler(self.viewModel);
            }
        }];
    }
    return self;
}

- (void)setViewModel:(WXFavoriteViewModel *)viewModel {
    _viewModel = viewModel;
    self.containerView.frame = viewModel.frame;
    viewModel.containerView = self.containerView;
    
    self.timeLabel.frame = viewModel.timeViewModel.frame;
    self.timeLabel.attributedText = viewModel.timeViewModel.content;
    
    self.sourceLabel.frame = viewModel.sourceViewModel.frame;
    self.sourceLabel.attributedText = viewModel.sourceViewModel.content;
    
    self.labelView.frame = viewModel.labelViewModel.frame;
    self.labelView.hidden = viewModel.favorite.label.length <= 0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
