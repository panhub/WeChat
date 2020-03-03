//
//  WXSetingListCell.m
//  MNChat
//
//  Created by Vincent on 2019/7/22.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXSetingListCell.h"
#import "WXDataValueModel.h"

@interface WXSetingListCell ()

@property (nonatomic, strong) UIImageView *arrowView;

@end

@implementation WXSetingListCell
+ (instancetype)dequeueReusableCellWithTableView:(UITableView *)tableView model:(WXDataValueModel *)model {
    WXSetingListCell *cell = [tableView dequeueReusableCellWithIdentifier:model.value];
    if (!cell) {
        cell = [[NSClassFromString(model.value) alloc] initWithReuseIdentifier:model.value size:tableView.rowSize];
    }
    [cell setValue:model forKey:@"model"];
    return cell;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.titleLabel.frame = CGRectMake(15.f, MEAN(self.contentView.height_mn - 17.f), 130.f, 17.f);
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.titleLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.88f];
        
        UIImage *image = UIImageNamed(@"wx_common_list_arrow");
        CGSize size = CGSizeMultiplyToWidth(image.size, 25.f);
        UIImageView *arrowView = [UIImageView imageViewWithFrame:CGRectMake(self.contentView.width_mn - size.width - self.titleLabel.left_mn, 0.f, size.width, size.height)
                                                           image:image];
        arrowView.centerY_mn = MEAN(self.contentView.height_mn);
        [self.contentView addSubview:arrowView];
        self.arrowView = arrowView;
        
        self.detailLabel.frame = CGRectMake(self.titleLabel.right_mn + 10.f, self.titleLabel.top_mn, arrowView.left_mn - self.titleLabel.right_mn - 10.f, self.titleLabel.height_mn);
        self.detailLabel.font = [UIFont systemFontOfSize:17.f];
        self.detailLabel.textColor = UIColorWithSingleRGB(165.f);
        self.detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setModel:(WXDataValueModel *)model {
    _model = model;
    self.titleLabel.text = model.title;
    self.detailLabel.text = model.desc;
    self.arrowView.hidden = model.userInfo != nil;
    self.detailLabel.right_mn = model.userInfo == nil ? self.arrowView.left_mn : self.arrowView.right_mn - 7.f;
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
