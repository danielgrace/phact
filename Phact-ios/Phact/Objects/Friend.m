//
//  Friend.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/13/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Friend.h"

@implementation Friend

+ (id)objectFromJSON:(id)json {
	Friend *friend = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
		friend = [[Friend alloc] init];
        friend.firstName = [json objectForKey:@"usr_fname"];
        friend.lastName = [json objectForKey:@"usr_lname"];
        friend.friendUserId = [json objectForKey:@"id"];
        friend.friendAvatarURL = [json objectForKey:@"usr_avatar"];
        
	}
	return friend;
}

@end

