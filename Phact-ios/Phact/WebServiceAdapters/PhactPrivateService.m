//
//  PhactPrivateService.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/20/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhactPrivateService.h"
#import "Philters.h"
#import "OpenUDID.h"

@implementation PhactPrivateService

static PhactPrivateService *sharedInstance = nil;

+(PhactPrivateService *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if(self){
        _errorDomainName =  @"PhactPrivateService";
    }
    return self;
}

- (AuthenticationState) authenticate:(ASIJSONRPCError **) jsonRPCError
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * login = [defaults stringForKey:kuserLogin];
    NSString * passwd = [defaults stringForKey:kuserPasswd];

    authenticationState = [ASIJSONRPC privateAuthentication:login password:passwd jsonRPCError:jsonRPCError];
    
    return authenticationState;
}

- (BOOL) checkAuthenticationState:(ASIJSONRPCError **) jsonRPCError
{
    if ( authenticationState != AuthenticationStatePrivate  )
    {
        if( [self authenticate:jsonRPCError] == AuthenticationStateNone )
        {
            return NO;
        }
    }
    return YES;
}

- (void)login:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    ASIJSONRPCError * jsonRPCError = nil;
    if([ASIJSONRPC privateAuthentication:email password:passwd jsonRPCError:&jsonRPCError] == AuthenticationStateNone)
    {
        NSError* error = nil;
        [self error:jsonRPCError error:&error];
        completionHandler(nil, error);
        return;
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:email forKey:kuserLogin];
    [defaults setValue:passwd forKey:kuserPasswd];
    [defaults synchronize];
   
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [paramDict setValue:[OpenUDID value] forKey:@"open_udid"];

    [self callMethod:@"login" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)fbPrivateConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:accessToken forKey:@"token"];
    [paramDict setValue:[OpenUDID value] forKey:@"open_udid"];
    
    [self callMethod:@"fbConnect" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)twPrivateConnect:(NSString *)userId username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data setValue:username forKey:@"username"];
    [data setValue:userId forKey:@"id"];
    [data setValue:firstname forKey:@"firstname"];
    [data setValue:lastname forKey:@"lastname"];
    [data setValue:avatar forKey:@"picture"];
    [data setValue:[OpenUDID value] forKey:@"open_udid"];
	
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [paramDict setValue:data forKey:@"data"];
	
    [self callMethod:@"twitterConnect" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)logout:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:[OpenUDID value] forKey:@"open_udid"];
    [self callMethod:@"logout" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];    
}

- (void)retrievePhiltersWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls {
    [self callMethod:@"philters" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)retrieveCategoriesWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls {
    [self callMethod:@"getCategories" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)retrieveSettingsWithCustomer:(CompletionHandler)completionHandler resultClass:(Class)cls {
    [self callMethod:@"getSettings" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)updatePhilters:(Philters *)philters customer:(NSInteger)customerId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
	NSArray *activePhilters = [NSArray arrayWithArray:philters.activePhilters];
	NSArray *inActivePhilters = [NSArray arrayWithArray:philters.inActivePhilters];
    [data setValue:activePhilters forKey:@"active"];
    [data setValue:inActivePhilters forKey:@"passive"];
    
    [self callMethod:@"syncPhilters" withParameters:data authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)imageSearch:(NSString *)image onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:image forKey:@"image"];
    
    [self callMethod:@"imageSearch" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)storeImage:(NSString *)image option:(BOOL)option onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:image forKey:@"image"];
    [paramDict setValue:[NSNumber numberWithInteger:!option] forKey:@"stored"];
    
    [self callMethod:@"storeImage" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)doSearch:(NSString *)body location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:body forKey:@"body"];
    [paramDict setValue:location forKey:@"geo_location"];
    
    [self callMethod:@"doSearch" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)searchByBestGuess:(NSString *)context location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:context forKey:@"bestGuess"];
    [paramDict setValue:location forKey:@"location"];
    
    [self callMethod:@"searchByBestGuess" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)savePhactWithImage:(NSString *)printedImage image:(NSString *)image description:(NSString *)description philter:(NSString *)philter categories:(NSArray *)categories date:(NSTimeInterval)date location:(NSString *)location onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
	
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:6];
    
    [paramDict setValue:printedImage forKey:@"printed_image"];
    [paramDict setValue:image forKey:@"image"];
    [paramDict setValue:description forKey:@"description"];
    [paramDict setValue:philter forKey:@"philter"];
    [paramDict setValue:[NSNumber numberWithDouble:date] forKey:@"date_created"];
    [paramDict setValue:location forKey:@"location"];
    [paramDict setValue:categories forKey:@"categories"];
    
    [self callMethod:@"savePhact" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)loadPhactsByCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:[NSNumber numberWithInteger:categoryId ] forKey:@"category_id"];
    
    [self callMethod:@"getUserPhacts" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)registerAPNS:(NSString *)token onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:token forKey:@"token"];
    [paramDict setValue:[OpenUDID value] forKey:@"open_udid"];

    [self callMethod:@"setAPNSToken" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)getFriends:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    [self callMethod:@"getFriends" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)findFriends:(CompletionHandler)completionHandler
{
    [self callMethod:@"findFriends" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)shareWithFriends:(NSArray *)friendFacebookIds  savedPhactId:(NSInteger)savedPhactId onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:friendFacebookIds forKey:@"friends"];
    [paramDict setValue:[NSNumber numberWithInteger:savedPhactId ] forKey:@"phact"];

    [self callMethod:@"shareWithFriends" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)getFeedsWithPage:(NSUInteger)page categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:[NSNumber numberWithInteger:page] forKey:@"page"];
    [paramDict setValue:[NSNumber numberWithInteger:categoryId] forKey:@"category_id"];
    
    [self callMethod:@"getFeed" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)hideFromFeed:(NSInteger)feedId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:[NSNumber numberWithInteger:feedId] forKey:@"feed_id"];
    
    [self callMethod:@"hideFromFeed" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)markPhactsAsRead:(NSArray *)ids onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:ids forKey:@"ids"];
    [self callMethod:@"markAsRead" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)getUnreadPhacts:(CompletionHandler)completionHandler resultClass:(Class)cls {
    [self callMethod:@"getUnreadPhacts" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)createCategory:(NSString *)name onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:name forKey:@"name"];
    
    [self callMethod:@"createCategory" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)deleteCategory:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:[NSNumber numberWithInteger:categoryId ] forKey:@"category_id"];
    
    [self callMethod:@"deleteCategory" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)addPhactToCategory:(NSArray *)phactIds categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:phactIds forKey:@"phact_ids"];
    [paramDict setValue:[NSNumber numberWithInteger:categoryId ] forKey:@"category_id"];
    
    [self callMethod:@"addPhactToCategory" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)removePhactFromCategory:(NSInteger)phactId categoryId:(NSInteger)categoryId onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:[NSNumber numberWithInteger:phactId ] forKey:@"phact_id"];
    [paramDict setValue:[NSNumber numberWithInteger:categoryId ] forKey:@"category_id"];
    
    [self callMethod:@"removePhactFromCategory" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)changePassword:(NSString *)newPassword onCompletion:(CompletionHandler)completionHandler  resultClass:(Class)cls {
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:newPassword forKey:@"newPassword"];
    
    [self callMethod:@"resetPassword" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)deletePhact:(NSInteger)phactId onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:[NSNumber numberWithInteger:phactId ] forKey:@"phact_id"];
    [self callMethod:@"deletePhact" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil]; 
}

- (void)uploadAvatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:avatar forKey:@"picture"];
    
    [self callMethod:@"saveAvatar" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)sendAddressBook:(NSArray *)contacts onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
    [params setValue:contacts forKey:@"data"];
	
    [self callMethod:@"addressBook" withParameters:params authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:[NSNumber class]];
}

- (void)sendInviteEmails:(NSArray *)contacts onCompletion:(CompletionHandler)completionHandler
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] initWithCapacity:1];
    [param setValue:contacts forKey:@"items"];

    [self callMethod:@"inviteFriendsEmail" withParameters:param authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)getProfileNumbers:(CompletionHandler)completionHandler
{
    [self callMethod:@"getProfileNumbers" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:[NSDictionary class]];
}

- (void)getOwnPhacts:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    [self callMethod:@"getOwnPhacts" withParameters:nil authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

@end
