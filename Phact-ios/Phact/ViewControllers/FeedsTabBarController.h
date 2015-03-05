//
//  FeedsTabBarController.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "CustomTabBarController.h"

@interface FeedsTabBarController : CustomTabBarController

@property (strong, nonatomic) UIButton *menuButton;
@property (strong, nonatomic) NSMutableArray *selectedPhactIds;

- (void)showLeftSidebarAnimated:(BOOL)animated;
- (void)hideSidebarAnimated:(BOOL)animated;
+ (FeedsTabBarController *)findFromViewController:(UIViewController *)viewController;
- (void)updateUserAvatar;

@end
