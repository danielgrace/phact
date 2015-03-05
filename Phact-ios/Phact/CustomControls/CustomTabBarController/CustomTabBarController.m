//
//  CustomTabBarController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "CustomTabBarController.h"

@interface CustomTabBarController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTrailingSpaceConstraint;
@end

@implementation CustomTabBarController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	NSAssert([self.viewControllers count] > 0, @"Tab bar controller should contain at least one view controller");
	
	[self.view removeConstraint:self.contentViewTrailingSpaceConstraint];
	NSLayoutConstraint *constrain = [NSLayoutConstraint constraintWithItem:self.view
																 attribute:NSLayoutAttributeWidth
																 relatedBy:0
																	toItem:self.contentView
																 attribute:NSLayoutAttributeWidth
																multiplier:1.0
																  constant:0];
	[self.view addConstraint:constrain];
	
	// FIX: It's not possible to set selected index from outside when creating tab bar controller
	self.selectedIndex = 0;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
	if (self.selectedViewController) {
		[self.selectedViewController willMoveToParentViewController:nil];
		[self.selectedViewController.view removeFromSuperview];
		[self.selectedViewController removeFromParentViewController];
	}
	_selectedViewController = selectedViewController;
	if (self.selectedViewController) {
		[self addChildViewController:self.selectedViewController];
		
		self.selectedViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView insertSubview:self.selectedViewController.view atIndex:0];
		NSDictionary *views = [[NSDictionary alloc] initWithObjectsAndKeys:self.selectedViewController.view, @"subview", nil];
		[self.contentView addConstraints:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
												 options:0
												 metrics:nil
												   views:views]];
		[self.contentView addConstraints:
		 [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|"
												 options:0
												 metrics:nil
												   views:views]];
		
		[self.selectedViewController didMoveToParentViewController:self];
	}
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	NSAssert(selectedIndex < [self.viewControllers count], @"The index is out of range of view controllers");
	_selectedIndex = selectedIndex;
	self.selectedViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
}

@end
