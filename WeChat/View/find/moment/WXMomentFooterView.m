//
//  WXMomentFooterView.m
//  MNChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentFooterView.h"

@interface WXMomentFooterView ()
@property (nonatomic, strong) UIImageView *separator;
@end

@implementation WXMomentFooterView
+ (instancetype)footerViewWithTableView:(UITableView *)tableView {
    WXMomentFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"com.wx.moment.footer.id"];
    if (!footer) {
        footer = [[WXMomentFooterView alloc] initWithReuseIdentifier:@"com.wx.moment.footer.id"];
    }
    return footer;
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        UIImageView *separator = [[UIImageView alloc] initWithImage:UIImageNamed(@"wx_moment_comment_horizontal_line")];
        separator.clipsToBounds = YES;
        separator.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:separator];
        separator.sd_layout
        .leftEqualToView(self.contentView)
        .bottomEqualToView(self.contentView)
        .rightEqualToView(self.contentView)
        .heightIs(.8f);
        self.separator = separator;
    }
    return self;
}

@end
