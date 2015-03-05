//
//  PhactService.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"

@interface PhactService : BaseService

+ (PhactService *)sharedInstance;
- (void)signUp:(NSString *)firstName lname:(NSString *)lastName email:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)freshInstall:(CompletionHandler)completionHandler;
- (void)fbConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)twitterConnect:(NSString *)userid username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)forgotPassword:(NSString *)email onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)resetPassword:(NSString *)pin password:(NSString *)password onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;

@end
