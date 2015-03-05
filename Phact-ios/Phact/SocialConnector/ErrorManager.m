//
//  ErrorManager.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 22/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ErrorManager.h"
#import <Accounts/Accounts.h>

@implementation ErrorManager

+ (void)showErrorAlertWithError:(NSError *)error {
	NSString *title = @"Error";
	NSString *message = [[error userInfo] objectForKey:NSLocalizedDescriptionKey];

	if (!message) {
		if ([error.domain isEqualToString:ACErrorDomain]) {
			NSString *accountType = [error.userInfo objectForKey:@"AccountType"];
			switch (error.code) {
				case ACErrorAccountNotFound:
					message = [NSString stringWithFormat:@"There are no %@ accounts configured. You can add or create a %@ account in Settings.", accountType, accountType];
					break;
				case ACErrorPermissionDenied:
					message = [NSString stringWithFormat:@"Access has not been granted to the %@ account. Verify device Settings.", accountType];
					break;
				default:
					break;
			}
		}
	}
	if (!message) {
		message = @"Something went wrong.";
	}
	[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

}

@end
