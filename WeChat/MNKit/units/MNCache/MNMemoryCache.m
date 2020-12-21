//
//  MNMemoryCache.m
//  MNKit
//
//  Created by Vincent on 2018/10/29.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNMemoryCache.h"
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <pthread.h>

static inline dispatch_queue_t MNMemoryCacheGlobalReleaseQueue(void) {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}

#pragma mark - 节点
@interface MNLinkedMapNode : NSObject {
    @package
    /**上一个节点*/
    __unsafe_unretained MNLinkedMapNode *_prev;
    /**下一个节点*/
    __unsafe_unretained MNLinkedMapNode *_next;
    id _key;
    id _value;
    /**开销*/
    NSUInteger _cost;
    /**时间*/
    NSTimeInterval _time;
}
@end

@implementation MNLinkedMapNode
@end

#pragma mark - 链表
@interface MNLinkedMap : NSObject {
    @package
    /**存放节点*/
    CFMutableDictionaryRef _container;
    /**总开销*/
    NSUInteger _totalCost;
    /**总数量*/
    NSUInteger _totalCount;
    /**表头*/
    MNLinkedMapNode *_head;
    /**表尾*/
    MNLinkedMapNode *_tail;
    BOOL _releaseOnMainThread;
    BOOL _releaseUseAsynchronously;
}

/**
 在链表头部插入某节点
 @param node 节点
 */
- (void)insertNodeAtHead:(MNLinkedMapNode *)node;

/**
 将链表内部的某个节点移到链表头部
 @param node 节点
 */
- (void)bringNodeToHead:(MNLinkedMapNode *)node;

/**
 删除链表内部的某个节点
 @param node 节点
 */
- (void)removeNode:(MNLinkedMapNode *)node;

/**
 移除链表的尾部节点
 @return 尾部节点
 */
- (MNLinkedMapNode *)removeTailNode;

@end

@implementation MNLinkedMap

- (void)dealloc {
    CFRelease(_container);
}

- (instancetype)init {
    if (self = [super init]) {
        /**数量和开销全部为0*/
        _totalCount = _totalCost = 0;
        /**释放操作不在后台进行*/
        _releaseOnMainThread = NO;
        /**释放操作异步执行*/
        _releaseUseAsynchronously = YES;
        /**创建存储器*/
        _container = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    }
    return self;
}

- (void)insertNodeAtHead:(MNLinkedMapNode *)node {
    /**存入节点*/
    CFDictionarySetValue(_container, (__bridge const void *)(node->_key), (__bridge const void *)(node));
    /**计算数量*/
    _totalCount ++;
    /**计算开销*/
    _totalCost += node->_cost;
    if (_head) {
        /**如果有头部节点则替换*/
        node->_next = _head;
        _head->_prev = node;
        _head = node;
    } else {
        /**没有头部节点则指向*/
        /**说明是第一次插入数据*/
        _head = _tail = node;
    }
}

- (void)bringNodeToHead:(MNLinkedMapNode *)node {
    if (_head == node) return;
    if (_tail == node) {
        /**尾部节点*/
        _tail = node->_prev;
        _tail->_next = nil;
    } else {
        /**中间节点, 要弥补链表*/
        node->_next->_prev = node->_prev;
        node->_prev->_next = node->_next;
    }
    /**node 作为表头, 原表头下移位*/
    node->_next = _head;
    node->_prev = nil;
    _head->_prev = node;
    _head = node;
}

- (void)removeNode:(MNLinkedMapNode *)node {
    /**先从链表里移除节点*/
    CFDictionaryRemoveValue(_container, (__bridge const void*)(node->_key));
    /**计算开销*/
    _totalCost -= node->_cost;
    /**计算数量*/
    _totalCount--;
    /**弥补链表*/
    if (node->_next) node->_next->_prev = node->_prev;
    if (node->_prev) node->_prev->_next = node->_next;
    if (_head == node) _head = node->_next;
    if (_tail == node) _tail = node->_prev;
}

- (MNLinkedMapNode *)removeTailNode {
    /**删除时, 仅从最后节点开始删除, 这样才可保证缓存新鲜, 命中率高*/
    if (!_tail) return nil;
    MNLinkedMapNode *tail = _tail;
    /**从链表里删除最后节点*/
    CFDictionaryRemoveValue(_container, (__bridge const void *)(_tail->_key));
    /**计算开销*/
    _totalCost -= _tail->_cost;
    /**计算数量*/
    _totalCount--;
    if (_head == _tail) {
        /**尾节点也是头节点, 说明没节点了*/
        _head = _tail = nil;
    } else {
        /**记录尾节点为上一个节点*/
        _tail = _tail->_prev;
        /**将此时的尾节点的下一个节点置空*/
        _tail->_next = nil;
    }
    /**释放操作由外部处理*/
    return tail;
}

- (void)removeAllNodes {
    _totalCost = 0;
    _totalCount = 0;
    _head = nil;
    _tail = nil;
    if (CFDictionaryGetCount(_container) <= 0) return;
    CFMutableDictionaryRef holder = _container;
    _container = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    /**按规定释放缓存*/
    if (_releaseUseAsynchronously) {
        dispatch_queue_t queue = _releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
        dispatch_async(queue, ^{
            CFRelease(holder);
        });
    } else if (_releaseOnMainThread && !pthread_main_np()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CFRelease(holder);
        });
    } else {
        CFRelease(holder);
    }
}

@end

@implementation MNMemoryCache {
    /**链表*/
    MNLinkedMap *_linked;
    /**线程锁*/
    pthread_mutex_t _lock;
    /**操作线程*/
    dispatch_queue_t _queue;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [_linked removeAllNodes];
    pthread_mutex_destroy(&_lock);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    @throw [NSException exceptionWithName:@"MNMemoryCache实例化方式错误"
                                   reason:@"请使用指定的实例化方式"
                                 userInfo:nil];
    return nil;
}

+ (instancetype)memoryCache {
    return [[MNMemoryCache alloc] initWithName:nil];
}

+ (instancetype)memoryCacheWithName:(nullable NSString *)name {
    return [[MNMemoryCache alloc] initWithName:name];
}

- (instancetype)initWithName:(nullable NSString *)name {
    self = [super init];
    if (!self) return nil;
    /**初始化线程锁*/
    pthread_mutex_init(&_lock, NULL);
    /**初始化链表*/
    _linked = [MNLinkedMap new];
    /**创建线程*/
    _queue = dispatch_queue_create("com.mn.cache.memory.queue", DISPATCH_QUEUE_SERIAL);
    
    _name = name;
    _maxCount = NSUIntegerMax;
    _maxCost = NSUIntegerMax;
    _timeOutInterval = DBL_MAX;
    _trimTimeInterval = 10.f;
    _clearCacheWhenMemoryWarning = YES;
    _clearCacheWhenEnterBackground = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMemoryWarningNotification)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [self trimCacheRecursively];
    
    return self;
}

- (void)trimCacheRecursively {
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_trimTimeInterval * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        __strong typeof(_self) __self = _self;
        if (!__self) return;
        [__self trimInBackground];
        [__self trimCacheRecursively];
    });
}

- (void)trimInBackground {
    dispatch_async(_queue, ^{
        [self trimToCost:self->_maxCost];
        [self trimToCount:self->_maxCount];
        [self trimToTime:self->_timeOutInterval];
    });
}

- (void)trimToCost:(NSUInteger)cost {
    BOOL finish = NO;
    /**加锁*/
    pthread_mutex_lock(&_lock);
    if (cost == 0) {
        /**最大开销为0, 则删除所有内存缓存*/
        [_linked removeAllNodes];
        finish = YES;
    } else if (_linked->_totalCost <= cost) {
        /**如果当前缓存的总开销符合要求, 则不进行清理操作*/
        finish = YES;
    }
    /**解锁*/
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    NSMutableArray <MNLinkedMapNode *>*holder = [NSMutableArray new];
    while (!finish) {
        /**0的时候说明在尝试加锁的时候,获取锁成功,可以进行操作*/
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_linked -> _totalCost > cost) {
                MNLinkedMapNode *node = [_linked removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            /**否则等待10s(不知道为什么是10s, 而不是2s, 5s,等等*/
            usleep(10*1000);
        }
    }
    /**按规定释放缓存*/
    if (holder.count) {
        dispatch_queue_t queue = _linked->_releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)trimToCount:(NSUInteger)count {
    BOOL finish = NO;
    pthread_mutex_lock(&_lock);
    if (count == 0) {
        [_linked removeAllNodes];
        finish = YES;
    } else if (_linked->_totalCount <= count) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray <MNLinkedMapNode *>*holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_linked->_totalCount > count) {
                MNLinkedMapNode *node = [_linked removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10*1000);
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _linked->_releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)trimToTime:(NSTimeInterval)timeInterval {
    BOOL finish = NO;
    NSTimeInterval now = CACurrentMediaTime();
    pthread_mutex_lock(&_lock);
    if (timeInterval <= 0) {
        [_linked removeAllNodes];
        finish = YES;
    } else if (!(_linked ->_tail) || (now - (_linked->_tail->_time)) <= timeInterval) {
        finish = YES;
    }
    pthread_mutex_unlock(&_lock);
    if (finish) return;
    
    NSMutableArray *holder = [NSMutableArray new];
    while (!finish) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            if (_linked->_tail && (now - _linked->_tail->_time) > timeInterval) {
                MNLinkedMapNode *node = [_linked removeTailNode];
                if (node) [holder addObject:node];
            } else {
                finish = YES;
            }
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10*1000);
        }
    }
    if (holder.count) {
        dispatch_queue_t queue = _linked->_releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
        dispatch_async(queue, ^{
            [holder count];
        });
    }
}

- (void)didReceiveMemoryWarningNotification {
    if (self.didReceiveMemoryWarningCallback) {
        self.didReceiveMemoryWarningCallback(self);
    }
    if (self.clearCacheWhenMemoryWarning) {
        [self removeAllObjects];
    }
}

- (void)didEnterBackgroundNotification {
    if (self.didEnterBackgroundCallback) {
        self.didEnterBackgroundCallback(self);
    }
    if (self.clearCacheWhenEnterBackground) {
        [self removeAllObjects];
    }
}

- (void)removeAllObjects {
    pthread_mutex_lock(&_lock);
    [_linked removeAllNodes];
    pthread_mutex_unlock(&_lock);
}

- (NSUInteger)totalCount {
    pthread_mutex_lock(&_lock);
    NSUInteger count = _linked->_totalCount;
    pthread_mutex_unlock(&_lock);
    return count;
}

- (NSUInteger)totalCost {
    pthread_mutex_lock(&_lock);
    NSUInteger totalCost = _linked ->_totalCost;
    pthread_mutex_unlock(&_lock);
    return totalCost;
}

- (BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    BOOL releaseOnMainThread = _linked->_releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
    return releaseOnMainThread;
}

- (void)setReleaseOnMainThread:(BOOL)releaseOnMainThread {
    pthread_mutex_lock(&_lock);
    _linked->_releaseOnMainThread = releaseOnMainThread;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)releaseUseAsynchronously {
    pthread_mutex_lock(&_lock);
    BOOL releaseUseAsynchronously = _linked->_releaseUseAsynchronously;
    pthread_mutex_unlock(&_lock);
    return releaseUseAsynchronously;
}

- (void)setReleaseUseAsynchronously:(BOOL)releaseUseAsynchronously {
    pthread_mutex_lock(&_lock);
    _linked->_releaseUseAsynchronously = releaseUseAsynchronously;
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsObjectForKey:(id)key {
    if (!key) return NO;
    pthread_mutex_lock(&_lock);
    BOOL contains = CFDictionaryContainsKey(_linked->_container, (__bridge const void *)(key));
    pthread_mutex_unlock(&_lock);
    return contains;
}

- (id)objectForKey:(id)key {
    if (!key) return nil;
    pthread_mutex_lock(&_lock);
    MNLinkedMapNode *node = CFDictionaryGetValue(_linked->_container, (__bridge const void *)(key));
    if (node) {
        /**取值时把时间设置为当前时间*/
        node->_time = CACurrentMediaTime();
        /**取值时将节点提至链表头*/
        [_linked bringNodeToHead:node];
        /**以此保证数据的新鲜, 提高命中率*/
    }
    pthread_mutex_unlock(&_lock);
    return node ? node->_value : nil;
}

- (void)setObject:(id)object forKey:(id)key {
    [self setObject:object forKey:key withCost:0];
}

- (void)setObject:(id)object forKey:(id)key withCost:(NSUInteger)cost {
    if (!key) return;
    if (!object) {
        /**存入缓存为nil, 则检查节点并删除*/
        [self removeObjectForKey:key];
        return;
    }
    pthread_mutex_lock(&_lock);
    /**先查找是否存在缓存节点*/
    MNLinkedMapNode *node = CFDictionaryGetValue(_linked->_container, (__bridge const void *)(key));
    NSTimeInterval now = CACurrentMediaTime();
    if (node) {
        /**存在节点, 更新开销, 数据*/
        _linked->_totalCost -= node->_cost;
        _linked->_totalCost += cost;
        node->_cost = cost;
        /**存入时也要把时间设置为当前时间*/
        node->_time = now;
        node->_value = object;
        [_linked bringNodeToHead:node];
    } else {
        /**不存在节点, 则创建节点并设为链表头*/
        node = [MNLinkedMapNode new];
        node->_cost = cost;
        node->_time = now;
        node->_key = key;
        node->_value = object;
        [_linked insertNodeAtHead:node];
    }
    /**检查是否满足开销设置*/
    if (_linked->_totalCost > _maxCost) {
        /**大于总开销, 就删除到规定开销*/
        dispatch_async(_queue, ^{
            [self trimToCost:_maxCost];
        });
    }
    /**检查是否满足数量设置, 不满足就删除*/
    /**只用删除一个即可, 要从尾节点删除, 这就是提高命中率的核心思想*/
    if (_linked->_totalCount > _maxCount) {
        MNLinkedMapNode *node = [_linked removeTailNode];
        /**按规定释放缓存*/
        if (_linked->_releaseUseAsynchronously) {
            dispatch_queue_t queue = _linked->_releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
            dispatch_async(queue, ^{
                [node class];
            });
        } else if (_linked->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

- (void)removeObjectForKey:(id)key {
    if (!key) return;
    pthread_mutex_lock(&_lock);
    MNLinkedMapNode *node = CFDictionaryGetValue(_linked->_container, (__bridge const void *)(key));
    if (node) {
        /**存在节点, 则删除节点, 并按要求释放缓存*/
        [_linked removeNode:node];
        if (_linked->_releaseUseAsynchronously) {
            dispatch_queue_t queue = _linked->_releaseOnMainThread ? dispatch_get_main_queue() : MNMemoryCacheGlobalReleaseQueue();
            dispatch_async(queue, ^{
                [node class];
            });
        } else if (_linked->_releaseOnMainThread && !pthread_main_np()) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [node class];
            });
        }
    }
    pthread_mutex_unlock(&_lock);
}

@end
