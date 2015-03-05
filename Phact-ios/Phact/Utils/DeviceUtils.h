//
//  DeviceUtils.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtils : NSObject

+ (NSString *)getMacAddress;
+ (NSString *)getIPAddress;

@end
