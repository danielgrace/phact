//
//  OpenProviderConnector.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kOpenProviderErrorDomain;

typedef void(^AuthorizeCallback)(NSError *error);
typedef void(^BasicUserInfoRequestCallback)(NSDictionary *userInfo, NSError *error);

@class OpenProviderManager;

@interface OpenProviderConnector : NSObject

@property (weak, nonatomic) OpenProviderManager *manager;
@property (strong, nonatomic) NSDictionary *configuration;

- (void)authorizeWithCallback:(AuthorizeCallback)callback;
- (void)retrieveBasicUserInfoWithCallback:(BasicUserInfoRequestCallback)callback;

@end
