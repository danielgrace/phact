//
//  CustomerSettings.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "CustomerSettings.h"

@implementation CustomerSettings

+ (id)objectFromJSON:(id)jsonRes {
    
    CustomerSettings *customerSettings = nil;
    
    if ([jsonRes isKindOfClass:[NSDictionary class]])
    {
        customerSettings = [[CustomerSettings alloc] init];
        customerSettings.philters = [Philters objectFromJSON:[jsonRes objectForKey:@"philters"]];
        customerSettings.categories = [PhactCategories objectFromJSON:[jsonRes objectForKey:@"categories"]];
    }
	return customerSettings;
}

+ (void)retrieveSettingsWithCustomer:(CompletionHandler)completionHandler {
	[[PhactPrivateService sharedInstance] retrieveSettingsWithCustomer:completionHandler resultClass:[CustomerSettings class]];
}

@end
