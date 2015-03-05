//
//  ProfileViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ProfileViewController.h"

#import "ProfileViewController.h"
//#import <QuartzCore/QuartzCore.h>
#import "CustomTextField.h"
#import "Customer.h"
#import "StringUtils.h"
#import "UIView+Animation.h"
#import "AsyncImageCache.h"
#import "UIImage+Additions.h"
#import "NSData+Base64.h"
#import "PhactAppDelegate.h"
#import "Philters.h"
#import "SettingsViewController.h"
#import "PhilterSettingsViewController.h"
#import "UIViewController+Animation.h"
#import "ChangePasswordViewController.h"
#import "FeedsTabBarController.h"
#import "OverlayViewController.h"
#import "FriendsViewController.h"
#import "PhactsArchiveViewController.h"
#import "Contacts.h"
#import "ImageUtils.h"

#define KEYBOARD_HEIGHT		216
#define SECTION_COUNT		2
#define ITEM_HEIGHT             41

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet CustomTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *savedView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UIView *phactsView;
@property (weak, nonatomic) IBOutlet UILabel *phactsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendsCountLabel;

@property(nonatomic, strong) NSMutableArray *sections;
@property(nonatomic, copy) NSString *firstName;
@property(nonatomic, copy) NSString *lastName;

- (void)addCustomerObservers:(Customer *)customer;
- (void)removeCustomerObservers:(Customer *)customer;

- (void)updateAvatarImage;
- (UIImage *)maskedProfileImageWithImage:(UIImage *)inputImage;

- (IBAction)avatarButtonPressed:(id)sender;

- (void)fillFormData;

- (NSString *)avatarURL;

@end

@implementation ProfileViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.sections = [[NSMutableArray alloc] initWithCapacity:SECTION_COUNT];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.title = @"PROFILE";
	
    self.view.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		self.contentViewTopConstraint.constant = 63.0;
	}

	[self configureFonts];

    self.savedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup-check.png"]];
    self.savedView.layer.borderColor = [UIColor clearColor].CGColor;
    self.savedView.layer.borderWidth = 1.0f;
    self.savedView.layer.cornerRadius = 10.0;
    self.savedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.savedView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.savedView.layer.shadowOpacity = 0.5;
    self.savedView.hidden = YES;
	
	[self fillFormData];
	
	[self.sections addObject: [NSArray arrayWithObjects:@"Change Password", nil]];
    [self.sections addObject:[NSArray arrayWithObjects:@"Sign Out", nil]];
	
    self.tableView.backgroundView = nil;
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor whiteColor]/*[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0]*/;
    
    self.tableView.separatorColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[PhactPrivateService sharedInstance] getProfileNumbers:^(id result, NSError *error) {
		if (!error) {
			if([result isKindOfClass:[NSDictionary class]])
			{
				NSDictionary *resDict = (NSDictionary *)result;
				NSDictionary *data = [resDict objectForKey:@"data"];
				self.phactsCountLabel.text = [data objectForKey:@"phacts"];
				self.friendsCountLabel.text = [data objectForKey:@"friends"];
			}
		}
	}];
	
	self.savedView.hidden = YES;

	UIImage *cameraButtonImage = [UIImage imageNamed:@"icon_camera_feed"];
	UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
	cameraButton.bounds = CGRectMake(0, 0, 40, 44);
	[cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
	cameraButtonItem.width = 0;
	self.navigationItem.rightBarButtonItem = cameraButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
	if (feedsTabBarController) {
		UIButton *menuButton = feedsTabBarController.menuButton;
		UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
		menuButtonItem.width = 0;
		self.navigationItem.leftBarButtonItem = menuButtonItem;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.navigationItem.rightBarButtonItem = nil;
}

- (void)setCustomer:(Customer *)customer {
    if (_customer) {
		[self removeCustomerObservers:_customer];
	}
	_customer = customer;
	if (_customer) {
		[self addCustomerObservers:_customer];
    }
}

- (void)addCustomerObservers:(Customer *)customer {
	[_customer addObserver:self forKeyPath:@"firstName" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
	[_customer addObserver:self forKeyPath:@"lastName" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
	[_customer addObserver:self forKeyPath:@"email" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
	[_customer addObserver:self forKeyPath:@"customerAvatarURL" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)removeCustomerObservers:(Customer *)customer {
	[_customer removeObserver:self forKeyPath:@"firstName"];
	[_customer removeObserver:self forKeyPath:@"lastName"];
	[_customer removeObserver:self forKeyPath:@"email"];
	[_customer removeObserver:self forKeyPath:@"customerAvatarURL"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.customer) {
		id newValue = [change objectForKey:NSKeyValueChangeNewKey];
		if ([keyPath isEqualToString:@"firstName"]) {
			self.firstNameTextField.text = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
			self.firstName = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
			self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
		} else if ([keyPath isEqualToString:@"lastName"]) {
			self.lastNameTextField.text = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
			self.lastName = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
			self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.firstName,self.lastName];
		} else if ([keyPath isEqualToString:@"email"]) {
			self.emailTextField.text = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
			self.emailLabel.text = [StringUtils safeStringOrEmptyIfNilWithString:newValue];
		} else if ([keyPath isEqualToString:@"customerAvatarURL"]) {
			if (self.avatarButton) {
				[self updateAvatarImage];
			}
		}
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"PhiltersSegue"]) {
		((PhilterSettingsViewController *)segue.destinationViewController).customer = self.customer;
	}
	if ([[segue identifier] isEqualToString:@"PhilesSegue"]) {
	}
}

- (void)dealloc {
	if (_customer) {
		[self removeCustomerObservers:_customer];
	}
}

- (void)updateAvatarImage {
	UIImage *defaultAvatar = [UIImage imageNamed:@"default-profile.png"];
	[self.avatarButton setImage:[self maskedProfileImageWithImage:defaultAvatar] forState:UIControlStateNormal];
	if ([self.customer.customerAvatarURL length] > 0) {
		[[AsyncImageCache mainCache] retrieveImageWithURL:self.customer.customerAvatarURL callback:^(UIImage *result, NSError *error, BOOL cached) {
			UIImage *avatar = nil;
			if ([result isKindOfClass:[UIImage class]]) {
				avatar = result;
			} else {
				avatar = defaultAvatar;
			}
			[self.avatarButton setImage:[self maskedProfileImageWithImage:avatar] forState:UIControlStateNormal];
		}];
	}
}

- (UIImage *)maskedProfileImageWithImage:(UIImage *)inputImage {
	UIImage *maskImage = [UIImage imageNamed:@"profile-mask-big.png"];
	UIImage *overlayImage = [UIImage imageNamed:@"profile-overlay-big.png"];
	UIImage *resultImage = [UIImage imageWithSize:maskImage.size color:[UIColor colorWithWhite:(146.0 / 255.0) alpha:1.0]];
	resultImage = [resultImage duplicateImageWithOverlayImage:[inputImage duplicateImageWithSize:maskImage.size]];
	resultImage = [resultImage maskWithImage:maskImage];
	resultImage = [resultImage duplicateImageWithOverlayImage:overlayImage];
	return resultImage;
}

- (void)fillFormData {
	self.firstNameTextField.text = self.customer.firstName;
	self.lastNameTextField.text = self.customer.lastName;
	self.emailTextField.text = self.customer.email;
	self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.customer.firstName,self.customer.lastName];
	self.emailLabel.text = self.customer.email;
	[self updateAvatarImage];
}

- (void)configureFonts
{
	self.firstNameTextField.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
	self.lastNameTextField.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
	self.emailTextField.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)avatarButtonPressed:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose From Library", nil];
	[actionSheet showInView:[UIApplication sharedApplication].keyWindow/*self.view*/];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		actionSheet.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - actionSheet.frame.size.height, [UIScreen mainScreen].bounds.size.width, actionSheet.frame.size.height);
	}
}

- (void)changePasswordButtonPressed {
	ChangePasswordViewController *changePasswordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
	changePasswordViewController.customer = self.customer;
	changePasswordViewController.isResettingPassword = NO;
    [self.navigationController pushViewController:changePasswordViewController animated:YES];
}

- (void)cameraButtonPressed:(id)sender {
    PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
    OverlayViewController *overlayViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OverlayViewController"];
    
	FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
    [feedsTabBarController.view pushView:overlayViewController.view duration:0.4 completion:^(){
        app.window.rootViewController = overlayViewController;
        app.rootViewController = overlayViewController;
    }];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
		{
			[self takeImageFromCamera];
		}
			break;
		case 1:
		{
			[self addImageFromAlbum];
		}
			break;
			
		default:
			break;
	}
}

- (void)takeImageFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
    {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		
		imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		imagePicker.delegate = self;
		imagePicker.allowsEditing = YES;
		[self presentViewController:imagePicker animated:YES completion:nil];
	}
    else
    {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle: @"Camera unavailable"
                                                               message: @"Sorry, the camera is not available."
                                                              delegate: nil
                                                     cancelButtonTitle: @"OK"
                                                     otherButtonTitles: nil, nil];
		[warningAlert show];
    }
}

- (void)addImageFromAlbum
{
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	picker.delegate = self;
	picker.allowsEditing = YES;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *itemImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (itemImage != NULL)
    {
		UIImage *normalizedImage = [ImageUtils normalizedImage:itemImage];
		UIImage *resizedImage = [ImageUtils imageWithImage:normalizedImage scaledToSize:CGSizeMake(80.0, 80.0) quality:kCGInterpolationHigh];
		
		[[AsyncImageCache mainCache] removeImageForURL:[self avatarURL]];
		NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
        
        [[PhactPrivateService sharedInstance] uploadAvatar:[imageData base64EncodedString]  onCompletion:^(id result, NSError *error) {
            if (!error) {
                if (result && [result isKindOfClass:[NSDictionary class]])
                {
                    NSString *imageUrl = [result objectForKey:@"url"];
					self.customer.customerAvatarURL = imageUrl;
					[self updateAvatarImage];
					[self.avatarButton setImage:[self maskedProfileImageWithImage:itemImage] forState:UIControlStateNormal];
					
					FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
					[feedsTabBarController updateUserAvatar];
					[[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:kuserAvatarUrl];
					[[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            else
            {
				NSLog(@"uploadAvatar : Error : %@",[error localizedDescription]);
            }
        }];
    }
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)avatarURL {
	return self.customer.customerAvatarURL;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		if(viewController.title == nil && ( ((UIImagePickerController *)self.presentedViewController).sourceType != UIImagePickerControllerSourceTypeCamera)) {
			app.window.clipsToBounds = YES;
			app.window.frame =  CGRectMake(0,20,app.window.frame.size.width,app.window.frame.size.height-20);
			app.window.bounds = CGRectMake(0, 20, app.window.frame.size.width, app.window.frame.size.height);
		}
		if(viewController.title == nil && ( ((UIImagePickerController *)self.presentedViewController).sourceType == UIImagePickerControllerSourceTypeCamera)) {
			self.presentedViewController.view.clipsToBounds = YES;
			self.presentedViewController.view.frame =  CGRectMake(0,20,self.presentedViewController.view.frame.size.width,self.presentedViewController.view.frame.size.height-20);
		}
	}
	else {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	}
}

- (void)logout {
	
	[Customer logout:^(id result, NSError *error) {
		if (!error) {
#if DEBUG_MODE
			NSLog(@"result = %@",result);
#endif
		}
		else
		{
			NSLog(@"Logout Error: %@", [error description]);
		}
	}];
	
	[[PhactPrivateService sharedInstance] resetAuthenticationState];
	[[PhactService sharedInstance] resetAuthenticationState];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kuserLogin];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kuserPasswd];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kuserFirstname];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kuserLastname];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kuserAvatarUrl];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TopPhilters"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MorePhilters"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Categories"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self.customer.philters.activePhilters removeAllObjects];
	[self.customer.philters.inActivePhilters removeAllObjects];
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	
	Contacts *contacts = [Contacts sharedInstance];
	contacts.bSendContacts = NO;
	[contacts unRegisterAddressBookChange];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kfacebookFriendAccess];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:ktwitterFriendAccess];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kaddressBookAccess];
    
	PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
	[app loginCustomer];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [[self.sections objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ITEM_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];

    NSMutableArray *data = [self.sections objectAtIndex:indexPath.section];
    NSString *title = [data objectAtIndex:indexPath.item];
	
    cell.textLabel.text = title;
    
    cell.textLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:16.0];
    
    if (indexPath.section == 0)
    {
        cell.textLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.textLabel.textColor = [UIColor colorWithRed:213.0/255.0 green:9.0/255.0 blue:18.0/255.0 alpha:1.0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if((indexPath.section == 0) && (indexPath.row == 0))
        [self changePasswordButtonPressed];
    else if((indexPath.section == 1) &&  (indexPath.row == 0))
        [self logout];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self.friendsView)
    {
		FriendsViewController *friendsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
		friendsViewController.mode = FindMode_View;
		friendsViewController.layoutType = 0;
		[self.navigationController pushViewController:friendsViewController animated:YES];
    }
	else if ([touch view] == self.phactsView) {
		if(![self.phactsCountLabel.text isEqualToString:@"0"]) {
			PhactsArchiveViewController *phactsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhactsArchiveViewController"];
			phactsViewController.mode = 1;
			[self.navigationController pushViewController:phactsViewController animated:YES];
			[phactsViewController loadOwnPhacts];
		}
	}
}

@end
