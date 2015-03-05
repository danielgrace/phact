//
//  AsyncImageCache.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "AsyncImageCache.h"
#import "ASIHTTPRequest.h"

NSString *const kPhactImageErrorDomain = @"PhactImageErrorDomain";
NSInteger const kPhactImageNoDataErrorCode = 1;
NSInteger const kPhactImageInvalidDataErrorCode = 2;

@interface AsyncImageCache ()

@property (strong, nonatomic) NSMutableDictionary *imageCache;
@property (strong, nonatomic) NSMutableDictionary *waitingCallbacks;
@property (nonatomic, retain) NSOperationQueue *queue;

- (void)purge;

@end

@implementation AsyncImageCache

+ (AsyncImageCache *)mainCache {
	static dispatch_once_t singletonPredicate;
	static AsyncImageCache *singleton = nil;
	
	dispatch_once(&singletonPredicate, ^{
		singleton = [[super allocWithZone:nil] init];
	});
	
	return singleton;
}

- (id)init {
	self = [super init];
	if (self) {
		self.imageCache = [[NSMutableDictionary alloc] init];
		self.waitingCallbacks = [[NSMutableDictionary alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purge) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [_queue cancelAllOperations];
}

- (void)purge {
	[self.imageCache removeAllObjects];
}

- (void)retrieveImageWithURL:(NSString *)url callback:(ImageRequestCallback)callback {

	id image = [self.imageCache objectForKey:url];
	if ([image isKindOfClass:[UIImage class]]) {
		callback(image, nil, YES);
	} else {
		NSMutableArray *waitingCallbacks = [self.waitingCallbacks objectForKey:url];
		if ([waitingCallbacks isKindOfClass:[NSMutableArray class]]) {
			[waitingCallbacks addObject:callback];
		} else {
			waitingCallbacks = [[NSMutableArray alloc] init];
			[self.waitingCallbacks setObject:waitingCallbacks forKey:url];
			[waitingCallbacks addObject:callback];

            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            __weak ASIHTTPRequest *wrequest = request;
            
            [request setCompletionBlock:^{
                UIImage *image = nil;
                NSError *error = nil;
                if (wrequest.responseStatusCode == 200) {
                    NSData *data = [wrequest responseData];
                    if (data) {
                        image = [UIImage imageWithData:data];
                    }
                }
                if (image) {
                    [self.imageCache setObject:image forKey:url];
                } else {
                    [self.imageCache setObject:[NSNull null] forKey:url];
                    error = [[NSError alloc] initWithDomain:kPhactImageErrorDomain code:kPhactImageInvalidDataErrorCode userInfo:nil];
                }
				NSArray *waitingCallbacks = [self.waitingCallbacks objectForKey:url];
				if ([waitingCallbacks isKindOfClass:[NSArray class]]) {
					for (ImageRequestCallback cb in waitingCallbacks) {
						cb(image, error, NO);
					}
				}
                [self.waitingCallbacks removeObjectForKey:url];
            }];
            
            [request setFailedBlock:^{

                UIImage *image = nil;
                NSError *error = [[NSError alloc] initWithDomain:kPhactImageErrorDomain code:kPhactImageInvalidDataErrorCode userInfo:nil];
				NSArray *waitingCallbacks = [self.waitingCallbacks objectForKey:url];
				if ([waitingCallbacks isKindOfClass:[NSArray class]]) {
					for (ImageRequestCallback cb in waitingCallbacks) {
						cb(image, error, NO);
					}
				}
                [self.waitingCallbacks removeObjectForKey:url];
            }];
            [self.queue addOperation:request];
		}
	}
}

- (void)removeImageForURL:(NSString *)url {
	[self.imageCache removeObjectForKey:url];
}

@end
