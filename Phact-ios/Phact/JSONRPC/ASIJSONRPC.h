//
//  ASIJSONRPC.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIJSONRPCError.h"


#define WEB_SERVICE_HOST    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"WEB_SERVICE_HOST"]
#define API_SECRET          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"API_SECRET"]
#define SECRET_KEY          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SECRET_KEY"]
#define API_KEY             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"API_KEY"]
#define GENERAL_REALM       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GENERAL_REALM"]
#define PRIVATE_REALM       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"PRIVATE_REALM"]



@class ASIJSONRPC;

typedef enum {
    ASIJSONRPCNetworkError = 1,
    ASIJSONRPCParseError = 2
} ASIJSONRPCErrorType;


typedef enum {
    AuthenticationTypeGeneral = 1,
    AuthenticationTypePrivate = 2
} AuthenticationType;


typedef enum {
    AuthenticationStateNone = 1,
    AuthenticationStateGeneral = 2,
    AuthenticationStatePrivate = 3
} AuthenticationState;


/**
 *  Delegate used to provide information regarding web service calls made.
 *
 **/
@protocol ASIJSONRPCDelegate <NSObject>
@optional
/**
 *  Invoked upon the method successfully completing without the error key being set in the response.
 *
 *  methodResult will be the appropriate Objective-C object type based on the type set as the result on the server.
 *
 **/
- (void)jsonRPC:(ASIJSONRPC *)jsonRPC didFinishMethod:(NSString *)methodName forId:(NSInteger)aId withResult:(id)methodResult;

/**
 *  Invoked when the method is completed and the error key is set in the response.
 *
 *  methodError is an Objective-C object which contains all information provided by the offical JSON-RPC error response structure.
 *
 **/
- (void)jsonRPC:(ASIJSONRPC *)jsonRPC didFinishMethod:(NSStream *)methodName forId:(NSInteger)aId withError:(ASIJSONRPCError *)methodError;

/**
 *  Invoked when an error occurs with the connection or when the JSON payload can't be (de)serialized.
 *
 *  The error number will be set to a value defined by ASIJSONRPCError.
 *  localizedDescription is the value from the original error that was generated.
 *
 **/
- (void)jsonRPC:(ASIJSONRPC *)jsonRPC didFailMethod:(NSString *)methodName forId:(NSInteger)aId withError:(NSError *)error;
@end


/**
 *  Invoked when and error occurs or upon method completion.
 *
 *  If methodError is set, the error occured on the server.
 *  methodError is an Objective-C object which contains all information provided by the offical JSON-RPC error response structure.
 *
 *  The internalError value is set when an error occurs with the connection or when the JSON payload can't be (de)serialized.
 *
 *  methodResult will be the appropriate Objective-C object type based on the type set as the result on the server.
 *
 **/
typedef void (^ASIJSONRPCCompletionHandler)(NSString *methodName, NSInteger callId, id methodResult, ASIJSONRPCError *methodError, NSError *internalError);



@interface ASIJSONRPC : NSObject

@property (nonatomic, unsafe_unretained) id<ASIJSONRPCDelegate> delegate;

- (id)initWithServiceEndpoint:(NSURL *)serviceEndpoint;
- (id)initWithServiceEndpoint:(NSURL *)serviceEndpoint andHTTPHeaders:(NSDictionary *)httpHeaders;

#pragma mark - Web Service Invocation Methods
- (NSInteger)callMethod:(NSString *)methodName authType:(AuthenticationType)authType;
- (NSInteger)callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType;

#pragma mark - Web Service Invocation Methods (Completion Handler Based)
- (NSInteger)callMethod:(NSString *)methodName authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(ASIJSONRPCCompletionHandler)completionHandler;
- (NSInteger)callMethod:(NSString *)methodName withParameters:(id)methodParams authType:(AuthenticationType)authType startAsync:(BOOL)startAsync onCompletion:(ASIJSONRPCCompletionHandler)completionHandler;


+ (AuthenticationState)generalAuthentication:(ASIJSONRPCError **)jsonRPCError;
+ (AuthenticationState)privateAuthentication:(NSString *)user password:(NSString *)password jsonRPCError:(ASIJSONRPCError **)jsonRPCError;

@end
