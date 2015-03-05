//
//  StringUtils.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils

+ (NSString *)safeStringWithString:(NSString *)string {
	NSString *result = nil;
	if (string && ![string isKindOfClass:[NSNull class]]) {
		result = [NSString stringWithFormat:@"%@", string];
	}
	return result;
}

+ (NSString *)safeStringOrEmptyIfNilWithString:(NSString *)string {
	NSString *result = [self safeStringWithString:string];
	if (!result) {
		result = @"";
	}
	return result;
}

@end
