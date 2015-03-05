//
//  Customer.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "Customer.h"
#import "NSMutableDictionary+Additions.h"
#import "StringUtils.h"
#import "Philters.h"

@implementation Customer

+ (id)objectFromJSON:(id)json {
	Customer *customer = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *user = [json objectForKey:@"user"];
		customer = [[Customer alloc] init];
		customer.customerId = [[user objectForKey:@"id"] integerValue];
		customer.email = [user objectForKey:@"usr_email"];
		customer.firstName = [user objectForKey:@"usr_fname"];
		customer.lastName = [user objectForKey:@"usr_lname"];
        customer.encryptedPassword = [user objectForKey:@"usr_pass"];
		customer.customerAvatarURL = [user objectForKey:@"usr_avatar"];
//        customer.philters = [Philters objectFromJSON:[user objectForKey:@"philters"]];
       
		customer.sessionToken = [user objectForKey:@"SessionToken"]; // ??
	}
	return customer;
}

- (NSDictionary *)objectToDictionary {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (self.customerId > 0) {
		[dict safeSetObject:[NSNumber numberWithInteger:self.customerId] forKey:@"Id"];
	}
	[dict safeSetObject:[StringUtils safeStringWithString:self.email] forKey:@"Email"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.firstName] forKey:@"First"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.lastName] forKey:@"Last"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.encryptedPassword] forKey:@"EncryptedPassword"];
	[dict setObject:[Philters objectFromJSON:self.philters] forKey:@"Philters"];
	return [dict copy];
}

+ (void)signUp:(NSString *)firstName lname:(NSString *)lastName email:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler
{
    [[PhactService sharedInstance] signUp:firstName lname:lastName email:email passwd:passwd onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)login:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] login:email passwd:passwd onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)fbConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler
{
    [[PhactService sharedInstance] fbConnect:accessToken onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)fbPrivateConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] fbPrivateConnect:accessToken onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)twitterConnect:(NSString *)userid username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler
{
    [[PhactService sharedInstance] twitterConnect:userid username:username firstname:firstname lastname:lastname avatar:avatar onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)twPrivateConnect:(NSString *)userId username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] twPrivateConnect:userId username:username firstname:firstname lastname:lastname avatar:avatar onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)forgotPassword:(NSString *)email onCompletion:(CompletionHandler)completionHandler
{
    [[PhactService sharedInstance] forgotPassword:email onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)resetPassword:(NSString *)pin password:(NSString *)password onCompletion:(CompletionHandler)completionHandler
{
    [[PhactService sharedInstance] resetPassword:pin password:password onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)changePassword:(NSString *)newPassword onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] changePassword:newPassword onCompletion:completionHandler resultClass:[Customer class]];
}

+ (void)logout:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] logout:completionHandler resultClass:nil];
}

@end
