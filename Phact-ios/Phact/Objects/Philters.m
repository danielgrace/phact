//
//  Philters.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/27/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "Philters.h"

@implementation Philters

+ (id)objectFromJSON:(id)json {
	Philters *philters = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
		philters = [[Philters alloc] init];
		philters.activePhilters = [[NSMutableArray alloc] init];
		philters.inActivePhilters = [[NSMutableArray alloc] init];
		
		
		if ([[json objectForKey:@"active"] isKindOfClass:[NSArray class]]) {
			NSArray *philtersList = [json objectForKey:@"active"];
			for(NSDictionary *philter in philtersList) {
				[philters.activePhilters addObject:[philter objectForKey:@"philter"]];
			}
		}
		if ([[json objectForKey:@"passive"] isKindOfClass:[NSArray class]]) {
			NSArray *philtersList = [json objectForKey:@"passive"];
			for(NSDictionary *philter in philtersList) {
				[philters.inActivePhilters addObject:[philter objectForKey:@"philter"]];
			}
		}
	}
	return philters;
}

- (NSDictionary *)objectToDictionary {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:self.activePhilters forKey:@"active"];
	[dict setObject:self.inActivePhilters forKey:@"passive"];
	return [dict copy];
}

- (void)uppercaseFilterNames {
	for (int i = 0; i < [self.activePhilters count]; i++) {
		NSString *name = [self.activePhilters objectAtIndex:i];
		[self.activePhilters replaceObjectAtIndex:i withObject:[name uppercaseString]];
	}
	for (int i = 0; i < [self.inActivePhilters count]; i++) {
		NSString *name = [self.inActivePhilters objectAtIndex:i];
		[self.inActivePhilters replaceObjectAtIndex:i withObject:[name uppercaseString]];
	}
}

+ (void)retrievePhiltersWithCustomer:(CompletionHandler)completionHandler {
	[[PhactPrivateService sharedInstance] retrievePhiltersWithCustomer:completionHandler resultClass:[Philters class]];
}

- (void)updatePhiltersWithCustomer:(NSInteger)customerId onCompletion:(CompletionHandler)completionHandler {
	[[PhactPrivateService sharedInstance] updatePhilters:self customer:customerId onCompletion:completionHandler resultClass:[Philters class]];
}

@end
