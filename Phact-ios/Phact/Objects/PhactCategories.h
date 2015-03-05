//
//  PhactCategories.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"

@interface PhactCategories : BaseService

@property (strong, nonatomic) NSMutableArray *categoriesArray;

+ (id)objectFromJSON:(id)json;
+ (void)retrieveCategoriesWithCustomer:(CompletionHandler)completionHandler;

@end
