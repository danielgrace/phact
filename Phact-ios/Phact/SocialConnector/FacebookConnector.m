//
//  FacebookConnector.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "FacebookConnector.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "OpenProviderManager.h"
#import "NSMutableDictionary+Additions.h"
#import "StringUtils.h"

typedef void(^UserProfilePictureURLRequestCallback)(NSString *profilePictureURL, NSError *error);

@interface FacebookConnector ()

@property (strong, nonatomic) ACAccount *account;

- (void)retrieveUserProfilePictureURLWithCallback:(UserProfilePictureURLRequestCallback)callback;

@end

@implementation FacebookConnector

- (void)authorizeWithCallback:(AuthorizeCallback)callback {
	NSString *facebookAppID = [self.configuration objectForKey:@"AppID"];
	ACAccountType *accountType = [self.manager.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 facebookAppID, ACFacebookAppIdKey,
							 [NSArray arrayWithObjects:@"email", nil], ACFacebookPermissionsKey, nil];
	[self.manager.accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSError *err = nil;
			NSDictionary *errorUserData = [NSDictionary dictionaryWithObject:@"Facebook" forKey:@"AccountType"];
			if (granted) {
				NSArray *accounts = [self.manager.accountStore accountsWithAccountType:accountType];
				self.account = [accounts lastObject];
				if (!self.account) {
					err = [NSError errorWithDomain:ACErrorDomain code:ACErrorAccountNotFound userInfo:errorUserData];
				}
			} else {
				NSInteger code = error ? error.code : ACErrorPermissionDenied;
				err = [NSError errorWithDomain:ACErrorDomain code:code userInfo:errorUserData];
			}
			callback(err);
		});
	}];
}

- (void)retrieveBasicUserInfoWithCallback:(BasicUserInfoRequestCallback)callback {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:@"id,first_name,last_name,email" forKey:@"fields"];
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
											requestMethod:SLRequestMethodGET
													  URL:[NSURL URLWithString:@"https://graph.facebook.com/me"]
											   parameters:parameters];
	request.account = self.account;
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableDictionary *basicUserInfo = nil;
			NSError *err = nil;
			if (!error) {
				id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
				if (!err) {
					NSDictionary *errorDictionary = [jsonObject objectForKey:@"error"];
					if (errorDictionary) {
						NSString *message = [errorDictionary objectForKey:@"message"];
						NSInteger code = [[errorDictionary objectForKey:@"code"] integerValue];
						NSDictionary *userInfo = nil;
						if (message) {
							userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
						}
						err = [NSError errorWithDomain:kOpenProviderErrorDomain code:code userInfo:userInfo];
					} else {
						basicUserInfo = [[NSMutableDictionary alloc] init];
						[basicUserInfo setObject:@"Facebook" forKey:@"provider"];
						[basicUserInfo safeSetObject:self.account.credential.oauthToken forKey:@"accessToken"];
						[basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"id"]] forKey:@"userId"];
						[basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"email"]] forKey:@"email"];
						[basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"first_name"]] forKey:@"firstName"];
						[basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"last_name"]] forKey:@"lastName"];

						[self retrieveUserProfilePictureURLWithCallback:^(NSString *profilePictureURL, NSError *error) {
							if (!error) {
								[basicUserInfo safeSetObject:profilePictureURL forKey:@"avatarURL"];
							}
							callback(basicUserInfo, err);
						}];
					}
				}
			} else {
				err = error;
			}
			if (err) {
				callback(basicUserInfo, err);
			}
		});
	}];
}

- (void)retrieveUserProfilePictureURLWithCallback:(UserProfilePictureURLRequestCallback)callback {
	NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
	[parameters setObject:@"false" forKey:@"redirect"];
	[parameters setObject:@"9999" forKey:@"width"];
	[parameters setObject:@"9999" forKey:@"height"];
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
											requestMethod:SLRequestMethodGET
													  URL:[NSURL URLWithString:@"https://graph.facebook.com/me/picture"]
											   parameters:parameters];
	request.account = self.account;
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSString *profilePictureURL = nil;
			NSError *err = nil;
			if (!error) {
				id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
				if (!err) {
					NSDictionary *errorDictionary = [jsonObject objectForKey:@"error"];
					if (errorDictionary) {
						NSString *message = [errorDictionary objectForKey:@"message"];
						NSInteger code = [[errorDictionary objectForKey:@"code"] integerValue];
						NSDictionary *userInfo = nil;
						if (message) {
							userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
						}
						err = [NSError errorWithDomain:kOpenProviderErrorDomain code:code userInfo:userInfo];
					} else {
						profilePictureURL = [StringUtils safeStringWithString:[jsonObject valueForKeyPath:@"data.url"]];
					}
				}
			} else {
				err = error;
			}
			callback(profilePictureURL, err);
		});
	}];
}

@end
