//
//  JSONRPCError.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ASIJSONRPCError.h"

@implementation ASIJSONRPCError

@synthesize code, message, data;

- (id)initWithErrorData:(NSDictionary *)errorData {
    if (!(self = [super init]))
        return self;
    
    code    = [[errorData objectForKey:@"code"] intValue];
    message = [errorData objectForKey:@"message"];
    data    = [errorData objectForKey:@"data"];
    
    
    return self;
}

+ (ASIJSONRPCError *)errorWithData:(NSDictionary *)errorData
{
    ASIJSONRPCError *error = [[self alloc] initWithErrorData:errorData];
    return error;
}


- (NSString *)description {
//    return [NSString stringWithFormat:@"ASIJSONRPC Error: %@ (Code: %i) - Data: %@", self.message, self.code, self.data];
    return [NSString stringWithFormat:@"%@", self.data];
}

@end
