//
//  PhactAppDelegate.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/11/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseService.h"
#import <HockeySDK/HockeySDK.h>

@class Customer;

@interface PhactAppDelegate : UIResponder <UIApplicationDelegate,BITHockeyManagerDelegate> {
	BOOL appLaunch;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Customer *customer;
@property (strong, nonatomic) UIViewController *rootViewController;

- (Customer *)getCustomerProfile;
- (void)setCustomerProfile:(Customer *)profile;
- (void)loginCustomer;
- (void)registerDeviceToken:(CompletionHandler)completionHandler;
- (void)updateNotificationBadge;

@end
