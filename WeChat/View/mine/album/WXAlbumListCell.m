//
//  WXAlbumListCell.m
//  MNChat
//
//  Created by Vincent on 2019/5/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXAlbumListCell.h"
#import "WXAlbumPictureView.h"
#import "WXAlbumViewModel.h"

@interface WXAlbumListCell ()
@property (nonatomic, strong) WXAlbumPictureView *pictureView;
@end

@implementation WXAlbumListCell
+ (instancetype)cellWithTableView:(UITableView *)tableView {
    return [self cellWithTableView:tableView style:UITableViewCellStyleDefault];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style {
    WXAlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"com.wx.moment.cell.id"];
    if (!cell) {
        cell = [[WXAlbumListCell alloc] initWithStyle:style reuseIdentifier:@"com.wx.moment.cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.titleLabel.frame = CGRectMake(10.f, 0.f, WXAlbumViewLeftMargin - 20.f, 18.f);
        self.titleLabel.font = [UIFont systemFontOfSizes:self.titleLabel.height_mn weights:.15f];
        self.titleLabel.textColor = [UIColor darkTextColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        WXAlbumPictureView *pictureView = [WXAlbumPictureView new];
        [self.contentView addSubview:pictureView];
        self.pictureView = pictureView;
    }
    return self;
}

- (void)setViewModel:(WXAlbumViewModel *)viewModel {
    _viewModel = viewModel;
    self.titleLabel.text = [viewModel.month stringByAppendingString:@"月"];
    self.pictureView.frame = viewModel.frame;
    self.pictureView.pictures = viewModel.pictures;
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
