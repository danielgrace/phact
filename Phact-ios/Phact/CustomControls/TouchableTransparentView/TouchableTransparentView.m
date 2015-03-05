//
//  TouchableTransparentView.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/26/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "TouchableTransparentView.h"

@implementation TouchableTransparentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.6f;
        self.userInteractionEnabled = YES;

    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([[touch.view class] isSubclassOfClass:[UIView class]]) {
        
        [self.delegate touchesBegan];
    }
}

@end
