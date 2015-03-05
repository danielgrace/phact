//
//  PhactCategory.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"
#import "PhactPrivateService.h"

@interface PhactCategory : BaseService

@property (assign, nonatomic) NSInteger categoryId;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *createdDate;
@property (copy, nonatomic) NSString *color;

+ (id)objectFromJSON:(id)json;
+ (void)createCategory:(NSString *)name onCompletion:(CompletionHandler)completionHandler;
+ (void)deleteCategory:(NSInteger)categotyId onCompletion:(CompletionHandler)completionHandler;

@end
