//
//  Feed.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"

@interface Feed : BaseService
@property (assign, nonatomic) NSInteger userIdTo;
@property (assign, nonatomic) NSInteger userIdFrom;
@property (assign, nonatomic) NSInteger phactId;
@property (assign, nonatomic) NSInteger feedId;
@property (copy, nonatomic) NSString *usernameTo;
@property (copy, nonatomic) NSString *usernameFrom;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *philterName;
@property (copy, nonatomic) NSString *phactImageURL;
@property (copy, nonatomic) NSString *phactPrintedImageURL;
@property (copy, nonatomic) NSString *sharedDate;
@property (copy, nonatomic) NSString *desc;
@property (copy, nonatomic) NSString *direction;
@property (copy, nonatomic) NSString *color;
@property (strong, nonatomic) NSMutableArray *categories;
@property (assign, nonatomic) BOOL markAsRead;

+ (id)objectFromJSON:(id)json;

+ (void)hideFromFeed:(NSInteger) feedId onCompletion:(CompletionHandler)completionHandler;

@end
