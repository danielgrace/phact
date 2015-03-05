//
//  BaseService.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/20/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

static ASIJSONRPC *jsonrpc = nil;
static NSString *emptyResponseString = @"Response is missing or empty";
static const NSUInteger emptyResponseCode = 500;


-(id)init{
    self = [super init];
    if(self){
        
        authenticationState = AuthenticationStateNone;
        NSString* webservicehost = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVICE_URL"];
        jsonrpc = [[ASIJSONRPC alloc] initWithServiceEndpoint:[NSURL URLWithString:webservicehost]];
    }
    return self;
    
}

- (void) callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls{
    
    ASIJSONRPCError * jsonRPCError = nil;
    if ( [self checkAuthenticationState:&jsonRPCError] == NO )
    {
        NSError* error = nil;
        [self error:jsonRPCError error:&error];
        completionHandler(nil, error);
        return;
    }
    
    
    [jsonrpc callMethod:methodName withParameters:methodParams authType:authType startAsync:startAsync onCompletion:^(NSString *methodName, NSInteger callId, id methodResult, ASIJSONRPCError *methodError, NSError *internalError){
        
#if DEBUG_MODE
        NSLog(@"==============================================================================");
        NSLog(@"methodName=%@", methodName);
//        NSLog(@"methodParams=%@", methodParams);
        NSLog(@"callId=%ld", (long)callId);
        NSLog(@"methodResult=%@", methodResult);
        NSLog(@"methodError=%@", methodError);
        NSLog(@"internalError=%@", internalError);
#endif
        
        if(internalError){
            completionHandler(nil, internalError);
        }else if(methodError){
            NSError* error = nil;
            [self error:methodError error:&error];
            completionHandler(nil, error);
        }else{
            if (methodResult)
            {
                id object;
                if ([cls respondsToSelector:@selector(objectFromJSON:)]) {
                    object = [cls objectFromJSON:methodResult];
                } else {
                    object = methodResult;
                }
                completionHandler(object, internalError);
            }
            else
            {
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:emptyResponseString forKey:NSLocalizedDescriptionKey];
                NSError* responseError  = [NSError errorWithDomain:self.errorDomainName code:emptyResponseCode userInfo:details];
                completionHandler(nil, responseError);
            }
        }
    }];
}


- (BOOL) checkAuthenticationState:(ASIJSONRPCError **) jsonRPCError
{
    return NO;
}

- (BOOL) error:(ASIJSONRPCError*)jsonError error:(NSError**)error
{
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:jsonError.description forKey:NSLocalizedDescriptionKey];
    if(error) *error = [NSError errorWithDomain:@"json" code:jsonError.code userInfo:details];
    return YES;
}

- (void)resetAuthenticationState
{
    authenticationState = AuthenticationStateNone;
}

+ (id)objectFromJSON:(id)json {
	return json;
}

@end
