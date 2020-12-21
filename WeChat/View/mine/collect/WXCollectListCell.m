//
//  WXCollectListCell.m
//  MNChat
//
//  Created by Vincent on 2019/4/29.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXCollectListCell.h"
#import "WXWebpage.h"

@interface WXCollectListCell ()
@property (nonatomic, unsafe_unretained) UIView *containerView;
@end

@implementation WXCollectListCell
- (instancetype) initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.backgroundColor = VIEW_COLOR;
        self.contentView.backgroundColor = VIEW_COLOR;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10.f, 0.f, self.contentView.width_mn - 20.f, self.contentView.height_mn)];
        containerView.backgroundColor = [UIColor whiteColor];
        UIViewSetCornerRadius(containerView, 5.f);
        [self.contentView addSubview:containerView];
        self.containerView = containerView;
        
        self.imgView.frame = CGRectMake(20.f, 20.f, 50.f, 50.f);
        [containerView addSubview:self.imgView];
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, self.imgView.top_mn, containerView.width_mn - self.imgView.right_mn - 30.f, self.imgView.height_mn);
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17.f];
        [containerView addSubview:self.titleLabel];
        
        self.detailLabel.frame = CGRectMake(self.imgView.left_mn, self.imgView.bottom_mn + 15.f, containerView.width_mn - self.imgView.left_mn*2.f, 14.f);
        self.detailLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:.5f];
        self.detailLabel.font = [UIFont systemFontOfSize:12.f];
        [containerView addSubview:self.detailLabel];
        
        //CGRectLog(self.detailLabel.frame);
    }
    return self;
}

- (void)setModel:(WXWebpage *)model {
    _model = model;
    self.imgView.image = model.thumbnail;
    self.detailLabel.text = model.date;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.width_mn = self.containerView.width_mn - self.imgView.right_mn - 30.f;
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
