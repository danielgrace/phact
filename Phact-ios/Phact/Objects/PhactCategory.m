//
//  PhactCategory.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/3/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PhactCategory.h"

@implementation PhactCategory

- (void)encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.categoryId ] forKey:@"category_id"];
    [encoder encodeObject:self.color forKey:@"color"];
    [encoder encodeObject:self.createdDate forKey:@"date_careated"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.categoryId = [[decoder decodeObjectForKey:@"category_id"] intValue];
        self.color = [decoder decodeObjectForKey:@"color"];
        self.createdDate = [decoder decodeObjectForKey:@"date_careated"];
    }
    return self;
}

+ (void)createCategory:(NSString *)name onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] createCategory:name onCompletion:completionHandler resultClass:[PhactCategory class]];
}

+ (void)deleteCategory:(NSInteger)categotyId onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] deleteCategory:categotyId onCompletion:completionHandler resultClass:[PhactCategory class]];
}

+ (id)objectFromJSON:(id)json {
	PhactCategory *category = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
		category = [[PhactCategory alloc] init];
		category.name = [json objectForKey:@"name"];
        category.categoryId = [[json objectForKey:@"category_id"] integerValue];
        category.color = [json objectForKey:@"color"];
        category.createdDate = [json objectForKey:@"date_careated"];
	}
	return category;
}

@end
