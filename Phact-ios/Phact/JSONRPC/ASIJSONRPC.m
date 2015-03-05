//
//  ASIJSONRPC.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ASIJSONRPC.h"
#import "JSONKit.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "NSString+NSStringDigestAdditions.h"
#import "OpenUDID.h"

#ifdef __OBJC_GC__
#error Demiurgic JSON-RPC does not support Objective-C Garbage Collection
#endif

AuthenticationState authenticationState = AuthenticationStateNone;


@interface ASIJSONRPC () // Private
@property (nonatomic, strong) NSURL               *serviceEndpoint;
@property (nonatomic, strong) NSDictionary        *httpHeaders;
@property (nonatomic, strong) NSMutableDictionary *activeConnections;


@end

@implementation ASIJSONRPC

@synthesize delegate;
@synthesize serviceEndpoint = _serviceEndpoint;
@synthesize httpHeaders = _httpHeaders;
@synthesize activeConnections = _activeConnections;


- (id)initWithServiceEndpoint:(NSURL *)serviceEndpoint; {
    return [self initWithServiceEndpoint:serviceEndpoint andHTTPHeaders:nil];
}

- (id)initWithServiceEndpoint:(NSURL *)serviceEndpoint andHTTPHeaders:(NSDictionary *)httpHeaders {
    if (!(self = [super init]))
        return self;
    
    self.serviceEndpoint = serviceEndpoint;
    self.httpHeaders     = httpHeaders;
    
    self.activeConnections = [NSMutableDictionary dictionary];
    
    return self;
}


#pragma mark - Web Service Invocation Methods

- (NSInteger)callMethod:(NSString *)methodName authType:(AuthenticationType)authType {
    return [self callMethod:methodName withParameters:nil authType:authType];
}

- (NSInteger)callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType {
    return [self callMethod:methodName withParameters:methodParams authType:authType startAsync:YES onCompletion:nil];
}

#pragma mark - Web Service Invocation Methods (Completion Handler Based)
- (NSInteger)callMethod:(NSString *)methodName authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(ASIJSONRPCCompletionHandler)completionHandler {
    return [self callMethod:methodName withParameters:nil authType:authType startAsync:startAsync onCompletion:completionHandler];
}
 
- (NSInteger)callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(ASIJSONRPCCompletionHandler)completionHandler {
    // Generate a random Id for the call
    NSInteger aId = arc4random();
    
    // Setup the JSON-RPC call payload
    NSArray *methodKeys = nil;
    NSArray *methodObjs = nil;
    if (methodParams) {
        methodKeys = [NSArray arrayWithObjects:@"jsonrpc", @"method", @"params", @"id", nil];
        methodObjs = [NSArray arrayWithObjects:@"2.0", methodName, methodParams, [NSNumber numberWithInteger:aId], nil];
    }
    else {
        methodKeys = [NSArray arrayWithObjects:@"jsonrpc", @"method", @"id", nil];
        methodObjs = [NSArray arrayWithObjects:@"2.0", methodName, [NSNumber numberWithInteger:aId], nil];
    }
    
    // Create call payload
    NSDictionary *methodCall = [NSDictionary dictionaryWithObjects:methodObjs forKeys:methodKeys];
    
    // Attempt to serialize the call payload to a JSON string
    NSError *error;
    NSData *postData = [methodCall JSONDataWithOptions:JKSerializeOptionNone error:&error];
    
    if (error != nil) {
        if (completionHandler || delegate) {
            NSError *aError = [NSError errorWithDomain:@"PhactService.json-rpc" code:ASIJSONRPCParseError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], NSLocalizedDescriptionKey, nil]];
            
            if (completionHandler) {
                completionHandler(methodName, aId, nil, nil, aError);
                completionHandler = nil;
            }
            else if ([delegate respondsToSelector:@selector(jsonRPC:didFailMethod:forId:withError:)]) {
                [delegate jsonRPC:self didFailMethod:methodName forId:aId withError:aError];
            }
        }
    }
    
    // Create the JSON-RPC request
    ASIHTTPRequest *request = [[ASIFormDataRequest alloc] initWithURL:self.serviceEndpoint];
    __weak ASIHTTPRequest *wRequest = request;
    
    request.shouldAttemptPersistentConnection = NO;
    
    [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
//    [request addRequestHeader:@"User-Agent" value:@"ASIJSONRPC/1.0"];
    
    // Add custom HTTP headers
    for (id key in self.httpHeaders) {
        [request addRequestHeader:key value:[self.httpHeaders objectForKey:key]];
    }
    
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length]];
    
    [request setValidatesSecureCertificate:NO];
    [request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:20];
    [request setDelegate:self];
//    [request setDidFinishSelector: @selector(ASIJSONRPCFinished:)];
//    [request setDidFailSelector: @selector(ASIJSONRPCFailed:)];
    [request appendPostData: postData];
    
    // Create dictionary to store information about the request so we can recall it later
    NSMutableDictionary *connectionInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [connectionInfo setObject:methodName forKey:@"method"];
    [connectionInfo setObject:@(aId) forKey:@"id"];
    if (completionHandler != nil) {
        ASIJSONRPCCompletionHandler completionHandlerCopy = [completionHandler copy];
        [connectionInfo setObject:completionHandlerCopy forKey:@"completionHandler"];
    }
    [connectionInfo setObject:[NSNumber numberWithInt:authType] forKey:@"authType"];
    [self.activeConnections setObject:connectionInfo forKey:[NSNumber numberWithInt:(int)request]];
    
    [request setCompletionBlock:^() {
        if (completionHandler != nil)
            [self ASIJSONRPCFinished:wRequest];
    }];
    [request setFailedBlock:^{
        
        [self ASIJSONRPCFailed:wRequest];
    }];
    
    if(startAsync)
        [request startAsynchronous];
    else
        [request startSynchronous];
    
    return aId;
}


- (void)ASIJSONRPCFailed:(ASIHTTPRequest *)request {
    
    NSNumber *connectionKey = @((int)request);
    NSMutableDictionary *connectionInfo = [self.activeConnections objectForKey:connectionKey];
    ASIJSONRPCCompletionHandler completionHandler = [connectionInfo objectForKey:@"completionHandler"];
    
    NSError *error = [request error];
    
#if DEBUG_MODE
    NSLog(@"************************ERROR*********************************");
    NSLog(@"response error:%@",[error localizedDescription]);
#endif
    
    if (completionHandler || delegate) {
        NSError *aError = [NSError errorWithDomain:@"PhactService.json-rpc" code:ASIJSONRPCNetworkError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], NSLocalizedDescriptionKey, nil]];
        
        if (completionHandler) {
            completionHandler([connectionInfo objectForKey:@"method"], [[connectionInfo objectForKey:@"id"] intValue], nil, nil, aError);
        }
        else if ([delegate respondsToSelector:@selector(jsonRPC:didFailMethod:forId:withError:)]) {
            [delegate jsonRPC:self didFailMethod:[connectionInfo objectForKey:@"method"] forId:[[connectionInfo objectForKey:@"id"] intValue] withError:aError];
        }
    }
    [self.activeConnections removeObjectForKey:connectionKey];
}


- (void)ASIJSONRPCFinished:(ASIHTTPRequest *)request {
    
    NSNumber *connectionKey = @((int)request);
    NSMutableDictionary *connectionInfo = [self.activeConnections objectForKey:connectionKey];
    ASIJSONRPCCompletionHandler completionHandler = [connectionInfo objectForKey:@"completionHandler"];
    
#if DEBUG_MODE
    NSLog(@"*********************************************************");
    NSLog(@"response:%@",[request responseString]);
    NSLog(@"ASIJSONRPCFinished response code = %d", [request responseStatusCode]);
#endif
    
    NSData *response = [request responseData];
    if (response) {
        NSError *error = nil;
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary* jsonResult = [decoder objectWithData:response error:&error];
        if (error) {
            [self sendErrorReport:request authType:[[connectionInfo objectForKey:@"authType"] intValue]];
            NSError *aError = [NSError errorWithDomain:@"PhactService.json-rpc" code:ASIJSONRPCParseError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription], NSLocalizedDescriptionKey, nil]];
            
            if (completionHandler || delegate) {
                // Pass the error to the delegate if they care, completion handler takes presidence
                if (completionHandler) {
                    completionHandler([connectionInfo objectForKey:@"method"], [[connectionInfo objectForKey:@"id"] intValue], nil, nil, aError);
                    completionHandler = nil;
                }
                if (delegate && [delegate respondsToSelector:@selector(jsonRPC:didFailMethod:forId:withError:)]) {
                    [delegate jsonRPC:self didFailMethod:[connectionInfo objectForKey:@"method"] forId:[[connectionInfo objectForKey:@"id"] intValue] withError:aError];
                }
            }
        }
        
        
        // The JSON server passed back and error for the response
        if (!error && [jsonResult objectForKey:@"error"] != nil && [[jsonResult objectForKey:@"error"] isKindOfClass:[NSDictionary class]]) {
            
//            [self sendErrorReport:request];
            if (completionHandler || delegate) {
                ASIJSONRPCError *jsonRPCError = [ASIJSONRPCError errorWithData:[jsonResult objectForKey:@"error"]];
                
                // Give the error to the delegate if they care, completion handler takes presidence
                if (completionHandler) {
                    completionHandler([connectionInfo objectForKey:@"method"], [[connectionInfo objectForKey:@"id"] intValue], nil, jsonRPCError, nil);
                    completionHandler = nil;
                }
                else if (delegate && [delegate respondsToSelector:@selector(jsonRPC:didFinishMethod:forId:withError:)]) {
                    [delegate jsonRPC:self didFinishMethod:[connectionInfo objectForKey:@"method"] forId:[[connectionInfo objectForKey:@"id"] intValue] withError:jsonRPCError];
                }
            }
        }
        
        // Not error, give delegate the method result
        else if (!error && (completionHandler || delegate)) {
            if (completionHandler) {
                completionHandler([connectionInfo objectForKey:@"method"], [[connectionInfo objectForKey:@"id"] intValue], [jsonResult objectForKey:@"result"], nil, nil);
                completionHandler = nil;
            }
            else if ([delegate respondsToSelector:@selector(jsonRPC:didFinishMethod:forId:withResult:)]) {
                [delegate jsonRPC:self didFinishMethod:[connectionInfo objectForKey:@"method"] forId:[[connectionInfo objectForKey:@"id"] intValue] withResult:[jsonResult objectForKey:@"result"]];
            }
        }
    }
    else
    {
        [self ASIJSONRPCFailed:request];
    }
    
    [self.activeConnections removeObjectForKey:connectionKey];
}

+(void)initializeGeneralAuthentication
{
    NSString *service_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVICE_URL"];
	[ASIHTTPRequest removeCredentialsForHost:service_url port:0 protocol:@"http" realm:GENERAL_REALM ];
	[ASIHTTPRequest clearSession];
}


+ (AuthenticationState) generalAuthentication:(ASIJSONRPCError **)jsonRPCError
{
    [self initializeGeneralAuthentication];
    
    NSString *service_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVICE_URL"];
    NSURL *url = [[NSURL alloc] initWithString:service_url];
    ASIHTTPRequest *request;
    NSError *err;
    
    request = [[ASIHTTPRequest alloc] initWithURL:url];
    
    request.shouldAttemptPersistentConnection = NO;
    [request setValidatesSecureCertificate:NO];
    [request setUseSessionPersistence:YES];
    [request setUseKeychainPersistence:YES];
    [request setRequestMethod:@"POST"];
    [request setUsername:API_KEY];
    
    NSString *inputString = [NSString stringWithFormat:@"%@:%@", API_SECRET,SECRET_KEY];
    NSString *sha1Pasword = [NSString sha1:inputString];
    [request setPassword:sha1Pasword];
    
    [request startSynchronous];
    err = [request error];

#if DEBUG_MODE
    NSLog(@"*********************************************************");
    NSLog(@"request:%@",[url absoluteString]);
    NSLog(@"response:%@",[request responseString]);
    NSLog(@"*********************************************************");
    NSLog(@"eroor = %@", [err localizedDescription]);
    NSLog(@"general response code = %d", [request responseStatusCode]);
#endif
    
    NSData *response = [request responseData];
    if(response)
    {
        NSError *error = nil;
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary* jsonResult = [decoder objectWithData:response error:&error];
        *jsonRPCError = [ASIJSONRPCError errorWithData:[jsonResult objectForKey:@"error"]];
    }
    else
    {
        NSMutableDictionary* errorData = [[NSMutableDictionary alloc] initWithCapacity:3];
        [errorData setValue:NSLocalizedString(@"There is no network connection available",nil) forKey:@"data"];
        [errorData setValue:@"" forKey:@"message"];
        [errorData setValue:@"" forKey:@"code"];
        *jsonRPCError = [ASIJSONRPCError errorWithData:errorData];
    }
    
    return ([request responseStatusCode] == 200 ) ? AuthenticationStateGeneral : AuthenticationStateNone;
}

+(void)initializePrivateAuthentication
{
    NSString *service_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVICE_URL"];
	[ASIHTTPRequest removeCredentialsForHost:service_url port:0 protocol:@"http" realm:PRIVATE_REALM];
	[ASIHTTPRequest clearSession];
}

+(AuthenticationState)privateAuthentication:(NSString *)user password:(NSString *)password jsonRPCError:(ASIJSONRPCError **)jsonRPCError
{
    if((user == NULL) || (password == NULL))
        return AuthenticationStateNone;
    
    [self initializePrivateAuthentication];
    
    NSString *service_url = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SERVICE_URL"];
    NSURL *url = [[NSURL alloc] initWithString:service_url];
    ASIFormDataRequest *request;
    NSError *err;
    
    request = [[ASIFormDataRequest alloc] initWithURL:url];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request setValidatesSecureCertificate:NO];
    
    request.shouldAttemptPersistentConnection = NO;
    [request setUseSessionPersistence:YES];
    [request setUseKeychainPersistence:YES];
    [request setPostValue:@"" forKey:@"private"];
    [request setRequestMethod:@"POST"];
    [request setUsername:user];
    
    NSString *inputString = [NSString stringWithFormat:@"%@:%@", password,SECRET_KEY];
    NSString *sha1Pasword = [NSString sha1:inputString];
    [request setPassword:sha1Pasword];
    
    [request startSynchronous];
    err = [request error];
    
#if DEBUG_MODE
    NSLog(@"*********************************************************");
    NSLog(@"request:%@",[url absoluteString]);
    NSLog(@"response:%@",[request responseString]);
    NSLog(@"*********************************************************");
    NSLog(@"eroor = %@", [err localizedDescription]);
    NSLog(@"private response code = %d", [request responseStatusCode]);
#endif
    
    NSData *response = [request responseData];
    if(response)
    {
        NSError *error = nil;
        JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionNone];
        NSDictionary* jsonResult = [decoder objectWithData:response error:&error];
        *jsonRPCError = [ASIJSONRPCError errorWithData:[jsonResult objectForKey:@"error"]];
    }
    else
    {
        NSMutableDictionary* errorData = [[NSMutableDictionary alloc] initWithCapacity:3];
        [errorData setValue:NSLocalizedString(@"There is no network connection available",nil) forKey:@"data"];
        [errorData setValue:@"" forKey:@"message"];
        [errorData setValue:@"" forKey:@"code"];
        *jsonRPCError = [ASIJSONRPCError errorWithData:errorData];
    }
    return ([request responseStatusCode] == 200 ) ? AuthenticationStatePrivate : AuthenticationStateNone;
}


- (void)sendErrorReport:(ASIHTTPRequest *)request authType:(AuthenticationType)authType {
    NSNumber *connectionKey = @((int)request);
    NSMutableDictionary *connectionInfo = [self.activeConnections objectForKey:connectionKey];
    NSMutableData *connectionData = [connectionInfo objectForKey:@"data"];
    
    if(![[connectionInfo objectForKey:@"method"] isEqualToString:@"errorReport"]){
        NSMutableDictionary* parseErrorParamDict = [NSMutableDictionary dictionaryWithCapacity:2];
        [parseErrorParamDict setValue:[[NSString alloc] initWithData: [request responseData] encoding: NSUTF8StringEncoding] forKey:@"params"];
        [parseErrorParamDict setValue:[[NSString alloc] initWithData: connectionData encoding: NSUTF8StringEncoding]  forKey:@"response"];
        [self callMethod:@"errorReport" withParameters:parseErrorParamDict authType:authType];
    }
}

@end
