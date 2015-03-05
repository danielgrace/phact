//
//  Customer.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhactService.h"
#import "PhactPrivateService.h"

@class PhactCategories;

typedef enum {
    RegisterType_None = 0,
    RegisterType_Email = 1,
    RegisterType_Facebook = 2,
    RegisterType_Twitter = 3
} RegisterType;

@interface Customer : BaseService

@property (assign, nonatomic) NSInteger customerId;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *sessionToken;
@property (copy, nonatomic) NSString *customerAvatarURL;
@property (copy, nonatomic) NSString *encryptedPassword;
@property (strong, nonatomic) Philters *philters;
@property (strong, nonatomic) PhactCategories *categories;
@property (assign, nonatomic) RegisterType regType;

+ (void)signUp:(NSString *)firstName lname:(NSString *)lastName email:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler;
+ (void)login:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler;
+ (void)fbConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler;
+ (void)fbPrivateConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler;
+ (void)twitterConnect:(NSString *)userid username:(NSString *)userName firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler;
+ (void)twPrivateConnect:(NSString *)userId username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler;
+ (void)forgotPassword:(NSString *)email onCompletion:(CompletionHandler)completionHandler;
+ (void)resetPassword:(NSString *)pin password:(NSString *)password onCompletion:(CompletionHandler)completionHandler;
+ (void)changePassword:(NSString *)password onCompletion:(CompletionHandler)completionHandler;
+ (void)logout:(CompletionHandler)completionHandler;

@end
