//
//  NSArray+MNHelper.h
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (MNHelper)
/**求和*/
@property (nonatomic, readonly) CGFloat sum;
/**求平均值*/
@property (nonatomic, readonly) CGFloat avg;
/**求最大值*/
@property (nonatomic, readonly) CGFloat max;
/**求最小值*/
@property (nonatomic, readonly) CGFloat min;
/**随机元素*/
@property (nonatomic, readonly) NSUInteger randomIndex;
/**乱序后的数组*/
@property (nonatomic, readonly) NSArray *scrambledArray;
/**倒序后的数组*/
@property (nonatomic, readonly) NSArray *reversedArray;
/**元素深拷贝或浅拷贝*/
@property (nonatomic, readonly) NSArray *elementCopy;
/**元素深拷贝*/
@property (nonatomic, readonly) NSArray *elementMutableCopy;
/**获取随机元素*/
@property (nonatomic, readonly, nullable) id randomObject;

/**
 求元素和
 @param keyPath 键路径
 @return 值对象
 */
- (NSNumber *_Nullable)sumValueForKeyPath:(NSString *)keyPath;

/**
 求元素平均值
 @param keyPath 键路径
 @return 值对象
 */
- (NSNumber *_Nullable)avgValueForKeyPath:(NSString *)keyPath;

/**
 求元素最大值
 @param keyPath 键路径
 @return 值对象
 */
- (NSNumber *_Nullable)maxValueForKeyPath:(NSString *)keyPath;

/**
 求元素最小值
 @param keyPath 键路径
 @return 值对象
 */
- (NSNumber *_Nullable)minValueForKeyPath:(NSString *)keyPath;

/**
 分割数组
 @param count 多少个元素一组
 @return 分割的数组
 */
- (NSArray <NSArray *>* _Nullable)componentArrayByCapacity:(NSUInteger)count;

/**
 获取指定键的值集合
 @return 值集合
 */
- (NSArray *_Nullable)valuesForKey:(NSString *)key;

/**
 获取指定键的值集合
 @param defaultValue 默认值
 @return 值集合
 */
- (NSArray *_Nullable)valuesForKey:(NSString *)key def:(id _Nullable)defaultValue;

/**
 获取指定键的值集合
 @return 值集合
 */
- (NSArray *_Nullable)valuesForKeyPath:(NSString *)keyPath;

/**
 获取指定键的值集合
 @param defaultValue 默认值
 @return 值集合
 */
- (NSArray *_Nullable)valuesForKeyPath:(NSString *)keyPath def:(id _Nullable)defaultValue;

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
- (void)insertObjects:(NSArray *)objects fromIndex:(NSUInteger)index;

/**
 在指定元素之后插入元素
 @param object 插入的元素
 @param afterObject 指定元素
 @return  操作结果
 */
- (BOOL)insertObject:(id)object afterObject:(id)afterObject;

@end
NS_ASSUME_NONNULL_END
