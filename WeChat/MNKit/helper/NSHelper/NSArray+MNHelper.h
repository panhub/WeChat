//
//  NSArray+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MNHelper)

/**
 分割数组
 @param count 多少个元素一组
 @return 分割的数组
 */
- (NSArray <NSArray *>*)componentArrayByCapacity:(NSUInteger)count;

/**
 倒序
 @return 倒序数组
 */
- (NSArray *)reverseObjects;

/**
 获取随机元素
 @return 随机元素
 */
- (id)randomObject;

/**
获取随机索引
@return 随机索引
*/
- (NSInteger)randomIndex;

/**
 将数组元素打乱顺序
 @return 乱序后的数组
 */
- (NSArray *)scrambledArray;

@end


@interface NSMutableArray (MNHelper)

/**
 移动元素
 @param index 需要移动的元素位置
 @param toIndex 移动到哪个位置
 */
- (void)moveSubjectAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex;

/**
 移动指定元素到指定索引
 @param subject 指定元素
 @param toIndex 指定索引
 */
- (void)moveSubject:(id)subject toIndex:(NSInteger)toIndex;

/**
 将元素移动到第一位
 @param subject 元素
 */
- (void)bringSubjectToFront:(id)subject;

/**
 将元素移动到最后
 @param subject 元素
 */
- (void)sendSubjectToBack:(id)subject;

/**
 将指定索引元素移动到第一位
 @param index 指定索引
 */
- (void)bringSubjectToFrontAtIndex:(NSUInteger)index;

/**
 将指定索引元素移动到最后
 @param index 指定索引
 */
- (void)sendSubjectToBackAtIndex:(NSUInteger)index;

/**
 插入一组数据到指定索引
 @param objects 数据
 @param index 指定索引
 */
- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index;

@end

