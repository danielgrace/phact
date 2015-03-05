//
//  FeedPaginator.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/10/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "FeedPaginator.h"
#import "Feeds.h"

@implementation FeedPaginator

# pragma - fetch feeds

- (void)fetchResultsWithPage:(NSInteger)page categoryId:(NSInteger)categoryId pageSize:(NSInteger)pageSize
{
	[Feeds getFeedsWithPage:page categoryId:categoryId onCompletion:^(id result, NSError *error) {
		if (!error) {
			
			Feeds *feeds = (Feeds *)result;
			if(feeds)
			{
				if(feeds.feedArray)
				{
					[self receivedResults:feeds.feedArray total:1000];
				}
			}
		}
		else
		{
#if DEBUG_MODE
			NSLog(@"getFeeds Error = %@",[error localizedDescription]);
#endif
			[self receivedResults:nil total:10000];
		}
		
	}];
	
	
}


@end
