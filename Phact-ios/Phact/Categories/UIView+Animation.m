//
//  UIView+Animation.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/25/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

- (void) moveTo:(CGPoint)destination duration:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.frame = CGRectMake(destination.x,destination.y, self.frame.size.width, self.frame.size.height);
                     }
                     completion:nil];
}

- (void) downUnder:(float)secs option:(UIViewAnimationOptions)option
{
    [UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, M_PI);
                     }
                     completion:nil];
}

- (void) addSubviewWithZoomInAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option
{
    CGAffineTransform trans = CGAffineTransformScale(view.transform, 0.01, 0.01);
    view.transform = trans;
    [self addSubview:view];
    [UIView animateWithDuration:secs delay:0.0 options:option
        animations:^{
            view.transform = CGAffineTransformScale(view.transform, 100.0, 100.0);
        }
        completion:nil];	
}

- (void) removeWithZoomOutAnimation:(float)secs option:(UIViewAnimationOptions)option
{
	[UIView animateWithDuration:secs delay:0.0 options:option
    animations:^{
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    }
    completion:^(BOOL finished) { 
        [self removeFromSuperview]; 
    }];
}

- (void) addSubviewWithFadeAnimation:(UIView*)view duration:(float)secs option:(UIViewAnimationOptions)option
{
	view.alpha = 0.0;
	[self addSubview:view];
	[UIView animateWithDuration:secs delay:0.0 options:option
                     animations:^{view.alpha = 1.0;}
                     completion:nil];
}


- (void) removeWithSinkAnimation:(int)steps
{
	NSTimer *timer;
	if (steps > 0 && steps < 100)
		self.tag = steps;
	else
		self.tag = 50;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(removeWithSinkAnimationRotateTimer:) userInfo:nil repeats:YES];
}

- (void) removeWithSinkAnimationRotateTimer:(NSTimer*) timer
{
	CGAffineTransform trans = CGAffineTransformRotate(CGAffineTransformScale(self.transform, 0.9, 0.9),0.314);
	self.transform = trans;
	self.alpha = self.alpha * 0.98;
	self.tag = self.tag - 1;
	if (self.tag <= 0)
	{
		[timer invalidate];
		[self removeFromSuperview];
	}
}

- (void) pushView:(UIView *)view duration:(float)secs completion:(void (^)())completion
{
    CGRect viewSize = self.frame;
    
    [self.superview addSubview:view];
    
    view.frame = CGRectMake( 320 , viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:secs animations:
     ^{
         self.frame = CGRectMake( -320 , viewSize.origin.y, 320, viewSize.size.height);
         view.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
     }
                     completion:^(BOOL finished)
     {
         if (finished)
         {
             [self removeFromSuperview];
             completion();
         }
     }];
}

- (void) popView:(UIView *)view duration:(float)secs completion:(void (^)())completion
{
    CGRect viewSize = self.frame;
    
    [self.superview addSubview:view];
 
    view.frame = CGRectMake( -320 , viewSize.origin.y, 320, viewSize.size.height);
    
    [UIView animateWithDuration:secs animations:
     ^{
         self.frame = CGRectMake( 320 , viewSize.origin.y, 320, viewSize.size.height);
         view.frame = CGRectMake(0, viewSize.origin.y, 320, viewSize.size.height);
     }
                     completion:^(BOOL finished)
     {
         if (finished)
         {
             [self removeFromSuperview];
             completion();
         }
     }];

}

@end
