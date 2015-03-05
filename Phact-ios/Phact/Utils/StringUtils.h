//
//  StringUtils.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtils : NSObject
+ (NSString *)safeStringWithString:(NSString *)string;
+ (NSString *)safeStringOrEmptyIfNilWithString:(NSString *)string;

@end
