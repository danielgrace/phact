//
//  Feeds.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"
#import "Feed.h"

@interface Feeds : BaseService
@property (strong, nonatomic) NSArray *feedArray;

+ (void)getFeedsWithPage:(NSUInteger)page categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler;

@end
