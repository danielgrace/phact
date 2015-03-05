//
//  OpenProviderManager
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "OpenProviderManager.h"
#import "OpenProviderConnector.h"
#import "FacebookConnector.h"
#import "TwitterConnector.h"

@implementation OpenProviderManager

+ (OpenProviderManager *)instance {
	static dispatch_once_t singletonPredicate;
	static OpenProviderManager *singleton = nil;

	dispatch_once(&singletonPredicate, ^{
		singleton = [[super allocWithZone:nil] init];
	});

	return singleton;
}

- (ACAccountStore *)accountStore {
	if (!_accountStore) {
		_accountStore = [[ACAccountStore alloc] init];
	}
	return _accountStore;
}

- (OpenProviderConnector *)facebookConnector {
	if (!_facebookConnector) {
		_facebookConnector = [[FacebookConnector alloc] init];
		_facebookConnector.manager = self;
		_facebookConnector.configuration = [self.configuration objectForKey:@"Facebook"];
	}
	return _facebookConnector;
}

- (OpenProviderConnector *)twitterConnector {
	if (!_twitterConnector) {
		_twitterConnector = [[TwitterConnector alloc] init];
		_twitterConnector.manager = self;
		_twitterConnector.configuration = [self.configuration objectForKey:@"Twitter"];
	}
	return _twitterConnector;
}

@end
