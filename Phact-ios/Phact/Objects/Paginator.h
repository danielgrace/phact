//
//  Paginator.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/10/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RequestStatusNone,
    RequestStatusInProgress,
    RequestStatusDone // request succeeded or failed
} RequestStatus;

@protocol PaginatorDelegate
@required
- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results;
@optional
- (void)paginatorDidFailToRespond:(id)paginator;
- (void)paginatorDidReset:(id)paginator;
@end

@interface Paginator : NSObject {
    id <PaginatorDelegate> __weak delegate;
}

@property (weak) id delegate;
@property (assign, readonly) NSInteger pageSize; // number of results per page
@property (assign, readonly) NSInteger page; // number of pages already fetched
@property (assign, readonly) NSInteger total; // total number of results
@property (assign, readonly) RequestStatus requestStatus;
@property (nonatomic, strong, readonly) NSMutableArray *results;
@property (assign, nonatomic) NSInteger categoryId;


- (id)initWithPageSize:(NSInteger)pageSize delegate:(id<PaginatorDelegate>)paginatorDelegate;
- (void)reset;
- (BOOL)reachedLastPage;

- (void)fetchFirstPage;
- (void)fetchNextPage;

// call these from subclass when you receive the results
- (void)receivedResults:(NSArray *)results total:(NSInteger)total;
- (void)failed;

@end
