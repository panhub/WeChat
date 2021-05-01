//
//  WXLocation.m
//  WeChat
//
//  Created by Vincent on 2019/5/18.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "WXLocation.h"

@interface WXLocation ()
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@end

@implementation WXLocation
+ (instancetype)locationWithCoordinate:(CLLocationCoordinate2D)coordinate {
    return [[self alloc] initWithCoordinate:coordinate];
}

+ (instancetype)locationWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [[self alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

- (instancetype)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    return [self initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)];
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (self = [super init]) {
        self.latitude = coordinate.latitude;
        self.longitude = coordinate.longitude;
        self.coordinate = coordinate;
    }
    return self;
}

- (NSString *)description {
    return [@[NSStringFromCoordinate2D(self.coordinate), self.debugDescription] componentsJoinedByString:@" : "];
}

- (NSString *)debugDescription {
    NSString *string = self.name ? : @"";
    if (string.length && self.address.length) string = [string stringByAppendingString:[@"·" stringByAppendingString:self.address]];
    return string;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone {
    WXLocation *location = [[self.class allocWithZone:zone] init];
    location.latitude = self.latitude;
    location.longitude = self.longitude;
    location.coordinate = self.coordinate;
    location.name = self.name;
    location.address = self.address;
    location.snapshot = self.snapshot;
    return location;
}

#pragma mark - NSSecureCoding
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeDouble:self.latitude forKey:sql_field(self.latitude)];
    [coder encodeDouble:self.longitude forKey:sql_field(self.longitude)];
    [coder encodeObject:self.name forKey:sql_field(self.name)];
    [coder encodeObject:self.address forKey:sql_field(self.address)];
    [coder encodeObject:self.snapshot forKey:sql_field(self.snapshot)];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.latitude = [coder decodeDoubleForKey:sql_field(self.latitude)];
        self.longitude = [coder decodeDoubleForKey:sql_field(self.longitude)];
        self.name = [coder decodeObjectForKey:sql_field(self.name)];
        self.address = [coder decodeObjectForKey:sql_field(self.address)];
        self.snapshot = [coder decodeObjectForKey:sql_field(self.snapshot)];
        self.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    }
    return self;
}

@end


@implementation NSString (WXLocationGeocode)

- (WXLocation *)locationValue {
    if (![self containsString:@" : "]) return nil;
    NSArray <NSString *>*components = [self componentsSeparatedByString:@" : "];
    if (components.count > 2) return nil;
    CLLocationCoordinate2D coordinate = components.firstObject.coordinate2DValue;
    if (!CLLocationCoordinate2DIsValid(coordinate)) return nil;
    WXLocation *location = [WXLocation locationWithCoordinate:coordinate];
    if (components.count == 2) {
        components = [components.lastObject componentsSeparatedByString:@"·"];
        if (components.count <= 2) {
            location.name = components.firstObject;
            if (components.count == 2) {
                location.address = components.lastObject;
            }
        }
    }
    return location;
}

@end
