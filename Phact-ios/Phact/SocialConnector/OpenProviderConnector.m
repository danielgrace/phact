//
//  OpenProviderConnector.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "OpenProviderConnector.h"
#import "OpenProviderManager.h"

NSString *const kOpenProviderErrorDomain = @"OpenProviderErrorDomain";

@implementation OpenProviderConnector

- (void)authorizeWithCallback:(AuthorizeCallback)callback {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)retrieveBasicUserInfoWithCallback:(BasicUserInfoRequestCallback)callback {
	[NSException raise:NSInternalInconsistencyException
				format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

@end
