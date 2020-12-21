//
//  WXMapLocation.m
//  MNChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXMapLocation.h"

@implementation WXMapLocation
+ (instancetype)pointWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[self alloc] initWithCoordinate:coordinate];
}

+ (instancetype)pointWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [self pointWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.latitude = coordinate.latitude;
        self.longitude = coordinate.longitude;
        self.coordinate = coordinate;
    }
    return self;
}

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [self initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.latitude forKey:kPath(self.latitude)];
    [coder encodeDouble:self.longitude forKey:kPath(self.longitude)];
    [coder encodeObject:self.name forKey:kPath(self.name)];
    //[coder encodeObject:self.desc forKey:kPath(self.desc)];
    [coder encodeObject:self.address forKey:kPath(self.address)];
    [coder encodeObject:self.snapshot forKey:kPath(self.snapshot)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.latitude = [coder decodeDoubleForKey:kPath(self.latitude)];
        self.longitude = [coder decodeDoubleForKey:kPath(self.longitude)];
        self.name = [coder decodeObjectForKey:kPath(self.name)];
        //self.desc = [coder decodeObjectForKey:kPath(self.desc)];
        self.address = [coder decodeObjectForKey:kPath(self.address)];
        self.snapshot = [coder decodeObjectForKey:kPath(self.snapshot)];
        self.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    }
    return self;
}

@end
