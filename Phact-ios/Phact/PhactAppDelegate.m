//
//  PhactAppDelegate.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/11/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhactAppDelegate.h"
#import "RegistrationViewController.h"
#import "SettingsViewController.h"
#import "PhactService.h"
#import "PhactPrivateService.h"
#import "Customer.h"
#import "Definitions.h"
#import "OpenProviderManager.h"
#import "Philters.h"
#import "FeedViewController.h"
#import "FeedsTabBarController.h"
#import "PhactCategories.h"
#import "Contacts.h"
#import "Flurry.h"

static NSString *kAPIConfigurationKey = @"APIConfiguration";
static NSString *kOpenProviderConfigurationKey = @"OpenProviderConfiguration";


@interface PhactAppDelegate ()

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, assign) BOOL viewNotifications;

@end

@implementation PhactAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
	[Flurry startSession:@"6VXHVY4KMTTMZVQHRK5X"];
#ifndef DEBUG
	NSDictionary *hockeyApp = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HockeyApp"];
	NSString *betaAppID = [hockeyApp objectForKey:@"BetaAppID"];
	NSString *liveAppID = [hockeyApp objectForKey:@"LiveAppID"];
		
	[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:betaAppID liveIdentifier:liveAppID delegate:self];
	[[[BITHockeyManager sharedHockeyManager] crashManager] setShowAlwaysButton:YES];
	[[BITHockeyManager sharedHockeyManager] startManager];
	[[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    NSDictionary *openProviderConfiguration = [[NSBundle mainBundle] objectForInfoDictionaryKey:kOpenProviderConfigurationKey];
	[[OpenProviderManager instance] setConfiguration:openProviderConfiguration];

	_customer = [[Customer alloc] init];

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		[application setStatusBarStyle:UIStatusBarStyleLightContent];
		self.window.clipsToBounds = YES;
		self.window.frame =  CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height-20);
		
		self.window.bounds = CGRectMake(0, 20, self.window.frame.size.width, self.window.frame.size.height);

		[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
	}
	else {
		[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]];
	}
	
//	[[UIBarButtonItem appearance] setBackButtonBackgroundImage:[UIImage imageNamed:@"back.png"]
//													  forState:UIControlStateNormal
//													barMetrics:UIBarMetricsDefault];
	
	[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0], UITextAttributeTextColor,
														  [UIFont fontWithName:@"NewsGothicBT-Light" size:18.0], UITextAttributeFont,nil]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* isDeviceInfoSent = [userDefaults stringForKey:kisDeviceInfoSent];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kuserLogin];

    if(isDeviceInfoSent && username)
    {
		FeedsTabBarController *feedsTabBarController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"FeedsTabBarController"];
        self.window.rootViewController = feedsTabBarController;
        self.rootViewController = feedsTabBarController;
    }
    else
    {
        self.rootViewController = self.window.rootViewController;
    }

	appLaunch = YES;

	// Setup push notifications
	if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		[application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[application registerForRemoteNotifications];
	} else {
		[application registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
	}
	
	NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (payload) {
        NSInteger badgeNumber = [[[payload objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
        application.applicationIconBadgeNumber = badgeNumber;
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* isDeviceInfoSent = [userDefaults stringForKey:kisDeviceInfoSent];
    if(!isDeviceInfoSent){
        self.rootViewController = self.window.rootViewController;
        [self sendDeviceInfo];
    }

	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kuserLogin];
	if(appLaunch && (username == nil)) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main"
                                                     bundle:nil];
		RegistrationViewController *registrationViewController = [sb instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
		UINavigationController *registrationNavigationController = [[UINavigationController alloc] initWithRootViewController:registrationViewController];
		[self.rootViewController presentViewController:registrationNavigationController animated:NO completion:^{
		}];
		appLaunch = NO;
	}
	else {
		self.customer.email = username;
		self.customer.firstName = [[NSUserDefaults standardUserDefaults] objectForKey:kuserFirstname];
		self.customer.lastName = [[NSUserDefaults standardUserDefaults] objectForKey:kuserLastname];
		self.customer.encryptedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kuserPasswd];
		self.customer.customerAvatarURL = [[NSUserDefaults standardUserDefaults] objectForKey:kuserAvatarUrl];
        self.customer.regType = ( RegisterType)[[[NSUserDefaults standardUserDefaults] objectForKey:kuserRegType] integerValue];
		
		Philters *philters = self.customer.philters;
		if(philters == nil)
			philters = [[Philters alloc] init];
			
		philters.activePhilters = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"TopPhilters"]];
		philters.inActivePhilters = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MorePhilters"]];
		self.customer.philters = philters;
        
        PhactCategories *categories = self.customer.categories;
        if(categories == nil)
            categories = [[PhactCategories alloc] init];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *encodedObject = [defaults objectForKey:@"Categories"];
        categories = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        self.customer.categories = categories;
		
//		[self setCustomerProfile:self.customer];
		
		Contacts *contacts = [Contacts sharedInstance];
		contacts.bSendContacts = YES;
		if(appLaunch) {
			[contacts registerAddressBookChange];
			appLaunch = NO;
		}

		if(self.viewNotifications) {
			if([self.rootViewController isKindOfClass:[FeedsTabBarController class]]) {
				FeedsTabBarController *feedsTabBarController = (FeedsTabBarController *)self.rootViewController;
				UINavigationController *feedNavController = [feedsTabBarController.viewControllers objectAtIndex:0];
				FeedViewController *feedViewController = (FeedViewController *)feedNavController.topViewController;
				
				feedsTabBarController.selectedIndex = 0;				
				[feedViewController loadFeedsByCategory:0];
				
				[feedsTabBarController hideSidebarAnimated:YES];
			}
			else {
				FeedsTabBarController *feedsTabBarController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"FeedsTabBarController"];
				self.window.rootViewController = feedsTabBarController;
				self.rootViewController = feedsTabBarController;
			}
			self.viewNotifications = NO;
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loginCustomer {
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kuserLogin];
	if(username == nil) {
		RegistrationViewController *registrationViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"RegistrationViewController"];
		UINavigationController *registrationNavigationController = [[UINavigationController alloc] initWithRootViewController:registrationViewController];
		[self.rootViewController presentViewController:registrationNavigationController animated:NO completion:^{
		}];
	}
}

- (Customer *)getCustomerProfile {
	return self.customer;
}

- (void)setCustomerProfile:(Customer *)profile {
	self.customer = profile;
}

- (void)sendDeviceInfo {
    
    [[PhactService sharedInstance] freshInstall:^(NSNumber *result, NSError *error) {
        if(error == nil)
        {
                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                [defaults setValue:@"Yes" forKey:kisDeviceInfoSent];
                [defaults synchronize];
        }
    }];
}

#pragma mark Push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
#if DEBUG_MODE
    NSLog(@"Received device token: %@", devToken);
#endif
    self.deviceToken = [[[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
#if DEBUG_MODE
    NSLog(@"strDeviceToken=%@", self.deviceToken);
#endif
	NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kuserLogin];
    if(username) {
        [self registerDeviceToken:^(id result, NSError *error) {
			if (!error) {
#if DEBUG_MODE
				NSLog(@"result = %@",result);
#endif
			}
			else
			{
				NSLog(@"RegisterDeviceToken Error: %@", [error description]);
			}
		}];
	}
}

- (void)registerDeviceToken:(CompletionHandler)completionHandler {
	[[PhactPrivateService sharedInstance] registerAPNS:self.deviceToken onCompletion:completionHandler resultClass:nil];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to retrieve a push device token: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo {
#if DEBUG_MODE
	NSLog(@"Received Notification: %@", userInfo);
#endif
    NSInteger badgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
    application.applicationIconBadgeNumber = badgeNumber;
#if DEBUG_MODE
	NSLog(@"- badgeNumber = %ld",(long)badgeNumber);
#endif
    UIApplicationState state = [application applicationState];
    if (state != UIApplicationStateActive) {
        self.viewNotifications = YES;
    }
}

- (void)updateNotificationBadge {
    [self getUnreadPhacts:^(NSNumber *result, NSError *error) {
        if(!error)
        {
			NSInteger badgeNumber = [result integerValue];
#if DEBUG_MODE
			NSLog(@"badgeNumber = %ld",(long)badgeNumber);
#endif
			[UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
        }
		else
		{
			NSLog(@"getUnreadPhacts Error: %@", [error description]);
		}
    }];
}

- (void)getUnreadPhacts:(CompletionHandler)completionHandler {
    [[PhactPrivateService sharedInstance] getUnreadPhacts:completionHandler resultClass:[NSNumber class]];
}

@end
