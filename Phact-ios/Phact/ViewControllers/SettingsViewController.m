//
//  SettingsViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "SettingsViewController.h"
#import "Customer.h"
#import "Philters.h"
#import "PhilterSettingsViewController.h"
#import "UIViewController+Animation.h"
#import "PhactAppDelegate.h"
#import "PhilterSettingsViewController.h"
#import "ProfileViewController.h"
#import "Contacts.h"

#define ITEM_HEIGHT             41
#define PHILTER_SETTING_ID      0
#define ACCOUNT_SETTING_ID      1
#define LOGOUT_ID               2
#define SECTION_COUNT 2

@interface SettingsViewController ()
{
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *sections;

@end

@implementation SettingsViewController

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
        // Initialization code
        self.sections = [[NSMutableArray alloc] initWithCapacity:SECTION_COUNT];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationItem.title = @"SETTINGS";
    
    [self.sections addObject: [NSArray arrayWithObjects:@"Philter Settings", @"Account Settings", nil]];
    [self.sections addObject:[NSArray arrayWithObjects:@"Sign Out", nil]];

    self.tableView.backgroundView = nil;
    self.tableView.backgroundView = [[UIView alloc] init];
    self.tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    
    self.tableView.separatorColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIImage *closeButtonImage = [UIImage imageNamed:@"icon_back"];
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[closeButton setImage:closeButtonImage forState:UIControlStateNormal];
	closeButton.bounds = CGRectMake(0, 0, 40, 44);
	[closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
	closeButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = closeButtonItem;
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


- (void)closeButtonPressed:(id)sender {
    
    [self popViewController:^(){
    }];
}

- (void)logout {
	
	[Customer logout:^(id result, NSError *error) {
		if (!error) {
			NSLog(@"result = %@",result);
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
    
    [self popViewController:^(){
        PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
		[app loginCustomer];
    }];
}

- (void)openPhilterSettings
{
    PhilterSettingsViewController *philterSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhilterSettingsViewController"];
    philterSettingsViewController.customer = self.customer;
    [self.navigationController pushViewController:philterSettingsViewController animated:YES];
}

- (void)openAccountProfile {
    ProfileViewController *profileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    profileViewController.customer = self.customer;
    [self.navigationController pushViewController:profileViewController animated:YES];
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
        [self openPhilterSettings];
    else if ((indexPath.section == 0) && (indexPath.row == 1))
        [self openAccountProfile];
    else if((indexPath.section == 1) &&  (indexPath.row == 0))
        [self logout];
}

@end
