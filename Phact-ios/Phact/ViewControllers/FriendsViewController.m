//
//  FriendsViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/14/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "FriendsViewController.h"
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import "Friends.h"
#import "FriendCell.h"
#import "PhactPrivateService.h"
#import "AsyncImageCache.h"
#import "PhactAppDelegate.h"
#import "CustomSegmentedControl.h"
#import "Customer.h"
#import "OpenProviderManager.h"
#import "OpenProviderConnector.h"
#import "FacebookConnector.h"
#import "TwitterConnector.h"
#import <AddressBook/AddressBook.h>
#import "ErrorManager.h"
#import "Contacts.h"
#import "OverlayViewController.h"
#import "FeedsTabBarController.h"
#import "UIView+Animation.h"
#import "Contact.h"

#define ITEM_HEIGHT             44
#define kAvatarTag				10000
#define kNameTag				20000
#define kCheckTag				5000

@interface FriendsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;
@property (weak, nonatomic) IBOutlet UIView *friendTypeSelectionView;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *bottomToolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *contactsSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet CustomSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *sendAlertView;
@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *contactsSwitch;
@property (weak, nonatomic) IBOutlet UIButton *findButton;

@property (strong, nonatomic) Friends *friends;
@property (strong, nonatomic) NSMutableArray *contacts;

@property (strong, nonatomic) NSArray *friendsSearchedData;
@property (strong, nonatomic) NSArray *contactsSearchedData;
@property (nonatomic) BOOL sentRequest;
@property (nonatomic) BOOL isFriendsFiltered;
@property (nonatomic) BOOL isContactsFiltered;

@property (nonatomic) BOOL allFriendsSelected;
@property (nonatomic) BOOL allContactsSelected;
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;

- (IBAction)facebookSharePressed:(id)sender;
- (IBAction)twitterSharePressed:(id)sender;
- (IBAction)emailSharePressed:(id)sender;
- (IBAction)toggleSwitch:(id)sender;
- (IBAction)findButtonPressed:(id)sender;

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
		_contacts = [[NSMutableArray alloc] init];
	}
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.tableView.backgroundView = nil;
//    self.tableView.backgroundView = [[UIView alloc] init];
//    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
	self.contactsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contactsTableView.separatorColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    self.friendsSearchedData = [NSArray array];
    self.contactsSearchedData = [NSArray array];
	
	[self.contactsTableView setAllowsMultipleSelection:YES];

    [self setupSegmentedControl];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.searchBar.barTintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]; //[UIColor whiteColor];
        self.contactsSearchBar.barTintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    }
    else {
        self.searchBar.tintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]; //[UIColor whiteColor];
        self.contactsSearchBar.tintColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
	}

	self.shareView.hidden = YES;
	if(self.mode == FindMode_View) {
		self.tableView.hidden = NO;
		self.contactsTableView.hidden = YES;
		if(self.layoutType == 1)
			self.bottomToolbar.hidden = NO;
		else
			self.bottomToolbar.hidden = YES;

		self.friendTypeSelectionView.hidden = YES;
	}
	else {
		self.tableView.hidden = YES;
		self.contactsTableView.hidden = YES;
		self.bottomToolbar.hidden = YES;
		self.friendTypeSelectionView.hidden = NO;
	}

	self.facebookSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:kfacebookFriendAccess] boolValue];
	self.twitterSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:ktwitterFriendAccess] boolValue];
	self.contactsSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:kaddressBookAccess] boolValue];

	if(self.facebookSwitch.on || self.twitterSwitch.on || self.contactsSwitch.on)
		self.findButton.enabled = YES;
	else
		self.findButton.enabled = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		self.topConstraint.constant -= 64.0;
	}
    
    self.sendAlertView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup-check.png"]];
    self.sendAlertView.layer.borderColor = [UIColor clearColor].CGColor;
    self.sendAlertView.layer.borderWidth = 1.0f;
    self.sendAlertView.layer.cornerRadius = 10.0;
    self.sendAlertView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.sendAlertView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.sendAlertView.layer.shadowOpacity = 0.5;
    self.sendAlertView.hidden = YES;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
    self.sendAlertView.hidden = YES;
	
	UIImage *closeButtonImage = [UIImage imageNamed:@"icon_back"];
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[closeButton setImage:closeButtonImage forState:UIControlStateNormal];
	closeButton.bounds = CGRectMake(0, 0, 40, 44);
	[closeButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
	closeButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = closeButtonItem;
    
    self.navigationItem.title = @"FRIENDS";
    
	if(self.mode == FindMode_Selection)
		return;

	[self getContactList];
	
    if(!self.sentRequest)
    {
        if (self.loadingIndicator.hidden)
        {
            self.transparentView.hidden = NO;
            [self.loadingIndicator startAnimating];
        }

        [Friends getFriends:^(id result, NSError *error) {
            [self.loadingIndicator stopAnimating];
            self.transparentView.hidden = YES;
            self.sentRequest = YES;
            
            if (!error) {
                
                Friends *friends = (Friends *)result;
                if(friends)
                {
                    if(friends.friendsList)
                    {
                        self.friends = friends;
                        [self.tableView reloadData];
                    }
                }
            }
            else
            {
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

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.navigationItem.leftBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)closeButtonPressed:(id)sender {
    
}

- (void)backButtonPressed:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toggleSwitch:(id)sender {
	
	if(self.facebookSwitch.on || self.twitterSwitch.on || self.contactsSwitch.on)
		self.findButton.enabled = YES;
	else
		self.findButton.enabled = NO;
}

- (void)getContactList {
	[self.contacts removeAllObjects];
	CFErrorRef error = NULL;
	ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
	ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (error || !granted)
			{
				// handle error
				NSLog(@"ERROR: %@",error);
				
				if(!granted) {
					// show alert (get access to contact list)
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Phact does not have access to your contacts"
																	message: @"To enable access go to: Settings > Privacy > Contacts > Phact set to 'On'"
																   delegate: self
														  cancelButtonTitle: @"OK"
														  otherButtonTitles: nil, nil];
					[alert show];
				}
			}
			else
			{
				ABAddressBookRevert(addressBook);
				NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
				
				NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
				{
					ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
					
					CFStringRef firstNameRef = ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
					NSString *firstName = (__bridge NSString *)firstNameRef;
					CFStringRef lastNameRef = ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
					NSString *lastName = (__bridge NSString *)lastNameRef;
					CFDataRef imageDataRef = ABPersonCopyImageDataWithFormat(contactPerson, kABPersonImageFormatThumbnail);
					NSData *imageData = (__bridge NSData*)imageDataRef;
					
					ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
					
					if(ABMultiValueGetCount(emails) > 0) {
						NSMutableArray *emailList = [[NSMutableArray alloc] init];
						
//						NSLog(@"firstName = %@ lastName = %@", firstName, lastName);
						for (NSInteger j = 0; j < ABMultiValueGetCount(emails); j++) {
							NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
//							NSLog(@"person.email = %@ ", email);
							
							[emailList addObject:email];
						}
						UIImage *img = [UIImage imageWithData:imageData];
						if(firstName == nil)
							firstName = @"";
						if(lastName == nil)
							lastName = @"";
						
						Contact *contact = [[Contact alloc] initWithAvatar:img firstname:firstName lastname:lastName emails:emailList];
						[self.contacts addObject:contact];
					}
					if(emails)
						CFRelease(emails);
					if(firstNameRef)
						CFRelease(firstNameRef);
					if(lastNameRef)
						CFRelease(lastNameRef);
					if(imageDataRef)
						CFRelease(imageDataRef);
				}
				[self.contactsTableView reloadData];
//				NSLog(@"Contacts count = %d",self.contacts.count);
			}
		});
	});

}

- (void)sendContactList {
	
	BOOL addressBookAccess = [[[NSUserDefaults standardUserDefaults] objectForKey:kaddressBookAccess] boolValue];
	if(addressBookAccess) {
		[self getFriendsList];
		return;
	}
	
	[[Contacts sharedInstance] sendAddressBook:^(id result, NSError *error) {
		if (!error) {
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kaddressBookAccess];
			[[NSUserDefaults standardUserDefaults] synchronize];

			[self getFriendsList];
		}
		else
		{
			[self.loadingIndicator stopAnimating];
			self.transparentView.hidden = YES;
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
															message: [error localizedDescription]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			[alert show];
			
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kaddressBookAccess];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}];
	
}

- (void)getFriendsList {
	
	[[PhactPrivateService sharedInstance] findFriends:^(id methodResults, NSError *error) {
		if(!error){
			[Friends getFriends:^(id result, NSError *error) {
				[self.loadingIndicator stopAnimating];
				self.transparentView.hidden = YES;
				
				if (!error) {					
					Friends *friends = (Friends *)result;
					if(friends)
					{
						if(friends.friendsList)
						{
							self.searchBar.text = @"";
							self.isFriendsFiltered = NO;
							self.allFriendsSelected = NO;

							self.friends = friends;
							[self.tableView reloadData];
							
							self.mode = FindMode_View;
							self.tableView.hidden = NO;

							NSIndexSet *index = [self.segmentedControl selectedIndexes];
							if(self.layoutType == 1) {
								if(index.lastIndex == 0) {
									[self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
									[self.sendButton setTitle:@"Send" forState:UIControlStateHighlighted];
								}
								else {
									[self.sendButton setTitle:@"Invite" forState:UIControlStateNormal];
									[self.sendButton setTitle:@"Invite" forState:UIControlStateHighlighted];
								}

								self.bottomToolbar.hidden = NO;
							}
							else {
								if(index.lastIndex == 0) {
									self.bottomToolbar.hidden = YES;
								}
								else {
									self.bottomToolbar.hidden = NO;
								}
							}
							self.friendTypeSelectionView.hidden = YES;
						}
						
						if(self.facebookSwitch.on)
							[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kfacebookFriendAccess];
						if(self.twitterSwitch.on)
							[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:ktwitterFriendAccess];
						if(self.contactsSwitch.on)
							[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kaddressBookAccess];
					}
				}
				else
				{
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
			[self.loadingIndicator stopAnimating];
			self.transparentView.hidden = YES;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
															message: [error localizedDescription]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			[alert show];
		}
	}];
}

- (IBAction)findButtonPressed:(id)sender {
	PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
	RegisterType type = app.customer.regType;
	
	if (self.loadingIndicator.hidden) {
        self.transparentView.hidden = NO;
        [self.loadingIndicator startAnimating];
	}

	if(self.facebookSwitch.on) {
		if(type != RegisterType_Facebook)
		{
			[self signInWithOpenProviderConnector:[[OpenProviderManager instance] facebookConnector]  completion:^(BOOL finished){
				if(finished) {
					if(self.twitterSwitch.on) {
						if(type != RegisterType_Twitter)
						{
							[self signInWithOpenProviderConnector:[[OpenProviderManager instance] twitterConnector]  completion:^(BOOL finished){
								if(finished) {
									if(self.contactsSwitch.on) {
										[self sendContactList];
									}
									else {
										[self getFriendsList];
									}
								}
								else {
									NSLog(@"twitter connect error");
									[self.loadingIndicator stopAnimating];
									self.transparentView.hidden = YES;
								}
							}];
						}
						else
						{
							if(self.contactsSwitch.on) {
								[self sendContactList];
							}
							else {
								[self getFriendsList];
							}
						}
					}
					else {
						if(self.contactsSwitch.on) {
							[self sendContactList];
						}
						else {
							[self getFriendsList];
						}
					}
				}
				else {
					NSLog(@"facebook connect error");
					[self.loadingIndicator stopAnimating];
					self.transparentView.hidden = YES;
				}
			}];
		}
		else
		{
			if(self.twitterSwitch.on) {
				if(type != RegisterType_Twitter)
				{
					[self signInWithOpenProviderConnector:[[OpenProviderManager instance] twitterConnector] completion:^(BOOL finished){
						if(finished) {
							if(self.contactsSwitch.on) {
								[self sendContactList];
							}
							else {
								[self getFriendsList];
							}
						}
						else {
							NSLog(@"twitter connect error");
							[self.loadingIndicator stopAnimating];
							self.transparentView.hidden = YES;
						}
					}];
				}
				else
				{
					if(self.contactsSwitch.on) {
						[self sendContactList];
					}
					else {
						[self getFriendsList];
					}
				}
			}
			else {
				if(self.contactsSwitch.on) {
					[self sendContactList];
				}
				else {
					[self getFriendsList];
				}
			}
		}
	}
	else {
		if(self.twitterSwitch.on) {
			if(type != RegisterType_Twitter)
			{
				[self signInWithOpenProviderConnector:[[OpenProviderManager instance] twitterConnector]  completion:^(BOOL finished){
					if(finished) {
						if(self.contactsSwitch.on) {
							[self sendContactList];
						}
						else {
							[self getFriendsList];
						}
					}
					else {
						NSLog(@"twitter connect error");
						[self.loadingIndicator stopAnimating];
						self.transparentView.hidden = YES;
					}
				}];
			}
			else
			{
				if(self.contactsSwitch.on) {
					[self sendContactList];
				}
				else {
					[self getFriendsList];
				}
			}
		}
		else {
			if(self.contactsSwitch.on) {
				[self sendContactList];
			}
			else {
				[self getFriendsList];
			}
		}
	}
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if(tableView == self.tableView) {
		if(!self.layoutType)
			return 0;
		
		NSInteger count = self.isFriendsFiltered ? [self.friendsSearchedData count] : [self.friends.friendsList count];
		if(count == 0)
			return 0;
		
		return 30;
	}
		
	NSInteger count = self.isContactsFiltered ? [self.contactsSearchedData count] : [self.contacts count];
	if(count == 0)
		return 0;
		
	return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(tableView == self.tableView) {
		if(!self.sentRequest)
			return self.isFriendsFiltered ? self.friendsSearchedData.count: [self.friends.friendsList count];
		
		return self.isFriendsFiltered ? self.friendsSearchedData.count + 1 : [self.friends.friendsList count] + 1;
	}
	return self.isContactsFiltered ? self.contactsSearchedData.count: [self.contacts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == self.tableView) {
		return ITEM_HEIGHT;
	}
	
	Contact *contact = [self.contacts objectAtIndex:indexPath.row];
	if ([tableView indexPathsForSelectedRows].count) {
        
		if ([[tableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
			return contact.emails.count * 40.0 + 50.0; // Expanded height
		}
        return 50.0;
	}
	
    return 50.0; // Normal height
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"FriendCell";
    static NSString *FindCellIdentifier = @"FindCell";
    static NSString *ContactCellIdentifier = @"ContactCell";

	if(tableView == self.tableView) {
		NSInteger count = self.isFriendsFiltered ? [self.friendsSearchedData count] + 1 : [self.friends.friendsList count] + 1;
		if(indexPath.row == count - 1) {
			UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:FindCellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FindCellIdentifier];
			}
			cell.textLabel.text = @"Find Friends";
			cell.textLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:17.0];
			cell.textLabel.textColor = [UIColor redColor];
			
			cell.indentationLevel = 10;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			return cell;
		}
		
		FriendCell *cell = (FriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
		
		if (cell == nil) {
			cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		Friend *friend = self.isFriendsFiltered ? self.friendsSearchedData[indexPath.row] : [self.friends.friendsList objectAtIndex:indexPath.row];
		NSString *title = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName ];
		
		cell.nameLabel.text = title;
		cell.nameLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:15.0];
		cell.nameLabel.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
		
		cell.avatarImageView.layer.borderColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0].CGColor;
		cell.avatarImageView.layer.borderWidth = 1.0f;
		
		UIImage *image = (friend.checked) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
			if(indexPath.row % 2 == 0)
				cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
			else
				cell.backgroundColor = [UIColor whiteColor];
		}
		else {
			
			if(indexPath.row % 2 == 0)
				cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
			else
				cell.contentView.backgroundColor = [UIColor whiteColor];
		}
		if(self.layoutType == 1) {
/*
			UIView *accesoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, ITEM_HEIGHT-1, ITEM_HEIGHT-1)];
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			
			button.bounds = CGRectMake(0.0, 0.0, ITEM_HEIGHT-1, ITEM_HEIGHT-1);
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
				button.center = CGPointMake(accesoryView.center.x + 7.0,accesoryView.center.y);
			else
				button.center = CGPointMake(accesoryView.center.x - 8.0,accesoryView.center.y);
			
			[button setImage:image forState:UIControlStateNormal];
			[button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
			button.backgroundColor = [UIColor clearColor];
			if(indexPath.row % 2 == 0)
				accesoryView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
			else
				accesoryView.backgroundColor = [UIColor clearColor];
			
			[accesoryView addSubview:button];
			
			cell.accessoryView = accesoryView;
*/
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
///			button.frame = CGRectMake(261.0, 2.0, 55.0, 40.0);
			button.contentMode = UIViewContentModeRight;
			button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 256, 0.0, 0.0);
			button.frame = CGRectMake(0, 2.0, 320.0, 40.0);
			[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = 1111;
			button.adjustsImageWhenHighlighted = NO;
			button.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:button];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIButton *checkButton = (UIButton *)[cell.contentView viewWithTag:1111];
		[checkButton setImage:image forState:UIControlStateNormal];
		
		cell.avatarImageView.image = nil;
		if([friend.friendAvatarURL length] > 0)
		{
			[[AsyncImageCache mainCache] retrieveImageWithURL:friend.friendAvatarURL  callback:^(UIImage *result, NSError *error, BOOL cached) {
				if (!error && [result isKindOfClass:[UIImage class]]) {
					cell.avatarImageView.image = result;
				}
				else {
					cell.avatarImageView.image = nil;
				}
			}];
		}
		
		return cell;
	}
	else {
		Contact *contact = self.isContactsFiltered ? self.contactsSearchedData[indexPath.row] : [self.contacts objectAtIndex:indexPath.row];
		
		UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];

			cell.clipsToBounds = YES;
			
            float posX = 13.0;
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(posX, 7, 30, 30)];
			imageView.tag = kAvatarTag;
			imageView.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:imageView];
            
			posX = 55.0;			
			UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(posX, 7.0, 205.0, 30.0)];
			nameLabel.tag = kNameTag;
			nameLabel.backgroundColor = [UIColor clearColor];
			nameLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:15.0];
			nameLabel.textColor = [UIColor colorWithWhite:(51.0 / 255.0) alpha:1];
			nameLabel.highlightedTextColor = [UIColor whiteColor];
			nameLabel.textAlignment = NSTextAlignmentLeft;
			[cell.contentView addSubview:nameLabel];
			
			posX += 224.0;
			UIImageView *checkView = [[UIImageView alloc] initWithFrame:CGRectMake(posX, 15, 19, 19)];
			checkView.image = nil;
			checkView.contentMode = UIViewContentModeScaleAspectFit;
			checkView.tag = kCheckTag;
			checkView.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:checkView];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UIImageView *avatar = (UIImageView *)[cell.contentView viewWithTag:kAvatarTag];
		UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:kNameTag];
		UIImageView *checkMarkView = (UIImageView *)[cell.contentView viewWithTag:kCheckTag];
		if(contact.avatar)
			avatar.image = contact.avatar;
		else
			avatar.image = [UIImage imageNamed:@"default-profile.png"];

		nameLabel.text = [NSString stringWithFormat:@"%@ %@",contact.firstName,contact.lastName];

		checkMarkView.image = nil;
		for(Email *email in contact.emails) {
			if(email.checked) {
				checkMarkView.image = [UIImage imageNamed:@"check_grey.png"];
				break;
			}
		}
		if([tableView indexPathsForSelectedRows] != nil) {
			if ([[tableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
				if(checkMarkView.image == nil) {
					checkMarkView.image = [UIImage imageNamed:@"icon_minus.png"];
				}
			}
			else {
				if(checkMarkView.image == nil) {
					checkMarkView.image = [UIImage imageNamed:@"icon_plus.png"];
				}
			}
		}
		else {
			if(checkMarkView.image == nil) {
				checkMarkView.image = [UIImage imageNamed:@"icon_plus.png"];
			}
		}
		
		for(int i = 0; i < cell.contentView.subviews.count; i++) {
			UIView *subview = [cell.contentView.subviews objectAtIndex:i];
			if(subview.tag != kAvatarTag && subview.tag != kNameTag && subview.tag != kCheckTag) {
				[subview removeFromSuperview];
				i--;
			}
		}
		
		float posY = 50.0;
		for(int i = 0; i < contact.emails.count; i++) {
			Email *contactEmail = [contact.emails objectAtIndex:i];
			
			UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, posY, 215.0, 40.0)];
			emailLabel.backgroundColor = [UIColor clearColor];
			emailLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:15.0];
			emailLabel.textColor = [UIColor colorWithWhite:(51.0 / 255.0) alpha:1];
			emailLabel.highlightedTextColor = [UIColor whiteColor];
			emailLabel.textAlignment = NSTextAlignmentLeft;
			emailLabel.text = contactEmail.email;
			[cell.contentView addSubview:emailLabel];
			
			UIImage *image = (contactEmail.checked) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
			button.contentMode = UIViewContentModeRight;
			button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 256, 0.0, 0.0);
			button.frame = CGRectMake(0, posY, 320.0, 40.0);
///			button.frame = CGRectMake(261.0, posY, 55.0, 40.0);
			[button setImage:image forState:UIControlStateNormal];
			[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
			button.tag = i;
			button.adjustsImageWhenHighlighted = NO;
			button.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:button];
			
			posY += 40.0;
		}
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == self.tableView) {
		NSInteger count = self.isFriendsFiltered ? [self.friendsSearchedData count] + 1 : [self.friends.friendsList count] + 1;
		if(indexPath.row == count - 1) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			self.mode = FindMode_Selection;
			self.tableView.hidden = YES;
			self.contactsTableView.hidden = YES;
			self.bottomToolbar.hidden = YES;
			self.friendTypeSelectionView.hidden = NO;
			
			[self.searchBar endEditing:YES];
		}
	}
	else {
		Contact *contact = self.isContactsFiltered ? self.contactsSearchedData[indexPath.row] : [self.contacts objectAtIndex:indexPath.row];
		Email *email = [contact.emails objectAtIndex:0];
		email.checked = YES;
		

		UITableViewCell *cell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
		UIImageView *checkMarkView = (UIImageView *)[cell.contentView viewWithTag:kCheckTag];
		checkMarkView.image = [UIImage imageNamed:@"check_grey.png"];
				
		for(int i = 0; i < cell.contentView.subviews.count; i++) {
			UIView *subview = [cell.contentView.subviews objectAtIndex:i];
			
			if([subview isKindOfClass:[UIButton class]]) {
				[(UIButton *)subview setImage:[UIImage imageNamed:@"icon_checked.png"] forState:UIControlStateNormal];
				break;
			}
		}
		[tableView beginUpdates];
		[tableView endUpdates];
	}
}


- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(tableView == self.contactsTableView) {
		Contact *contact = self.isContactsFiltered ? self.contactsSearchedData[indexPath.row] : [self.contacts objectAtIndex:indexPath.row];
		UITableViewCell *cell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
		UIImageView *checkMarkView = (UIImageView *)[cell.contentView viewWithTag:kCheckTag];

		int i;
		for(i = 0; i < contact.emails.count; i++) {
			Email *email = [contact.emails objectAtIndex:i];
			if(email.checked) {
				checkMarkView.image = [UIImage imageNamed:@"check_grey.png"];
				break;
			}
		}
		if(i == contact.emails.count) {
			checkMarkView.image = [UIImage imageNamed:@"icon_plus.png"];
		}

		[tableView beginUpdates];
		[tableView endUpdates];
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
   
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,30)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20.0, 5.0, 150.0, 22.0);
    label.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:15.0];
    label.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"Select All "];
    [headerView addSubview:label];
    
    UIImage *image = (self.allFriendsSelected ) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
	if(tableView == self.contactsTableView)
		image = (self.allContactsSelected ) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
	
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(263.0, 0.0, 50.0, 30.0);
    button.frame = frame;
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectAllButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [headerView addSubview:button];

    return headerView;
}

- (void)selectAllButtonTapped:(id)sender event:(id)event
{
	NSIndexSet *index = [self.segmentedControl selectedIndexes];
    if(index.lastIndex == 0 ) {
		self.allFriendsSelected = !self.allFriendsSelected;
		
		for (Friend *friend in self.friends.friendsList) {
			
			friend.checked = self.allFriendsSelected;
		}
		[self.tableView reloadData];
	}
	else {
		self.allContactsSelected = !self.allContactsSelected;
		for (Contact *contact in self.contacts) {
			for(Email *email in contact.emails) {
				email.checked = self.allContactsSelected;
			}
		}
		
		NSArray *visibleCells = [self.contactsTableView visibleCells];
		for(UITableViewCell *cell in visibleCells) {
			NSIndexPath *indexPath = [self.contactsTableView indexPathForCell:cell];
			UIImageView *checkMarkView = (UIImageView *)[cell.contentView viewWithTag:kCheckTag];
			
			if(self.allContactsSelected) {
				checkMarkView.image = [UIImage imageNamed:@"check_grey.png"];
			}
			else {
				if ([[self.contactsTableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
					checkMarkView.image = [UIImage imageNamed:@"icon_minus.png"];
				}
				else {
					checkMarkView.image = [UIImage imageNamed:@"icon_plus.png"];
				}
			}
			
			for(int i = 0; i < cell.contentView.subviews.count; i++) {
				UIView *subview = [cell.contentView.subviews objectAtIndex:i];
				if([subview isKindOfClass:[UIButton class]]) {
					UIImage *image = (self.allContactsSelected ) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
					[(UIButton *)subview setImage:image forState:UIControlStateNormal];
				}
				
			}
		}
		
		UIImage *image = (self.allContactsSelected ) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
		[(UIButton *)sender setImage:image forState:UIControlStateNormal];
	}
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
	NSIndexSet *index = [self.segmentedControl selectedIndexes];
    if(index.lastIndex == 0 ) {
		CGPoint currentTouchPosition = [touch locationInView:self.tableView];
		NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
		
		if (indexPath != nil)
		{
			[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
		}
	}
	else {
		CGPoint currentTouchPosition = [touch locationInView:self.contactsTableView];
		NSIndexPath *indexPath = [self.contactsTableView indexPathForRowAtPoint: currentTouchPosition];
		
		if (indexPath != nil)
		{
			Contact *contact = self.isContactsFiltered ? self.contactsSearchedData[indexPath.row] : [self.contacts objectAtIndex:indexPath.row];
			
			NSInteger index = ((UIButton *)sender).tag;
			Email *email = [contact.emails objectAtIndex:index];
			if(email.checked)
				[contact setUncheckedEmailAtIndex:index];
			else
				[contact setCheckedEmailAtIndex:index];

			UITableViewCell *cell = [self.contactsTableView cellForRowAtIndexPath:indexPath];
			UIImageView *checkMarkView = (UIImageView *)[cell.contentView viewWithTag:kCheckTag];
			
			UIImage *image = (email.checked) ? [UIImage imageNamed:@"icon_checked.png"] : [UIImage imageNamed:@"icon_unchecked.png"];
			[((UIButton *)sender) setImage:image forState:UIControlStateNormal];
			
			checkMarkView.image = nil;
			for(Email *email in contact.emails) {
				if(email.checked) {
					checkMarkView.image = [UIImage imageNamed:@"check_grey.png"];
					break;
				}
			}
			if ([[self.contactsTableView indexPathsForSelectedRows] indexOfObject:indexPath] != NSNotFound) {
				if(checkMarkView.image == nil) {
					checkMarkView.image = [UIImage imageNamed:@"icon_minus.png"];
				}
			}
			else {
				if(checkMarkView.image == nil) {
					checkMarkView.image = [UIImage imageNamed:@"icon_plus.png"];
				}
			}
		}
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if(tableView == self.tableView) {
		Friend *friend = self.isFriendsFiltered ? self.friendsSearchedData[indexPath.row] : [self.friends.friendsList objectAtIndex:indexPath.row];
		friend.checked = !friend.checked;
		[self.tableView reloadData];
	}
}

- (void)setupSegmentedControl
{
//    UIImage *backgroundImage = [[UIImage imageNamed:@"segmented-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
//    [self.segmentedControl setBackgroundImage:backgroundImage];
    
//    [self.segmentedControl setSeparatorImage:[UIImage imageNamed:@"segmented-separator.png"]];
    
    
    [self.segmentedControl addTarget:self action:@selector(segmentedViewController:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControl setSegmentedControlMode:SegmentedControlModeSticky];
    [self.segmentedControl setSelectedIndex:0];

    
    UIImage *buttonBackgroundImagePressedLeft = [UIImage imageNamed:@"send_3tabs_active.png"];
    UIImage *buttonBackgroundImagePressedRight = [UIImage imageNamed:@"invite_3tabs_active.png"];
	if(!self.layoutType) {
		buttonBackgroundImagePressedLeft = [UIImage imageNamed:@"friends_2tab_active.png"];
		buttonBackgroundImagePressedRight = [UIImage imageNamed:@"invite_2tabs_active.png"];
	}

    UIImage *buttonBackgroundImagePressedMiddle = [UIImage imageNamed:@"share_3tabs_active.png"];

    
    // Button Send Friend
    UIButton *buttonSendFriend = [[UIButton alloc] init];
    [buttonSendFriend setBackgroundImage:[UIImage imageNamed:@"send_3tabs_inactive.png"] forState:UIControlStateNormal];
	if(!self.layoutType)
		[buttonSendFriend setBackgroundImage:[UIImage imageNamed:@"friends_2tab_inactive.png"] forState:UIControlStateNormal];
    
    [buttonSendFriend setBackgroundImage:buttonBackgroundImagePressedLeft forState:UIControlStateHighlighted];
    [buttonSendFriend setBackgroundImage:buttonBackgroundImagePressedLeft forState:UIControlStateSelected];
    [buttonSendFriend setBackgroundImage:buttonBackgroundImagePressedLeft forState:(UIControlStateHighlighted|UIControlStateSelected)];
    
    // Button Share
    UIButton *buttonShare = [[UIButton alloc] init];
    [buttonShare setBackgroundImage:[UIImage imageNamed:@"share_3tabs_inactive.png"] forState:UIControlStateNormal];

    [buttonShare setBackgroundImage:buttonBackgroundImagePressedMiddle forState:UIControlStateHighlighted];
    [buttonShare setBackgroundImage:buttonBackgroundImagePressedMiddle forState:UIControlStateSelected];
    [buttonShare setBackgroundImage:buttonBackgroundImagePressedMiddle forState:(UIControlStateHighlighted|UIControlStateSelected)];
 
	// Button Invite
    UIButton *buttonInvite = [[UIButton alloc] init];
    [buttonInvite setBackgroundImage:[UIImage imageNamed:@"invite_3tabs_inactive.png"] forState:UIControlStateNormal];
	if(!self.layoutType)
		[buttonInvite setBackgroundImage:[UIImage imageNamed:@"invite_2tabs_inactive.png"] forState:UIControlStateNormal];
	
    [buttonInvite setBackgroundImage:buttonBackgroundImagePressedRight forState:UIControlStateHighlighted];
    [buttonInvite setBackgroundImage:buttonBackgroundImagePressedRight forState:UIControlStateSelected];
    [buttonInvite setBackgroundImage:buttonBackgroundImagePressedRight forState:(UIControlStateHighlighted|UIControlStateSelected)];

	if(self.layoutType == 0)
		[self.segmentedControl setButtonsArray:@[buttonSendFriend, buttonInvite]];
	else
		[self.segmentedControl setButtonsArray:@[buttonSendFriend, buttonShare, buttonInvite]];
}

#pragma mark - CustomSegmentedControl callbacks

- (void)segmentedViewController:(id)sender
{
    CustomSegmentedControl *segmentedControl = (CustomSegmentedControl *)sender;
    
    NSIndexSet *index = [segmentedControl selectedIndexes];
    if(index.lastIndex == 0 )
    {
		self.shareView.hidden = YES;
		if(self.mode == FindMode_View) {
			self.tableView.hidden = NO;
			self.contactsTableView.hidden = YES;
			if(self.layoutType == 1) {
				[self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
				[self.sendButton setTitle:@"Send" forState:UIControlStateHighlighted];
				self.bottomToolbar.hidden = NO;
			}
			else
				self.bottomToolbar.hidden = YES;

			self.friendTypeSelectionView.hidden = YES;
		}
		else {
			self.tableView.hidden = YES;
			self.contactsTableView.hidden = YES;
			self.bottomToolbar.hidden = YES;
			self.friendTypeSelectionView.hidden = NO;
		}
    }
    else if(index.lastIndex == 1 )
    {
		if(self.layoutType == 1) {
			self.shareView.hidden = NO;
			self.tableView.hidden = YES;
			self.contactsTableView.hidden = YES;
			self.bottomToolbar.hidden = YES;
		}
		else {
			self.shareView.hidden = YES;
			self.tableView.hidden = YES;
			self.contactsTableView.hidden = NO;
			[self.sendButton setTitle:@"Invite" forState:UIControlStateNormal];
			[self.sendButton setTitle:@"Invite" forState:UIControlStateHighlighted];
			self.bottomToolbar.hidden = NO;
			self.friendTypeSelectionView.hidden = YES;
		}
    }
	else {
		self.shareView.hidden = YES;
		self.tableView.hidden = YES;
		self.contactsTableView.hidden = NO;
			
		[self.sendButton setTitle:@"Invite" forState:UIControlStateNormal];
		[self.sendButton setTitle:@"Invite" forState:UIControlStateHighlighted];
				
		self.bottomToolbar.hidden = NO;
		self.friendTypeSelectionView.hidden = YES;
	}
    
    [self.searchBar endEditing:YES];
    [self.contactsSearchBar endEditing:YES];
}


#pragma mark - SearchBar Delegate -
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchBar == self.searchBar) {
		if (searchText.length == 0)
			self.isFriendsFiltered = NO;
		else
			self.isFriendsFiltered = YES;
		
		NSMutableArray *tmpSearched = [[NSMutableArray alloc] init];
		
		for (Friend *friend in self.friends.friendsList) {
			
			NSString *nameString = [NSString stringWithFormat:@"%@ %@",friend.firstName, friend.lastName ];
			
			NSRange range = [nameString rangeOfString:searchText
											  options:NSCaseInsensitiveSearch];
			
			if (range.location != NSNotFound)
				[tmpSearched addObject:friend];
		}
		
		self.friendsSearchedData = [NSArray arrayWithArray:tmpSearched];
		
		[self.tableView reloadData];
	}
	else {
		if (searchText.length == 0)
			self.isContactsFiltered = NO;
		else
			self.isContactsFiltered = YES;
		
		NSMutableArray *tmpSearched = [[NSMutableArray alloc] init];
		
		for (Contact *contact in self.contacts) {
			
			NSString *nameString = [NSString stringWithFormat:@"%@ %@",contact.firstName, contact.lastName ];
			
			NSRange range = [nameString rangeOfString:searchText
											  options:NSCaseInsensitiveSearch];
			
			if (range.location != NSNotFound)
				[tmpSearched addObject:contact];
		}
		
		self.contactsSearchedData = [NSArray arrayWithArray:tmpSearched];
		
		[self.contactsTableView reloadData];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar endEditing:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
    [self.contactsSearchBar endEditing:YES];
}

- (void) uncheckAllFriends
{
    for (Friend *fr in self.friends.friendsList)
    {
        fr.checked = NO;
    }
    self.allFriendsSelected = NO;
}

- (void) uncheckAllContacts
{
	for (Contact *contact in self.contacts)
	{
		for(Email *email in contact.emails) {
			email.checked = NO;
		}
	}
    self.allContactsSelected = NO;
}

- (IBAction)cancelButtonPressed:(id)sender {
	self.mode = FindMode_View;
	self.tableView.hidden = NO;
	self.bottomToolbar.hidden = NO;
	self.friendTypeSelectionView.hidden = YES;
}

- (IBAction)sendButtonPressed:(id)sender {
    NSIndexSet *index = [self.segmentedControl selectedIndexes];
    if(index.lastIndex == 0) {
		NSMutableArray *friendArray = [[NSMutableArray alloc] init];
		
		for (Friend *fr in self.friends.friendsList)
		{
			if(fr.checked)
				[friendArray addObject:fr.friendUserId];
		}
		
		if([friendArray count] > 0)
		{
			self.sendButton.enabled = NO;
			
			self.sendAlertView.hidden = NO;
			self.sendAlertView.alpha = 0.0f;
			
			[UIView animateWithDuration:0.3 animations:^{
				self.sendAlertView.alpha = 0.799f;
			} completion:^(BOOL finished){
				if(finished) [UIView animateWithDuration:1.5 animations:^{
					self.sendAlertView.alpha = 0.8f;
				} completion:^(BOOL finished){
				}];
			}];
			
			[[PhactPrivateService sharedInstance] shareWithFriends:friendArray  savedPhactId:self.phactId onCompletion:^(id methodResults, NSError *error) {
				
				self.sendAlertView.hidden = YES;
				self.sendButton.enabled = YES;
				
				if(!error) {
					[self uncheckAllFriends];
					[self.tableView reloadData];
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
	else {
		// Invite Friends
		NSMutableArray *contactsArray = [[NSMutableArray alloc] init];
		
		for (Contact *contact in self.contacts)
		{
			NSMutableArray *emailsArray = [[NSMutableArray alloc] init];
			for(Email *email in contact.emails) {
				if(email.checked)
					[emailsArray addObject:email.email];
			}
			if(emailsArray.count > 0) {
				[contactsArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:contact.firstName,@"firstname",contact.lastName,@"lastname",emailsArray,@"emails", nil]];
			}
		}
		
		if([contactsArray count] > 0)
		{
			self.sendButton.enabled = NO;
			
			self.sendAlertView.hidden = NO;
			self.sendAlertView.alpha = 0.0f;
			
			[UIView animateWithDuration:0.3 animations:^{
				self.sendAlertView.alpha = 0.799f;
			} completion:^(BOOL finished){
				if(finished) [UIView animateWithDuration:1.5 animations:^{
					self.sendAlertView.alpha = 0.8f;
				} completion:^(BOOL finished){
				}];
			}];
			
			[[PhactPrivateService sharedInstance] sendInviteEmails:contactsArray onCompletion:^(id methodResults, NSError *error) {
				
				self.sendAlertView.hidden = YES;
				self.sendButton.enabled = YES;
				
				if(!error) {
					[self uncheckAllContacts];
					[self.contactsTableView reloadData];
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
}

- (IBAction)facebookSharePressed:(id)sender {
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
            NSString *output = nil;
            if (result == SLComposeViewControllerResultDone) {
                output = @"Posted on your facebook timeline";
            } else if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled");
            }
            if (output) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:output message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler = myBlock;
        [controller setInitialText:@""];
        [controller addImage:self.phactImage];
        [self presentViewController:controller animated:YES completion:nil];
//    }
}

- (IBAction)twitterSharePressed:(id)sender {
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result) {
            NSString *output = nil;
            if (result == SLComposeViewControllerResultDone) {
                output = @"Twitted";
            } else if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancelled");
            }
            if (output) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:output message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
            }
            [controller dismissViewControllerAnimated:YES completion:nil];
        };
        controller.completionHandler = myBlock;
        [controller setInitialText:@""];
        [controller addImage:self.phactImage];
        [self presentViewController:controller animated:YES completion:nil];
//    }
}

- (IBAction)emailSharePressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
		NSData *imageData = UIImageJPEGRepresentation(self.phactImage, 1.0f);
		
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"New Phact"];
        [mailViewController setMessageBody:@"Sent from Phact" isHTML:NO];
		[mailViewController addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"picture"];
		
        [self presentViewController:mailViewController animated:YES completion:^{
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
				[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
			}
		}];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Mail Accounts" message:@"Please, set up a Mail account in order to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    NSString *resultText = nil;
    switch (result) {
        case MFMailComposeResultSent:
            resultText = @"Email sent";
			break;
        case MFMailComposeResultFailed:
            resultText = @"Failed to send";
        default:
            break;
    }
    if (resultText) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:resultText message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
    }
    if (!error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"error :%@", [error localizedDescription]);
    }
}

- (void)signInWithOpenProviderConnector:(OpenProviderConnector *)connector  completion:(void (^)(BOOL finished))completion{
	[connector authorizeWithCallback:^(NSError *error) {
		if (error) {
			[ErrorManager showErrorAlertWithError:error];
			completion(NO);
		} else {
			[connector retrieveBasicUserInfoWithCallback:^(NSDictionary *userInfo, NSError *error) {
				if (error) {
					[ErrorManager showErrorAlertWithError:error];
                    completion(NO);
				} else {
                    if([connector isKindOfClass:[FacebookConnector class]]) {
                        [self facebookLogin:[userInfo objectForKey:@"accessToken"] completion:^(BOOL finished){
                            completion(finished);}];
					}
					else {
                        [self twitterLogin:[userInfo objectForKey:@"userId"] username:[userInfo objectForKey:@"userName"] firstname:[userInfo objectForKey:@"firstName"] lastname:[userInfo objectForKey:@"lastName"] avatar:[userInfo objectForKey:@"avatarURL"] completion:^(BOOL finished){
                            completion(finished);}];
					}
				}
			}];
		}
	}];
}

- (void)facebookLogin:(NSString *)accessToken completion:(void (^)(BOOL finished))completion
{
    [Customer fbPrivateConnect:accessToken onCompletion:^(id methodResults, NSError *error) {
        
        if(!error){
            PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
			if(app.customer.regType == RegisterType_Facebook) {
				Customer *result = (Customer *)methodResults;
				app.customer.email = result.email;
				app.customer.encryptedPassword = result.encryptedPassword;
				app.customer.firstName = result.firstName;
				app.customer.lastName = result.lastName;
				app.customer.customerAvatarURL = result.customerAvatarURL;
				app.customer.regType = RegisterType_Facebook;
				
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.email forKey:kuserLogin];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.encryptedPassword forKey:kuserPasswd];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.firstName forKey:kuserFirstname];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.lastName forKey:kuserLastname];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.customerAvatarURL forKey:kuserAvatarUrl];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:app.customer.regType ] forKey:kuserRegType];
            }
			
            completion(YES);
        }
        else {
            completion(NO);
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
															message: [error localizedDescription]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			[alert show];
		}
    }];
}

- (void)twitterLogin:(NSString *)userid username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar completion:(void (^)(BOOL finished))completion
{
    [Customer twPrivateConnect:userid username:username firstname:firstname lastname:lastname avatar:avatar onCompletion:^(id methodResults, NSError *error) {
        
        if(!error){
            PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
			if(app.customer.regType == RegisterType_Twitter) {
				Customer *result = (Customer *)methodResults;
				app.customer.email = result.email;
				app.customer.encryptedPassword = result.encryptedPassword;
				app.customer.firstName = result.firstName;
				app.customer.lastName = result.lastName;
				app.customer.customerAvatarURL = result.customerAvatarURL;
				app.customer.regType = RegisterType_Twitter;
				
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.email forKey:kuserLogin];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.encryptedPassword forKey:kuserPasswd];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.firstName forKey:kuserFirstname];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.lastName forKey:kuserLastname];
				[[NSUserDefaults standardUserDefaults] setObject:app.customer.customerAvatarURL forKey:kuserAvatarUrl];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:app.customer.regType ] forKey:kuserRegType];
            }
			
            completion(YES);
        }
        else {
            completion(NO);
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
															message: [error localizedDescription]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			[alert show];
		}
    }];
}

@end
