//
//  SESessionCell.m
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import "SESessionCell.h"
#import "SESession.h"
#import "UIView+MNLayout.h"

@interface SESessionCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *avatarView;
@end

@implementation SESessionCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.size_mn = size;
        self.contentView.frame = self.bounds;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UIImageView *avatarView = [[UIImageView alloc] init];
        avatarView.size_mn = CGSizeMake(self.contentView.height_mn - 15.f, self.contentView.height_mn - 15.f);
        avatarView.left_mn = 13.f;
        avatarView.centerY_mn = self.contentView.height_mn/2.f;
        avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.left_mn = avatarView.right_mn + 10.f;
        nameLabel.font = [UIFont systemFontOfSize:17.f];
        nameLabel.textColor = [UIColor.darkTextColor colorWithAlphaComponent:.9f];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        self.separatorInset = UIEdgeInsetsMake(0.f, avatarView.left_mn, 0.f, avatarView.left_mn);
    }
    return self;
}

- (void)setSession:(SESession *)session {
    _session = session;
    self.avatarView.image = session.avatar;
    self.nameLabel.text = session.name;
    [self.nameLabel sizeToFit];
    self.nameLabel.centerY_mn = self.contentView.height_mn/2.f;
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
