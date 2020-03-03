//
//  MNRecordView.m
//  MNKit
//
//  Created by Vincent on 2018/7/25.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNRecordView.h"

@interface MNRecordView ()
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIImageView *maskView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@end

#define kMNRecordViewVerMargin     20.f //横向间隔
#define kMNRecordViewHorMargin     8.f   //纵向间隔
#define kMNRecordImageViewSize     70.f //录音图片
#define kMNRecordViewSize             (kMNRecordViewVerMargin*2.f + kMNRecordImageViewSize)
@implementation MNRecordView

//+ (instancetype)recordView {
//    MNRecordView *recordView = [[MNRecordView alloc]initWithFrame:CGRectMake(kMEAN(UIScreenWidth - kMNRecordViewSize), kMEAN(UIScreenHeight - kMNRecordViewSize), kMNRecordViewSize, kMNRecordViewSize)];
//    return recordView;
//}
//
//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
//        [self createView];
//    }
//    return self;
//}
//
//- (void)createView {
//    //录音图片
//    UIImageView *imageView = [UIImageView imageViewWithFrame:CGRectMake(kMNRecordViewVerMargin, kMNRecordViewHorMargin, kMNRecordImageViewSize, kMNRecordImageViewSize)
//                                                       image:MNIconFont(kRecorderIconUnicode, kMNRecordImageViewSize, [UIColor whiteColor])];
//    [self addSubview:imageView];
//    
//    //音量覆盖图
//    UIImageView *maskView = [UIImageView imageViewWithFrame:imageView.bounds
//                                                       image:MNIconFont(kRecorderIconUnicode, kMNRecordImageViewSize, [UIColor mn_colorWithHex:@"7fff00"])];
//    [imageView addSubview:maskView];
//    _maskView = maskView;
//    
//    //mask更新
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskView.layer.mask = maskLayer;
//    _maskLayer = maskLayer;
//    
//    //录音时长
//    UILabel *timeLabel = [UILabel labelWithFrame:CGRectMake(10.f, kMEAN(self.height_mn - imageView.bottom_mn - 15.f) + imageView.bottom_mn, self.width_mn - 20.f, 15.f)
//                                            text:@"00:00"
//                                   textAlignment:NSTextAlignmentCenter
//                                       textColor:[UIColor whiteColor]
//                                            font:0.f];
//    [timeLabel setFont:[UIFont systemFontOfSize:15.f]];
//    [self addSubview:timeLabel];
//    _timeLabel = timeLabel;
//    
//    [self mn_cornerRadius:7.f];
//}
//
//- (void)show {
//    [MN_WINDOW addSubview:self];
//}
//
//#pragma mark - 更新时间/音量
//- (void)updateMeters:(float)meters duration:(int)duration {
//    [_timeLabel setText:[MNInline timeDurationWithTimestamp:@(duration)]];
//    
//    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//    [bezierPath moveToPoint:CGPointMake(0.f, _maskView.height_mn*(1.f - meters))];
//    [bezierPath addLineToPoint:CGPointMake(0.f, _maskView.height_mn)];
//    [bezierPath addLineToPoint:CGPointMake(_maskView.width_mn, _maskView.height_mn)];
//    [bezierPath addLineToPoint:CGPointMake(_maskView.width_mn, _maskView.height_mn*(1.f - meters))];
//    [bezierPath closePath];
//    
//    _maskLayer.path = bezierPath.CGPath;
//}


@end
