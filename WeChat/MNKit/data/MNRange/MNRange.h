//
//  MNRange.h
//  MNKit
//
//  Created by Vincent on 2019/8/10.
//  Copyright © 2019 Vincent. All rights reserved.
//  MNRange

#import <Foundation/NSValue.h>
#import <Foundation/NSObjCRuntime.h>
@class NSString;

typedef struct _MNRange {
    CGFloat location;
    CGFloat length;
} MNRange;

typedef MNRange *MNRangePointer;

static inline MNRange MNRangeMake(CGFloat location, CGFloat length)
{
    MNRange range;
    range.location = location;
    range.length = length;
    return range;
}

#define MNRangeZero MNRangeMake(0.f, 0.f)

#ifndef NSRangeZero
#define NSRangeZero  NSMakeRange(0, 0)
#endif

static inline BOOL __MNRangeEqualToRange(MNRange range1, MNRange range2)
{
    return (range1.location == range2.location && range1.length == range2.length);
}

#define MNRangeEqualToRange __MNRangeEqualToRange

static inline CGFloat MNMaxRange(MNRange range) {
    return (range.location + range.length);
}

static inline BOOL MNLocationInRange(CGFloat loc, MNRange range) {
    return (!(loc < range.location) && (loc - range.location) < range.length) ? YES : NO;
}

FOUNDATION_EXPORT NSString *NSStringFromMNRange(MNRange range);
FOUNDATION_EXPORT MNRange MNRangeFromString(NSString *aString);

@interface NSValue (MNRangeValue)

+ (NSValue *)valueWithMNRange:(MNRange)range;
@property (readonly) MNRange MNRangeValue;

@end
