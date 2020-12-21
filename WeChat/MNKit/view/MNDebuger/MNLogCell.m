//
//  MNLogCell.m
//  MNKit
//
//  Created by Vincent on 2019/9/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "MNLogCell.h"
#import "MNLogModel.h"

@implementation MNLogCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setModel:(MNLogModel *)model {
    _model = model;
    self.titleLabel.frame = model.contentRect;
    self.titleLabel.attributedText = model.attributedLog;
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
