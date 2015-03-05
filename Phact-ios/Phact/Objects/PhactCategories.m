//
//  PhactCategories.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PhactCategories.h"
#import "PhactCategory.h"

@implementation PhactCategories

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.categoriesArray forKey:@"categories"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.categoriesArray = [decoder decodeObjectForKey:@"categories"];
    }
    return self;
}


+ (id)objectFromJSON:(id)jsonRes {
    
    PhactCategories *categories = nil;
    if ([jsonRes isKindOfClass:[NSArray class]])
    {
		NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
		for (id item in jsonRes) {
			PhactCategory *category = [PhactCategory objectFromJSON:item];
			if (category) {
				[categoryArray addObject:category];
			}
		}
		categories = [[PhactCategories alloc] init];
		categories.categoriesArray = categoryArray ;
    }
	return categories;
}

+ (void)retrieveCategoriesWithCustomer:(CompletionHandler)completionHandler {
	[[PhactPrivateService sharedInstance] retrieveCategoriesWithCustomer:completionHandler resultClass:[PhactCategories class]];
}


@end
