//
//  MNRange.m
//  MNKit
//
//  Created by Vincent on 2019/8/10.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNRange.h"

NSString *NSStringFromMNRange(MNRange range) {
    return [NSString stringWithFormat:@"{%@, %@}", [NSNumber numberWithFloat:range.location], [NSNumber numberWithFloat:range.length]];
}

MNRange MNRangeFromString(NSString *aString) {
    if (aString.length <= 5) return MNRangeZero;
    if ([aString hasPrefix:@"{"] && [aString hasSuffix:@"}"] && [aString containsString:@", "]) {
        NSArray *components = [aString componentsSeparatedByString:@", "];
        if (components.count == 2) {
            NSString *location = components.firstObject;
            location = [location stringByReplacingOccurrencesOfString:@"{" withString:@""];
            NSString *length = components.lastObject;
            length = [length stringByReplacingOccurrencesOfString:@"}" withString:@""];
            return MNRangeMake(location.floatValue, length.floatValue);
        }
    }
    return MNRangeZero;
}

@implementation NSValue (MNRangeValue)

+ (NSValue *)valueWithMNRange:(MNRange)range {
    return [NSValue value:&range withObjCType:@encode(MNRange)];
}

- (MNRange)MNRangeValue {
    MNRange range;
    [self getValue:&range];
    return range;
}

@end
