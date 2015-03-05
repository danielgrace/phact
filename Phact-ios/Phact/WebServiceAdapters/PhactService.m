//
//  PhactService.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhactService.h"
#import "ASIJSONRPC.h"
#import "JSONKit.h"
#import "OpenUDID.h"
#import "DeviceUtils.h"

@implementation PhactService

static PhactService *sharedInstance = nil;

+(PhactService *)sharedInstance {
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
        _errorDomainName =  @"PhactService";
    }
    return self;
}

- (AuthenticationState) authenticate:(ASIJSONRPCError **)jsonRPCError;
{
    authenticationState = [ASIJSONRPC generalAuthentication:jsonRPCError];
    return authenticationState;
}

- (void)signUp:(NSString *)firstName lname:(NSString *)lastName email:(NSString *)email passwd:(NSString *)passwd onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    [self resetAuthenticationState];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setValue:firstName forKey:@"usr_fname"];
    [data setValue:lastName forKey:@"usr_lname"];
    [data setValue:email forKey:@"usr_email"];
    [data setValue:passwd forKey:@"usr_pass"];
    [data setValue:[OpenUDID value] forKey:@"open_udid"];

    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [paramDict setValue:data forKey:@"data"];
    
    [self callMethod:@"SignUp" withParameters:paramDict authType:AuthenticationTypeGeneral startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)freshInstall:(CompletionHandler)completionHandler
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSString *deviceName = [[UIDevice currentDevice] model];
    NSString *iosVersion = [[UIDevice currentDevice] systemVersion];
    NSString *openUDID = [OpenUDID value];
    NSString *macAddress = [DeviceUtils getMacAddress];
    NSString *ipAddress = [DeviceUtils getIPAddress];
    
    [data setValue:deviceName forKey:@"name"];
    [data setValue:openUDID forKey:@"open_udid"];
    [data setValue:iosVersion forKey:@"os_version"];
    [data setValue:ipAddress forKey:@"ip"];
    [data setValue:macAddress forKey:@"mac"];
    
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [paramDict setValue:data forKey:@"data"];
    
    [self callMethod:@"freshInstall" withParameters:paramDict authType:AuthenticationTypeGeneral startAsync:YES onCompletion:completionHandler resultClass:nil];
}

- (void)fbConnect:(NSString *)accessToken onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:accessToken forKey:@"token"];
    [paramDict setValue:[OpenUDID value] forKey:@"open_udid"];
    
    [self callMethod:@"fbConnect" withParameters:paramDict authType:AuthenticationTypeGeneral startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)twitterConnect:(NSString *)userid username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    [data setValue:username forKey:@"username"];
    [data setValue:userid forKey:@"id"];
    [data setValue:firstname forKey:@"firstname"];
    [data setValue:lastname forKey:@"lastname"];
    [data setValue:avatar forKey:@"picture"];
    [data setValue:[OpenUDID value] forKey:@"open_udid"];

    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    [paramDict setValue:data forKey:@"data"];

    [self callMethod:@"twitterConnect" withParameters:paramDict authType:AuthenticationTypePrivate startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)forgotPassword:(NSString *)email onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    [self resetAuthenticationState];
    
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    [paramDict setValue:email forKey:@"email"];
    [self callMethod:@"forgotPassRequest" withParameters:paramDict authType:AuthenticationTypeGeneral startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (void)resetPassword:(NSString *)pin password:(NSString *)password onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls
{
    NSMutableDictionary* paramDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [paramDict setValue:pin forKey:@"pin"];
    [paramDict setValue:password forKey:@"newPassword"];
    [self callMethod:@"resetPassword" withParameters:paramDict authType:AuthenticationTypeGeneral startAsync:YES onCompletion:completionHandler resultClass:cls];
}

- (BOOL) checkAuthenticationState:(ASIJSONRPCError **) jsonRPCError
{
    if ( authenticationState != AuthenticationStateGeneral )
    {
        if( [self authenticate:jsonRPCError] == AuthenticationStateNone )
        {
            return NO;
        }
    }
    return YES;
}


- (BOOL) error:(ASIJSONRPCError*)jsonError error:(NSError**)error
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:jsonError.description forKey:NSLocalizedDescriptionKey];
    if(error) *error = [NSError errorWithDomain:@"json" code:jsonError.code userInfo:details];
    return YES;
}


@end
