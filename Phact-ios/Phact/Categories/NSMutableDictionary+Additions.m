//
//  NSMutableDictionary+Additions.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "NSMutableDictionary+Additions.h"

@implementation NSMutableDictionary (Additions)

- (void)safeSetObject:(id)object forKey:(id<NSCopying>)key {
	if (object) {
		[self setObject:object forKey:key];
	}
}

@end
