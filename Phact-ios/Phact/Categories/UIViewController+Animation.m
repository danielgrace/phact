//
//  UIViewController+Animation.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "UIViewController+Animation.h"

@implementation UIViewController (Animation)

- (void) pushViewController:(UIViewController *)viewController completion:(void (^)())completion
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self presentViewController:viewController animated:NO completion:^{
        completion();
    }];
}

- (void) popViewController:(void (^)())completion
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:NO completion:^{
        completion();
    }];
}


@end
