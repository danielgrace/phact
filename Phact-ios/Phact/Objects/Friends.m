//
//  Friends.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/13/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Friends.h"
#import "PhactPrivateService.h"

@implementation Friends

+ (void)getFriends:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] getFriends:completionHandler resultClass:[Friends class]];
}

+ (id)objectFromJSON:(id)jsonRes {
    
    Friends *friends = nil;
    if ([jsonRes isKindOfClass:[NSDictionary class]])
    {
        id jsonData = [jsonRes objectForKey:@"data"];
        if ([jsonData isKindOfClass:[NSArray class]]) {
            NSMutableArray *friendList = [[NSMutableArray alloc] init];
            for (id friendJson in jsonData) {
                Friend *friend = [Friend objectFromJSON:friendJson];
                if (friend) {
                    [friendList addObject:friend];
                }
            }
            friends = [[Friends alloc] init];
            friends.friendsList = [friendList copy];
        }
    }
	return friends;
}


@end
