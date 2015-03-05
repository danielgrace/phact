//
//  CustomerSettings.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "BaseService.h"
#import "PhactCategories.h"
#import "Philters.h"

@interface CustomerSettings : BaseService

@property (strong, nonatomic) PhactCategories *categories;
@property (strong, nonatomic) Philters *philters;

+ (void)retrieveSettingsWithCustomer:(CompletionHandler)completionHandler;

@end
