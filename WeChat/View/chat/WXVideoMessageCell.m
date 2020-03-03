//
//  WXVideoMessageCell.m
//  MNChat
//
//  Created by Vincent on 2019/6/15.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXVideoMessageCell.h"
#import "WXVideoMessageViewModel.h"
#import "WXMessagePlayView.h"

@interface WXVideoMessageCell ()
@property (nonatomic, strong) WXMessagePlayView *playView;
@end

@implementation WXVideoMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.imgView.layer.cornerRadius = 4.f;
        self.imgView.clipsToBounds = YES;
        
        WXMessagePlayView *playView = [[WXMessagePlayView alloc] initWithFrame:CGRectMake(0.f, 0.f, WXVideoMsgPlayViewWH, WXVideoMsgPlayViewWH)];
        [self.imgView addSubview:playView];
        self.playView = playView;
    }
    return self;
}

- (void)setViewModel:(WXMessageViewModel *)viewModel {
    [super setViewModel:viewModel];
    WXVideoMessageViewModel *vm = (WXVideoMessageViewModel *)viewModel;
    /// 图片
    self.imgView.frame = vm.imageViewModel.frame;
    self.imgView.image = vm.imageViewModel.content;
    viewModel.imageViewModel.obj = self.imgView;
    /// 气泡遮罩
    //self.maskImageView.frame = (CGRect){CGPointZero, vm.imageViewItem.frame.size};
    //self.maskImageView.image = vm.borderItem.content;
    //self.imgView.layer.mask = self.maskImageView.layer;
    /// 进度
    self.playView.frame = vm.playViewModel.frame;
    if (vm.state == WXVideoMessageStateNormal) {
        self.playView.type = WXMessagePlayViewNormal;
    } else {
        self.playView.type = WXMessagePlayViewUpdating;
        self.playView.progress = vm.progress;
        @weakify(self);
        vm.updateProgressHandler = ^(CGFloat progress) {
            @strongify(self);
            self.playView.progress = progress;
        };
        [vm beginUpdateProgress];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [kTransform(WXVideoMessageViewModel *, self.viewModel) pauseUpdateProgress];
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
