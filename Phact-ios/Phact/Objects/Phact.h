//
//  Phact.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/25/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhactPrivateService.h"

@interface Phact : BaseService
@property (assign, nonatomic) NSUInteger ident;
@property (copy, nonatomic) NSString *philterName;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *printedImage;
@property (assign, nonatomic) NSTimeInterval createdDate;
@property (copy, nonatomic) NSString *location;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSArray *colors;

+ (id)objectFromJSON:(id)json;
- (void)savePhact:(CompletionHandler)completionHandler;
+ (void)deletePhact:(NSInteger)phactId onCompletion:(CompletionHandler)completionHandler;

@end
