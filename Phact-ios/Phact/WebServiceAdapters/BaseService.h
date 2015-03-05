//
//  BaseService.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/20/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIJSONRPC.h"

@interface BaseService : NSObject{
    
@protected
    __unsafe_unretained NSString *_errorDomainName;
    AuthenticationState authenticationState;
}

@property (nonatomic, assign) NSString *errorDomainName ;

typedef void (^CompletionHandler)(id methodResults, NSError *error);

- (BOOL) checkAuthenticationState:(ASIJSONRPCError **) jsonRPCError;
- (void) resetAuthenticationState;
- (void) callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(CompletionHandler)completionHandler resultClass:(Class)cls;
- (BOOL) error:(ASIJSONRPCError*)jsonError error:(NSError**)error;

@end