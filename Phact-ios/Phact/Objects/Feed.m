//
//  Feed.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Feed.h"
#import "PhactPrivateService.h"

@implementation Feed

+ (id)objectFromJSON:(id)json {
	Feed *feed = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
		feed = [[Feed alloc] init];
		feed.markAsRead = [[json objectForKey:@"read"] boolValue];
        feed.usernameTo = [json objectForKey:@"usr_name_to"];
        feed.usernameFrom = [json objectForKey:@"usr_name_from"];
        feed.userIdTo = [[json objectForKey:@"usr_id_to"] integerValue];
        feed.userIdFrom = [[json objectForKey:@"usr_id_from"] integerValue];
        feed.feedId = [[json objectForKey:@"id"] integerValue];
        feed.phactId = [[json objectForKey:@"phact_id"] integerValue];
        feed.philterName = [json objectForKey:@"philter"];
        feed.desc = [json objectForKey:@"description"];
        feed.location = [json objectForKey:@"location"];
        feed.phactImageURL = [json objectForKey:@"image"];
        feed.phactPrintedImageURL = [json objectForKey:@"printed_image"];        
        feed.sharedDate = [json objectForKey:@"shared_date"];
        feed.direction = [json objectForKey:@"direction"];
        feed.color = [json objectForKey:@"color"];
        feed.categories = [json objectForKey:@"categories"];
	}
	return feed;
}

+ (void)hideFromFeed:(NSInteger)feedId onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] hideFromFeed:feedId onCompletion:completionHandler resultClass:[Feed class]];
}

@end
