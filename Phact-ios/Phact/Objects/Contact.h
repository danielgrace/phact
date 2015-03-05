//
//  Contact.h
//  Phact
//
//  Created by Tigran Kirakosyan on 3/6/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Email : NSObject
@property(nonatomic,strong) NSString		*email;
@property(nonatomic,assign) BOOL			checked;

@end

@interface Contact : NSObject
@property(nonatomic,strong) NSString			*firstName;
@property(nonatomic,strong) NSString			*lastName;
@property(nonatomic,strong) UIImage				*avatar;
@property(nonatomic,strong) NSMutableArray		*emails;

- (id)initWithAvatar:(UIImage *)image firstname:(NSString *)firstname lastname:(NSString *)lastname emails:(NSArray *)emailsArray;
- (void)setCheckedEmailAtIndex:(NSInteger)index;
- (void)setUncheckedEmailAtIndex:(NSInteger)index;

@end
