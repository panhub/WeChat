//
//  WXAddMomentCollectionModel.h
//  MNChat
//
//  Created by Vincent on 2019/5/9.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WXAddMomentCollectionModel : NSObject

/**最后一个*/
@property (nonatomic, assign, getter=isLast) BOOL last;

/**图片*/
@property (nonatomic, strong) UIImage *image;

/**显示图片的view*/
@property (nonatomic, weak) UIImageView *containerView;

/**是否可删除*/
@property (nonatomic, getter=isEditing) BOOL editing;

+ (instancetype)lastModel;

- (instancetype)initWithImage:(UIImage *)image;

@end
