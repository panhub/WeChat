//
//  MNSegmentCell.h
//  MIS_MIShop
//
//  Created by Vincent on 2018/4/8.
//  Copyright © 2018年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSegmentCell : UICollectionViewCell

/**标题*/
@property (nonatomic, copy) NSString *title;
/**标题字体*/
@property (nonatomic, strong) UIFont *titleFont;
/**标题正常颜色*/
@property (nonatomic, strong) UIColor *titleColor;

@end
