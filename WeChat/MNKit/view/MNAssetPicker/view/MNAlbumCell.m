//
//  MNAlbumCell.m
//  MNKit
//
//  Created by Vincent on 2019/9/1.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNAlbumCell.h"
#import "MNAssetCollection.h"
#import "MNAssetHelper.h"

@implementation MNAlbumCell
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size {
    if (self = [super initWithReuseIdentifier:reuseIdentifier size:size]) {
        
        self.imgView.frame = CGRectMake(self.contentView.width_mn/6.f, 0.f, self.contentView.height_mn/3.f*2.f, self.contentView.height_mn/3.f*2.f);
        self.imgView.contentMode = UIViewContentModeScaleAspectFill;
        self.imgView.clipsToBounds = YES;
        self.imgView.backgroundColor = UIColorWithSingleRGB(240.f);
        self.imgView.bottom_mn = self.contentView.height_mn - 7.f;
        
        self.titleLabel.frame = CGRectMake(self.imgView.right_mn + 10.f, 0.f, 0.f, 20.f);
        self.titleLabel.font = [UIFont systemFontOfSize:16.f];
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.centerY_mn = self.imgView.centerY_mn;
        
        self.detailLabel.frame = CGRectMake(0.f, 0.f, 0.f, 18.f);
        self.detailLabel.centerY_mn = self.imgView.centerY_mn;
        self.detailLabel.font = [UIFont systemFontOfSize:15.f];
        self.detailLabel.textColor = [self.titleLabel.textColor colorWithAlphaComponent:.5f];
    }
    return self;
}

- (void)setModel:(MNAssetCollection *)model {
    _model = model;
    self.titleLabel.text = model.title;
    [self.titleLabel sizeToFit];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSArray <MNAsset *>*assets = [model.assets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.isSelected == YES"]];
    self.detailLabel.text = [NSString stringWithFormat:@"(%@/%@)", @(assets.count).stringValue, @(model.assets.count).stringValue];
    [self.detailLabel sizeToFit];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    
    self.detailLabel.left_mn = self.titleLabel.right_mn + 7.f;
    
    @weakify(self);
    [[MNAssetHelper helper] requestCollectionThumbnail:model completion:^(MNAssetCollection *m) {
        if (m == weakself.model) {
            weakself.imgView.image = m.thumbnail;
        }
    }];
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
