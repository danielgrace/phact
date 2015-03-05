//
//  NSData+NSDataDigestAdditions.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/20/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringDigestAdditions)

+ (NSString *)sha1:(NSString*)input;
+ (NSString *)md5:( NSString *)input;

@end
