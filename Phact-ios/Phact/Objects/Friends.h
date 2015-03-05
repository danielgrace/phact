//
//  Friends.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/13/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"
#import "Friend.h"

@interface Friends : BaseService

@property (strong, nonatomic) NSArray *friendsList;

+ (void)getFriends:(CompletionHandler)completionHandler;

@end
