//
//  Phacts.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "BaseService.h"

@interface Phacts : BaseService

@property (strong, nonatomic) NSMutableArray *phacts;
@property (strong, nonatomic) NSString *geolocation;

+ (void)imageSearch:(NSString *)image onCompletion:(CompletionHandler)completionHandler;
+ (void)doSearch:(NSString *)body location:(NSString *)location onCompletion:(CompletionHandler)completionHandler;
+ (void)searchByBestGuess:(NSString *)context location:(NSString *)location onCompletion:(CompletionHandler)completionHandler;

+ (void)loadPhactsByCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler;
+ (void)markPhactsAsRead:(NSArray *)ids onCompletion:(CompletionHandler)completionHandler;
+ (void)loadOwnPhacts:(CompletionHandler)completionHandler;

@end
