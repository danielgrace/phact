//
//  CustomTabBarController.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTabBarController : UIViewController
@property (strong, nonatomic) NSArray *viewControllers;
@property (weak, nonatomic) UIViewController *selectedViewController;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (weak,nonatomic) IBOutlet UIView *contentView;
@end
