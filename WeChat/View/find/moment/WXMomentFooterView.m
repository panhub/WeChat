//
//  WXMomentFooterView.m
//  WeChat
//
//  Created by Vincent on 2019/5/12.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMomentFooterView.h"

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
        UIImageView *separator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moment_more_line"]];
        separator.clipsToBounds = YES;
        separator.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:separator];
        separator.sd_layout
        .leftEqualToView(self.contentView)
        .bottomEqualToView(self.contentView)
        .rightEqualToView(self.contentView)
        .heightIs(.8f);
    }
    return self;
}

@end
