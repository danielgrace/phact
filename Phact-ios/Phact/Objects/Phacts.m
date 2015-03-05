//
//  Phacts.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "Phacts.h"
#import "PhactPrivateService.h"
#import "Phact.h"

@implementation Phacts

+ (void)imageSearch:(NSString *)image onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] imageSearch:image onCompletion:completionHandler resultClass:[Phacts class]];
}

+ (void)doSearch:(NSString *)body location:(NSString *)location onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] doSearch:body location:(NSString *)location onCompletion:completionHandler resultClass:[Phacts class]];
}

+ (void)searchByBestGuess:(NSString *)context location:(NSString *)location onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] searchByBestGuess:context location:location onCompletion:completionHandler resultClass:[Phacts class]];
}

+ (void)loadPhactsByCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] loadPhactsByCategory:categoryId onCompletion:completionHandler resultClass:[Phacts class]];
}

+ (void)loadOwnPhacts:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] getOwnPhacts:completionHandler resultClass:[Phacts class]];
}

+ (void)markPhactsAsRead:(NSArray *)ids onCompletion:(CompletionHandler)completionHandler {
    [[PhactPrivateService sharedInstance] markPhactsAsRead:ids onCompletion:completionHandler resultClass:[NSNumber class]];
}

+ (id)objectFromJSON:(id)jsonRes {
	Phacts *phacts = nil;
    if ([jsonRes isKindOfClass:[NSDictionary class]])
    {
        id jsonData = [jsonRes objectForKey:@"result"];
        if ([jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *phactList = [[NSMutableArray alloc] init];
            for (id phactJson in jsonData) {
                Phact *phact = [Phact objectFromJSON:phactJson];
                if (phact) {
                    [phactList addObject:phact];
                }
            }
            phacts = [[Phacts alloc] init];
            phacts.phacts = phactList;
        }
        phacts.geolocation = [jsonRes objectForKey:@"geolocation"];
    }
	return phacts;
}

@end
