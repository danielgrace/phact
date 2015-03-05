//
//  JSONRPCError.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JSONRPCParseError = -32700,
    JSONRPCInvalidRequest = -32600,
    JSONRPCMethodNotFound = -32601,
    JSONRPCInvalidParams = -32602,
    JSONRPCInternalError = -32603
} JSONRPCErrorType;

@interface ASIJSONRPCError : NSObject

@property (nonatomic, readonly)          NSInteger   code;
@property (nonatomic, strong, readonly)  NSString    *message;
@property (nonatomic, strong, readonly)  id          data;

- (id)initWithErrorData:(NSDictionary *)errorData;
+ (ASIJSONRPCError *)errorWithData:(NSDictionary *)errorData;

@end
