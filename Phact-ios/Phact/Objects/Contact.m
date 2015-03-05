//
//  Contact.m
//  Phact
//
//  Created by Tigran Kirakosyan on 3/6/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "Contact.h"


@implementation Email

- (id)initWithEmail:(NSString *)strEmail {
    if (self = [super init]) {
        _email = [[NSString alloc] initWithString:strEmail];
		_checked = NO;
    }
    return self;
}

@end
	
@implementation Contact

- (id)init {
    if (self = [super init]) {
        _firstName = [NSString string];
        _lastName = [NSString string];
        _emails = [NSMutableArray array];
    }
    return self;
}

- (id)initWithAvatar:(UIImage *)image firstname:(NSString *)firstname lastname:(NSString *)lastname emails:(NSArray *)emailsArray {
    if (self = [super init]) {
        _firstName = [[NSString alloc] initWithString:firstname];
        _lastName = [[NSString alloc] initWithString:lastname];
        _avatar = image;
        _emails = [[NSMutableArray alloc] init];
		for(int i = 0; i < emailsArray.count; i++) {
			Email *email = [[Email alloc] initWithEmail:[emailsArray objectAtIndex:i]];
			[_emails addObject:email];
		}
    }
    return self;
}

- (void)setCheckedEmailAtIndex:(NSInteger)index {
	Email *email = [self.emails objectAtIndex:index];
	email.checked = YES;
}

- (void)setUncheckedEmailAtIndex:(NSInteger)index {
	Email *email = [self.emails objectAtIndex:index];
	email.checked = NO;
}

@end
