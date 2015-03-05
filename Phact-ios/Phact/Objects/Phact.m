//
//  Phact.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/25/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "Phact.h"
#import "NSMutableDictionary+Additions.h"
#import "StringUtils.h"

@implementation Phact

+ (id)objectFromJSON:(id)json {
	Phact *phact = nil;
	if ([json isKindOfClass:[NSDictionary class]]) {
		phact = [[Phact alloc] init];
		if(![[json objectForKey:@"id"] isKindOfClass:[NSNull class]])
			phact.ident = [[json objectForKey:@"id"] integerValue];
		phact.philterName = [json objectForKey:@"philter"];
		phact.desc = [json objectForKey:@"description"];
		phact.image = [json objectForKey:@"image"];
		phact.printedImage = [json objectForKey:@"printed_image"];
		phact.createdDate = [[json objectForKey:@"date_created"] doubleValue];
		phact.location = [json objectForKey:@"location"];
		phact.categories = [json objectForKey:@"categories"];
        phact.colors = [json objectForKey:@"color"];
	}
	return phact;
}

- (NSDictionary *)objectToDictionary {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (self.ident > 0) {
		[dict safeSetObject:[NSNumber numberWithInteger:self.ident] forKey:@"id"];
	}
	[dict safeSetObject:[StringUtils safeStringWithString:self.philterName] forKey:@"philter"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.desc] forKey:@"description"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.philterName] forKey:@"image"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.desc] forKey:@"printed_image"];
	[dict safeSetObject:[NSNumber numberWithDouble:self.createdDate] forKey:@"date_created"];
	[dict safeSetObject:[StringUtils safeStringWithString:self.desc] forKey:@"location"];
	return [dict copy];
}

- (void)savePhact:(CompletionHandler)completionHandler {
    [[PhactPrivateService sharedInstance] savePhactWithImage:self.printedImage image:self.image description:self.desc philter:self.philterName  categories:self.categories date:self.createdDate location:self.location onCompletion:completionHandler resultClass:[Phact class]];
}

+ (void)deletePhact:(NSInteger)phactId onCompletion:(CompletionHandler)completionHandler
{
    [[PhactPrivateService sharedInstance] deletePhact:phactId onCompletion:completionHandler resultClass:[Phact class]];
}

@end
