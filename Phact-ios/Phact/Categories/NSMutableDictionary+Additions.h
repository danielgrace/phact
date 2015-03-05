//
//  NSMutableDictionary+Additions.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Additions)

- (void)safeSetObject:(id)object forKey:(id<NSCopying>)key;

@end
