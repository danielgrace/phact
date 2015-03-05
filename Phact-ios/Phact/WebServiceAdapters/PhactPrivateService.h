//
//  PhactPrivateService.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/20/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseService.h"

@class Philters;

@interface PhactPrivateService : BaseService

+ (PhactPrivateService *)sharedInstance;
- (AuthenticationState) authenticate:(ASIJSONRPCError **) jsonRPCError;

- (void)login:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)logout:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)fbPrivateConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)twPrivateConnect:(NSString *)userId username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;

- (void)retrievePhiltersWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)retrieveCategoriesWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)retrieveSettingsWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls;

- (void)updatePhilters:(Philters *)philters customer:(NSInteger)customerId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;

- (void)imageSearch:(NSString *)image onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)storeImage:(NSString *)image  option:(BOOL)option onCompletion:(CompletionHandler)completionHandler;
- (void)doSearch:(NSString *)body location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)searchByBestGuess:(NSString *)context location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;

- (void)savePhactWithImage:(NSString *)printedImage image:(NSString *)image description:(NSString *)description philter:(NSString *)philter categories:(NSArray *)categories date:(NSTimeInterval)date location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)loadPhactsByCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)registerAPNS:(NSString *)token onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)getFriends:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)findFriends:(CompletionHandler)completionHandler;
- (void)shareWithFriends:(NSArray *)friendFacebookId  savedPhactId:(NSInteger)savedPhactId onCompletion:(CompletionHandler)completionHandler;
- (void)getFeedsWithPage:(NSUInteger)page categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)hideFromFeed:(NSInteger) feedId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)markPhactsAsRead:(NSArray *)ids onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)getUnreadPhacts:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)createCategory:(NSString *)name onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)deleteCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)addPhactToCategory:(NSArray *)phactIds categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler;
- (void)removePhactFromCategory:(NSInteger)phactId categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler;
- (void)changePassword:(NSString *)newPassword onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)deletePhact:(NSInteger)phactId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (void)uploadAvatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler;
- (void)sendAddressBook:(NSArray *)contacts onCompletion:(CompletionHandler)completionHandler;
- (void)sendInviteEmails:(NSArray *)contacts onCompletion:(CompletionHandler)completionHandler;
- (void)getProfileNumbers:(CompletionHandler)completionHandler;
- (void)getOwnPhacts:(CompletionHandler)completionHandler resultClass:(Class)cls;

@end
