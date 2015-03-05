//
//  Feeds.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Feeds.h"
#import "PhactPrivateService.h"

@implementation Feeds

+ (void)getFeedsWithPage:(NSUInteger)page categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler {
    [[PhactPrivateService sharedInstance] getFeedsWithPage:page categoryId:categoryId onCompletion:completionHandler resultClass:[Feeds class]];
}

+ (id)objectFromJSON:(id)jsonRes {
    
    Feeds *feeds = nil;
    if ([jsonRes isKindOfClass:[NSArray class]])
    {
		NSMutableArray *feedArray = [[NSMutableArray alloc] init];
		for (id item in jsonRes) {
			Feed *feed = [Feed objectFromJSON:item];
			if (feed) {
				[feedArray addObject:feed];
			}
		}
		feeds = [[Feeds alloc] init];
		feeds.feedArray = [feedArray copy];
    }
	return feeds;
}

@end
