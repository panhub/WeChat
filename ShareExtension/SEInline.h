//
//  SEInline.h
//  WeChat
//
//  Created by Vicent on 2020/3/4.
//  Copyright © 2020 Vincent. All rights reserved.
//

/**
 缩放到指定宽度的比例尺寸
 @param size 指定尺寸
 @param width 指定宽度
 @return 比例尺寸
 */
static inline CGSize CGSizeMultiplyToWidth (CGSize size, CGFloat width) {
    if (width <= 0.f) return CGSizeZero;
    return CGSizeMake(width, size.height/(size.width/width));
}

/**
 缩放到指定高度的比例尺寸
 @param size 指定尺寸
 @param height 指定高度
 @return 比例尺寸
 */
static inline CGSize CGSizeMultiplyToHeight (CGSize size, CGFloat height) {
    if (height <= 0.f) return CGSizeZero;
    return CGSizeMake(size.width/(size.height/height), height);
}
