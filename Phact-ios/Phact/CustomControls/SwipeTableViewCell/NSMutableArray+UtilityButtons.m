//
//  NSMutableArray+UtilityButtons.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "NSMutableArray+UtilityButtons.h"

@implementation NSMutableArray (UtilityButtons)

- (void)addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    [self addObject:button];
}

@end

