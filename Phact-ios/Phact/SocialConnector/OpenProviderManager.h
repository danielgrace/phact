//
//  OpenProviderManager.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OpenProviderConnector;
@class ACAccountStore;

@interface OpenProviderManager : NSObject

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSDictionary *configuration;

@property (strong, nonatomic) OpenProviderConnector *facebookConnector;
@property (strong, nonatomic) OpenProviderConnector *twitterConnector;

+ (OpenProviderManager *)instance;

@end
