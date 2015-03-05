//
//  AsyncImageCache.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kPhactImageErrorDomain;
extern NSInteger const kPhactImageNoDataErrorCode;
extern NSInteger const kPhactImageInvalidDataErrorCode;

typedef void(^ImageRequestCallback)(UIImage *result, NSError *error, BOOL cached);

@interface AsyncImageCache : NSObject

+ (AsyncImageCache *)mainCache;

- (void)retrieveImageWithURL:(NSString *)url callback:(ImageRequestCallback)callback;

- (void)removeImageForURL:(NSString *)url;

@end
