 //
//  FeedsTabBarController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "FeedsTabBarController.h"
#import "DimView.h"
#import "FeedViewController.h"
#import "PhactsArchiveViewController.h"
#import "ProfileViewController.h"
#import "PhactCategory.h"
#import "PhactCategories.h"
#import "PhactAppDelegate.h"
#import "Customer.h"
#import "PopListViewCell.h"
#import "UIColor-Expanded.h"
#import "AsyncImageCache.h"
#import "UIImage+Additions.h"

//static CGFloat const kPanMinimumDistance = 10.0;

@interface FeedsTabBarController ()
@property (weak,nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *contentViewLeadingSpaceConstraint;
@property (weak,nonatomic) IBOutlet UIView *dimView;
@property (weak,nonatomic) IBOutlet UIView *leftSidebarView;
@property (weak,nonatomic) IBOutlet UITableView *leftSidebarTableView;
@property (weak,nonatomic) IBOutlet UIButton *accountProfileButton;
@property (weak,nonatomic) IBOutlet UIButton *phlowButton;
@property (weak,nonatomic) IBOutlet UIButton *archiveButton;
@property (weak,nonatomic) IBOutlet UIButton *createTagButton;
@property (weak,nonatomic) IBOutlet UIView *separator;
@property (weak,nonatomic) IBOutlet UIView *separator1;
@property (weak,nonatomic) IBOutlet UIView *separator2;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *leftSidebarViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (strong,nonatomic) PhactCategories *categories;
@property (strong,nonatomic) Customer *customer;
@property (assign,nonatomic) BOOL leftSidebarOpen;
@property (assign,nonatomic) BOOL createCategoryAction;
@property (strong,nonatomic) id notificationObserver;


- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer;
- (IBAction)showPhlow:(id)sender;

@end

@interface FeedsTabBarController(Protocols) <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, DimViewDelegate>
@end

@implementation FeedsTabBarController

- (void)awakeFromNib {
	[super awakeFromNib];

	_selectedPhactIds = [[NSMutableArray alloc] init];
    FeedViewController *feedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedViewController"];
    UINavigationController *feedNavigationController = [[UINavigationController alloc] initWithRootViewController:feedViewController];
    
    PhactsArchiveViewController *archiveViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhactsArchiveViewController"];
    UINavigationController *archiveNavigationController = [[UINavigationController alloc] initWithRootViewController:archiveViewController];
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
    
	self.viewControllers = [[NSArray alloc] initWithObjects:feedNavigationController,archiveNavigationController,profileNavigationController, nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
		self.leftSidebarViewTopConstraint.constant = 20;
	}
	else {
		self.leftSidebarViewTopConstraint.constant = 0;
	}

	self.createTagButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:20.0];

	self.accountProfileButton.titleLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
	self.accountProfileButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
	
	self.phlowButton.titleLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
	self.phlowButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];

    self.archiveButton.titleLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
	self.archiveButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];

	UIImage *menuButtonImage = [UIImage imageNamed:@"menu-button.png"];
	self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[self.menuButton setImage:menuButtonImage forState:UIControlStateNormal];
	self.menuButton.bounds = CGRectMake(0, 0, 40, 44);
	[self.menuButton addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
	self.customer = [app getCustomerProfile];
    self.categories  = self.customer.categories;
	
	[self updateUserAvatar];
    
    [self.leftSidebarTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
		return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return NO;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
	if(![navController.topViewController isKindOfClass:[FeedViewController class]] &&
		!([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]] && ((PhactsArchiveViewController *)navController.topViewController).mode == 0) &&
	    ![navController.topViewController isKindOfClass:[ProfileViewController class]])
		return;
	
	CGFloat leftSidebarWidth = self.leftSidebarView.bounds.size.width;
	
	CGPoint translation = [gestureRecognizer translationInView:self.contentView];
	CGFloat offset =  translation.x;// + (translation.x > 0 ? kPanMinimumDistance : -kPanMinimumDistance);
	if (self.leftSidebarOpen) {
		offset = MIN(leftSidebarWidth, MAX(0.0, leftSidebarWidth + offset));
	} else {
		offset = MIN(leftSidebarWidth, MAX(0, offset));
	}
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			[self.view endEditing:YES];
		case UIGestureRecognizerStateChanged:
			self.contentViewLeadingSpaceConstraint.constant = offset;
			self.dimView.alpha = (offset > 0) ? (offset / leftSidebarWidth) : 0.0;

			if([self.selectedPhactIds count] > 0) {
				UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
				if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
					for(int i = 0; i < [self.view subviews].count; i++) {
						UIView *subview = [[self.view subviews] objectAtIndex:i];
						if(subview.tag == 1000) {
							subview.tag = 0;
							subview.userInteractionEnabled = YES;
							[subview removeFromSuperview];
						}
					}
					
					[((FeedViewController *)navController.topViewController).tableView reloadData];
					[self.selectedPhactIds removeAllObjects];
				}
                else if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
                    [self.selectedPhactIds removeAllObjects];
                    [((PhactsArchiveViewController *)navController.topViewController).collectionView reloadData];
                }
			}
			break;
		case UIGestureRecognizerStateEnded: {
			CGPoint velocity = [gestureRecognizer velocityInView:self.contentView];
			if (velocity.x > 100) {
				if (!self.leftSidebarOpen) {
					[self showLeftSidebarAnimated:YES];
				}
				else {
					if (offset > leftSidebarWidth / 2.0) {
						[self showLeftSidebarAnimated:YES];
					} else {
						[self hideSidebarAnimated:YES];
					}
				}
			} else if (velocity.x < -100) {
				if (self.leftSidebarOpen) {
					[self hideSidebarAnimated:YES];
				}
				else {
					if (offset > leftSidebarWidth / 2.0) {
						[self showLeftSidebarAnimated:YES];
					} else {
						[self hideSidebarAnimated:YES];
					}
				}
			} else {
				if (offset > leftSidebarWidth / 2.0) {
					[self showLeftSidebarAnimated:YES];
				} else {
					[self hideSidebarAnimated:YES];
				}
			}
			break;
		}
		default:
			break;
	}
}

- (BOOL)dimView:(DimView *)view pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (self.menuButton.superview) {
		CGPoint pointInMenuButton = [view convertPoint:point toView:self.menuButton];
		return !CGRectContainsPoint(self.menuButton.bounds, pointInMenuButton);
	}
	return YES;
}

- (void)menuButtonPressed:(id)sender {
    [self.view endEditing:YES];
	if (self.leftSidebarOpen) {
		[self hideSidebarAnimated:YES];
	} else {
		[self showLeftSidebarAnimated:YES];
	}
	[self.selectedPhactIds removeAllObjects];
}

- (void)showLeftSidebarAnimated:(BOOL)animated {
	void (^showBlock)(void) = ^(void) {
		self.contentViewLeadingSpaceConstraint.constant = self.leftSidebarView.bounds.size.width;
		self.dimView.alpha = 1.0;
		[self.view layoutIfNeeded];
	};
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			showBlock();
		}];
	} else {
		showBlock();
	}
	self.leftSidebarOpen = YES;

	if([self.selectedPhactIds count] == 0) {
		self.phlowButton.titleLabel.text = @"Phlow";
		self.phlowButton.userInteractionEnabled = YES;
		
		UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
		if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
			[((FeedViewController *)navController.topViewController).tableView reloadData];
		}
        if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
			[((PhactsArchiveViewController *)navController.topViewController).collectionView reloadData];
		}
		
		self.accountProfileButton.hidden = NO;
		self.phlowButton.hidden = NO;
		self.archiveButton.hidden = NO;
		self.separator.hidden = NO;
		self.separator1.hidden = NO;
		self.separator2.hidden = NO;
		self.tableViewTopConstraint.constant = 0.0;
	}
	else {
		self.phlowButton.titleLabel.text = @"Phlow";
		self.phlowButton.userInteractionEnabled = YES;

		self.accountProfileButton.hidden = YES;
		self.phlowButton.hidden = YES;
		self.archiveButton.hidden = YES;
		self.separator.hidden = YES;
		self.separator1.hidden = YES;
		self.separator2.hidden = YES;
		self.tableViewTopConstraint.constant = -self.separator2.frame.origin.y;
	}
	[self.leftSidebarTableView reloadData];
}

- (void)hideSidebarAnimated:(BOOL)animated {
	void (^showBlock)(void) = ^(void) {
		self.contentViewLeadingSpaceConstraint.constant = 0.0;
		self.dimView.alpha = 0.0;
		[self.view layoutIfNeeded];
	};
	if (animated) {
		[UIView animateWithDuration:0.25 animations:^{
			showBlock();
		}];
	} else {
		showBlock();
	}
	self.leftSidebarOpen = NO;
	
	if([self.selectedPhactIds count] > 0) {
		UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
		if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
			for(int i = 0; i < [self.view subviews].count; i++) {
				UIView *subview = [[self.view subviews] objectAtIndex:i];
				if(subview.tag == 1000) {
					subview.tag = 0;
					subview.userInteractionEnabled = YES;
					[subview removeFromSuperview];
				}
			}
			[((FeedViewController *)navController.topViewController).tableView reloadData];
		}
        else if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
            [((PhactsArchiveViewController *)navController.topViewController).collectionView reloadData];
            UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
            menuButtonItem.width = 0;
            
            [((PhactsArchiveViewController *)navController.topViewController).navigationItem setLeftBarButtonItem:menuButtonItem];
        }
	}
    else
    {
        UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
		UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.menuButton];
		menuButtonItem.width = 0;
		
        if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
            [((PhactsArchiveViewController *)navController.topViewController).navigationItem setLeftBarButtonItem:menuButtonItem];
        }
        if([navController.topViewController isKindOfClass:[ProfileViewController class]]) {
            [((ProfileViewController *)navController.topViewController).navigationItem setLeftBarButtonItem:menuButtonItem];
        }
        if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
            [((FeedViewController *)navController.topViewController).navigationItem setLeftBarButtonItem:menuButtonItem];
        }
    }

	[self.selectedPhactIds removeAllObjects];
}

+ (FeedsTabBarController *)findFromViewController:(UIViewController *)viewController {
	UIViewController *parentViewController = viewController.parentViewController;
	while (parentViewController) {
		if ([parentViewController isKindOfClass:[FeedsTabBarController class]]) {
			return (FeedsTabBarController *)parentViewController;
		}
		parentViewController = parentViewController.parentViewController;
	}
	return nil;
}

- (IBAction)showAccountProfile:(id)sender {
	self.selectedIndex = 2;

    UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
    if([navController.topViewController isKindOfClass:[ProfileViewController class]]) {
        ProfileViewController *profileViewController = (ProfileViewController *)navController.topViewController;
		profileViewController.customer = self.customer;
	}
    
	[self hideSidebarAnimated:YES];
}

- (IBAction)showPhlow:(id)sender {
	self.selectedIndex = 0;
	
    UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
    if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
        FeedViewController *feedViewController = (FeedViewController *)navController.topViewController;
        
        [feedViewController loadFeedsByCategory:0];
    }

	[self hideSidebarAnimated:YES];
}

- (IBAction)showArchive:(id)sender {
	
    self.selectedIndex = 1;
    
    UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
    if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
        PhactsArchiveViewController *archiveViewController = (PhactsArchiveViewController *)navController.topViewController;
        [archiveViewController loadPhactsByCategory:0 categoryName:((UIButton *)sender).titleLabel.text];
    }
    
	[self hideSidebarAnimated:YES];
}

- (IBAction)createCategory:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create New Label" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 100;
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.font = [UIFont systemFontOfSize:16.0];
	textField.placeholder = @"Label Name";
	textField.keyboardType = UIKeyboardTypeDefault;
	[alert show];
	
	self.createCategoryAction = YES;	
	self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification* notification){
		if(self.createCategoryAction) {
			[alert dismissWithClickedButtonIndex:0 animated:NO];
			self.createCategoryAction = NO;
			
			[[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver name:UIApplicationDidBecomeActiveNotification object:nil];
		}
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100) {
		if (buttonIndex == 1) {
            NSString *name = [alertView textFieldAtIndex:0].text;
			
			if(![name isEqualToString:@""]) {
				[PhactCategory createCategory:name onCompletion:^(id methodResults, NSError *error){
					if(!error)
					{
						PhactCategory *category = methodResults;
						[self.categories.categoriesArray addObject:category];
						[self.leftSidebarTableView reloadData];
						[self.leftSidebarTableView scrollRectToVisible:CGRectMake(0, self.leftSidebarTableView.contentSize.height - self.leftSidebarTableView.bounds.size.height, self.leftSidebarTableView.bounds.size.width, self.leftSidebarTableView.bounds.size.height) animated:YES];
						
						[self updateCustomerProfile];
					}
					else {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
																		message: [error localizedDescription]
																	   delegate: self
															  cancelButtonTitle: @"OK"
															  otherButtonTitles: nil, nil];
						[alert show];
					}
				}];
			}
		}
		self.createCategoryAction = NO;
		[[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver name:UIApplicationDidBecomeActiveNotification object:nil];
	}
}

-(void) deleteCategory:(NSInteger) categoryId
{
    [PhactCategory deleteCategory:categoryId onCompletion:^(id methodResults, NSError *error){
        if(!error)
        {
            NSArray* results = [self.categories.categoriesArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.categoryId = %d", categoryId]];
            [self.categories.categoriesArray removeObject:[results objectAtIndex:0]];
            [self.leftSidebarTableView reloadData];
            
            [self updateCustomerProfile];
            
            UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
            if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
                PhactsArchiveViewController *archiveViewController = (PhactsArchiveViewController *)navController.topViewController;
                [archiveViewController loadPhactsByCategory:0 categoryName:@"Archive"];
            }
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                            message: [error localizedDescription]
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil, nil];
            [alert show];
        }
    }];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.categories.categoriesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellId = @"Cell";
		
	UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_arrow.png"]];

    PopListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
        cell = [[PopListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];

	if([self.selectedPhactIds count] > 0)
		cell.accessoryView = nil;
	else
		cell.accessoryView = accessoryView;
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;

    PhactCategory *category = [self.categories.categoriesArray objectAtIndex:indexPath.row];
	cell.icon.backgroundColor = [UIColor colorWithHexString:category.color];
	cell.label.text = category.name;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    PhactCategory *category = [self.categories.categoriesArray objectAtIndex:indexPath.row];
    NSInteger categoryId = category.categoryId;
	
    if([self.selectedPhactIds count] > 0) {
        [[PhactPrivateService sharedInstance] addPhactToCategory:self.selectedPhactIds categoryId:categoryId onCompletion:^(id methodResults, NSError *error) {
            if(!error)
            {                
                UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
                if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
                    PhactsArchiveViewController *archiveViewController = (PhactsArchiveViewController *)navController.topViewController;
                    archiveViewController.mode = 0;

                    [archiveViewController loadPhactsByCategory:categoryId categoryName:category.name];
                }
                
				[self hideSidebarAnimated:YES];
            }
            else {
				cell.accessoryType = UITableViewCellAccessoryNone;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                message: [error localizedDescription]
                                                               delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil, nil];
                [alert show];
            }
        }];
	}
	else {
		
        self.selectedIndex = 1;
        
        UINavigationController *navController = [self.viewControllers objectAtIndex:self.selectedIndex];
		if([navController.topViewController isKindOfClass:[PhactsArchiveViewController class]]) {
            PhactsArchiveViewController *archiveViewController = (PhactsArchiveViewController *)navController.topViewController;
			archiveViewController.mode = 0;
            
            [archiveViewController loadPhactsByCategory:categoryId categoryName:category.name];
		}

		[self hideSidebarAnimated:YES];
 	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        PhactCategory *category = [self.categories.categoriesArray objectAtIndex:indexPath.row];
        NSInteger categoryId = category.categoryId;

        [self deleteCategory:categoryId];
    }
}

-(void) updateCustomerProfile
{
    if(self.categories.categoriesArray)
    {
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.customer.categories];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:encodedObject forKey:@"Categories"];
        [defaults synchronize];
    }

    PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
    [app setCustomerProfile:self.customer];
}

- (UIImage *)maskedProfileImageWithImage:(UIImage *)inputImage {
	UIImage *maskImage = [UIImage imageNamed:@"profile-mask-small.png"];
	UIImage *overlayImage = [UIImage imageNamed:@"profile-overlay-small.png"];
	UIImage *resultImage = [UIImage imageWithSize:maskImage.size color:[UIColor colorWithWhite:(146.0 / 255.0) alpha:1.0]];
	resultImage = [resultImage duplicateImageWithOverlayImage:[inputImage duplicateImageWithSize:maskImage.size]];
	resultImage = [resultImage maskWithImage:maskImage];
	resultImage = [resultImage duplicateImageWithOverlayImage:overlayImage];
	return resultImage;
}

- (void)updateUserAvatar {
	UIImage *defaultAvatar = [UIImage imageNamed:@"default-profile-small.png"];
	[self.accountProfileButton setImage:[self maskedProfileImageWithImage:defaultAvatar] forState:UIControlStateNormal];
	if ([self.customer.customerAvatarURL length] > 0) {
		[[AsyncImageCache mainCache] retrieveImageWithURL:self.customer.customerAvatarURL callback:^(UIImage *result, NSError *error, BOOL cached) {
			UIImage *avatar = nil;
			if ([result isKindOfClass:[UIImage class]]) {
				avatar = result;
			} else {
				avatar = defaultAvatar;
			}
			[self.accountProfileButton setImage:[self maskedProfileImageWithImage:avatar] forState:UIControlStateNormal];
		}];
	}
}

@end
