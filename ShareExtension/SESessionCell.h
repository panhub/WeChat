//
//  SESessionCell.h
//  ShareExtension
//
//  Created by Vincent on 2020/1/23.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SESession;

NS_ASSUME_NONNULL_BEGIN

@interface SESessionCell : UITableViewCell

@property (nonatomic, strong) SESession *session;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
