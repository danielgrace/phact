//
//  TwitterConnector.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/24/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "TwitterConnector.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "OpenProviderManager.h"
#import "NSMutableDictionary+Additions.h"
#import "StringUtils.h"

@interface TwitterConnector ()

@property (strong, nonatomic) ACAccount *account;

@end

@implementation TwitterConnector

- (void)authorizeWithCallback:(AuthorizeCallback)callback {
	ACAccountType *accountType = [self.manager.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[self.manager.accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSError *err = nil;
			NSDictionary *errorUserData = [NSDictionary dictionaryWithObject:@"Twitter" forKey:@"AccountType"];
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
	[parameters setObject:self.account.username forKey:@"screen_name"];
	[parameters setObject:@"false" forKey:@"include_entities"];
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
											requestMethod:SLRequestMethodGET
													  URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"]
											   parameters:parameters];
	request.account = self.account;
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSMutableDictionary *basicUserInfo = nil;
			NSError *err = nil;
			if (!error) {
				id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
				if (!err) {
					NSArray *errorsArray = [jsonObject objectForKey:@"errors"];
					if (errorsArray) {
						NSString *message = nil;
						NSInteger code = 0;
						NSDictionary *errorDictionary = [errorsArray lastObject];
						if (errorDictionary) {
							message = [errorDictionary objectForKey:@"message"];
							code = [[errorDictionary objectForKey:@"code"] integerValue];
						}
						NSDictionary *userInfo = nil;
						if (message) {
							userInfo = [NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey];
						}
						err = [NSError errorWithDomain:kOpenProviderErrorDomain code:code userInfo:userInfo];
					} else {
						basicUserInfo = [[NSMutableDictionary alloc] init];
						[basicUserInfo setObject:@"Twitter" forKey:@"provider"];
                        [basicUserInfo safeSetObject:self.account.credential.oauthToken forKey:@"accessToken"];// ??
						[basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"id"]] forKey:@"userId"];
                        [basicUserInfo safeSetObject:[StringUtils safeStringWithString:[jsonObject objectForKey:@"screen_name"]] forKey:@"userName"];
						NSString *name = [StringUtils safeStringWithString:[jsonObject objectForKey:@"name"]];
						NSArray *nameComponents = [name componentsSeparatedByString:@" "];
						if ([nameComponents count] > 0) {
							[basicUserInfo safeSetObject:[nameComponents objectAtIndex:0] forKey:@"firstName"];
							if ([nameComponents count] > 1) {
								[basicUserInfo safeSetObject:[nameComponents objectAtIndex:1] forKey:@"lastName"];
							}
						}
						NSString *profilePictureURL = [StringUtils safeStringWithString:[jsonObject objectForKey:@"profile_image_url"]];
						if ([profilePictureURL length] > 0) {
							NSArray *pathComponents = [profilePictureURL pathComponents];
							NSString *fileExtension = [[pathComponents lastObject] pathExtension];
							NSString *fileName = [[pathComponents lastObject] stringByDeletingPathExtension];
							if ([fileName hasSuffix:@"_normal"]) {
								fileName = [fileName substringWithRange:NSMakeRange(0, [fileName length] - [@"_normal" length])];
								profilePictureURL = [[[[profilePictureURL stringByDeletingPathExtension] stringByDeletingLastPathComponent] stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:fileExtension];
							}
							[basicUserInfo safeSetObject:profilePictureURL forKey:@"avatarURL"];
						}
					}
				}
			} else {
				err = error;
			}
			callback(basicUserInfo, err);
		});
	}];
}

@end
