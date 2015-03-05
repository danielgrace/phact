//
//  CameraFocusSquare.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/28/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "CameraFocusSquare.h"
#import <QuartzCore/QuartzCore.h>

@implementation CameraFocusSquare

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        CABasicAnimation* selectionAnimation = [CABasicAnimation
                                                animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)[UIColor colorWithRed:92.0/255.0 green:227.0/255.0 blue:2.0/255.0 alpha:1].CGColor;
        selectionAnimation.duration = 3.0;
        selectionAnimation.repeatCount = 1;
        [self.layer addAnimation:selectionAnimation
                          forKey:@"selectionAnimation"];
        
    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    if (self) {
    }
    return self;
}

-(void) setPos:(CGPoint) point
{
    [self setAlpha:1.0];
    [self setFrame:CGRectMake(point.x-self.frame.size.width/2, point.y-self.frame.size.height/2,self.frame.size.width,self.frame.size.height )];
}

@end
