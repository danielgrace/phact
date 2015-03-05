//
//  Philters.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/27/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhactPrivateService.h"

@interface Philters : BaseService
@property (strong, nonatomic) NSMutableArray *activePhilters;
@property (strong, nonatomic) NSMutableArray *inActivePhilters;

+ (id)objectFromJSON:(id)json;
+ (void)retrievePhiltersWithCustomer:(CompletionHandler)completionHandler;
- (void)updatePhiltersWithCustomer:(NSInteger)customerId onCompletion:(CompletionHandler)completionHandler;

- (void)uppercaseFilterNames;

@end
