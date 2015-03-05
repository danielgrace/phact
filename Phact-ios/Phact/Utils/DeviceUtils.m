//
//  DeviceUtils.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "DeviceUtils.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "NICInfoSummary.h"

@implementation DeviceUtils

+ (NSString *)getMacAddress {
    NSString *macAddress = @"";
    NICInfoSummary *summary = [[NICInfoSummary alloc] init];
    NSArray *nicArray = summary.nicInfos;
    for (int i = 0; i < [nicArray count]; i++) {
        NICInfo *nicInfo = [nicArray objectAtIndex:i];
        if (nicInfo.macAddress != nil) {
            macAddress = [nicInfo getMacAddressWithSeparator:@"-"];
        }
    }
    return macAddress;
}

+ (NSString *)getIPAddress {
    NSString *ipAddress = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    success = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return ipAddress;
}

@end
