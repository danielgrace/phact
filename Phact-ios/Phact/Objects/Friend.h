//
//  Friend.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/13/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"

@interface Friend : BaseService

@property (copy, nonatomic) NSString* friendUserId;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *friendAvatarURL;
@property (assign, nonatomic) BOOL checked;

+ (id)objectFromJSON:(id)json;

@end
