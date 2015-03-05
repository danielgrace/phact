//
//  UIViewController+Animation.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Animation)

- (void) pushViewController:(UIViewController *)viewController completion:(void (^)())completion;
- (void) popViewController:(void (^)())completion;

@end
