 //
//  SignUpViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "SignUpViewController.h"
#import "CustomTextField.h"
#import "Customer.h"
#import "PhactAppDelegate.h"
#import "Philters.h"
#import "RegistrationViewController.h"
#import "CustomerSettings.h"
#import "Contacts.h"
#import "FeedsTabBarController.h"
#import "FeedViewController.h"

#define KEYBOARD_HEIGHT		216

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet CustomTextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *emailTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *reEnterPasswordTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstNameTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic)  Customer *customer;
@property (assign, nonatomic) UITextField *activeField;
@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
/*	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
	backButton.bounds = CGRectMake(0, 0, 40, 44);
	[backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = backButtonItem;	
	self.navigationItem.title = @"SIGN UP";
*/
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		self.logoTopConstraint.constant = 20.0;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
			self.logoTopConstraint.constant = 0.0;
		}
	}
	else {
		self.logoTopConstraint.constant = 0.0;
	}

	if(!IS_WIDESCREEN) {
		self.firstNameTopConstraint.constant = 40.0;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)createAccountButtonPressed:(id)sender {
	if ([self validateForm]) {
		[NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];

        [Customer signUp:self.firstNameTextField.text lname:self.lastNameTextField.text email:self.emailTextField.text passwd:self.passwordTextField.text onCompletion:^(id methodResults, NSError *error) {
            
            if(error){
				[self.activityIndicator stopAnimating];
				self.transparentView.hidden = YES;
				
                if([error code] == 403)
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Wrong email or password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                else
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
            }
            else {
                self.customer = methodResults;
                self.customer.regType = RegisterType_Email;

				[[NSUserDefaults standardUserDefaults] setObject:self.customer.email forKey:kuserLogin];
				[[NSUserDefaults standardUserDefaults] setObject:self.customer.encryptedPassword forKey:kuserPasswd];
				[[NSUserDefaults standardUserDefaults] setObject:self.customer.firstName forKey:kuserFirstname];
				[[NSUserDefaults standardUserDefaults] setObject:self.customer.lastName forKey:kuserLastname];
				[[NSUserDefaults standardUserDefaults] setObject:self.customer.customerAvatarURL forKey:kuserAvatarUrl];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.customer.regType ] forKey:kuserRegType];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
				[app registerDeviceToken:^(id result, NSError *error) {
					if (!error) {
#if DEBUG_MODE
						NSLog(@"result = %@",result);
#endif
					}
					else
					{
						NSLog(@"RegisterDeviceToken Error: %@", [error description]);
					}
				}];

				[CustomerSettings retrieveSettingsWithCustomer:^(id methodResults, NSError *error) {
					[self.activityIndicator stopAnimating];
					self.transparentView.hidden = YES;
					
					if(error){
						if([error code] == 403)
						{
							UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Something went wrong. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
							[alert show];
						}
						else
						{
							UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
							[alert show];
						}
					}
					else
					{
                        CustomerSettings *settings = methodResults;
                        self.customer.philters = settings.philters;
                        self.customer.categories = settings.categories;
                        
						[self.customer.philters uppercaseFilterNames];
						PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
						[app setCustomerProfile:self.customer];
						
						if(self.customer.philters.activePhilters)
							[[NSUserDefaults standardUserDefaults] setObject:self.customer.philters.activePhilters forKey:@"TopPhilters"];
						if(self.customer.philters.inActivePhilters)
							[[NSUserDefaults standardUserDefaults] setObject:self.customer.philters.inActivePhilters forKey:@"MorePhilters"];
                        
                        if(self.customer.categories.categoriesArray)
                        {
                            NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.customer.categories];
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults setObject:encodedObject forKey:@"Categories"];
                            [defaults synchronize];
                        }
					}
					
					Contacts *contacts = [Contacts sharedInstance];
					contacts.bSendContacts = YES;
					[contacts registerAddressBookChange];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kfacebookFriendAccess];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ktwitterFriendAccess];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kaddressBookAccess];

                    [[PhactPrivateService sharedInstance] findFriends:^(id methodResults, NSError *error) {
                        if(!error){
                        }
                        else {
                        }
                    }];

					[self dismissViewControllerAnimated:YES completion:^{
						if([app.rootViewController isKindOfClass:[FeedsTabBarController class]]) {
							FeedsTabBarController *feedsTabBarController = (FeedsTabBarController *)app.rootViewController;
							
							UINavigationController *navController = [feedsTabBarController.viewControllers objectAtIndex:0];
							if([navController.topViewController isKindOfClass:[FeedViewController class]]) {
								FeedViewController *feedViewController = (FeedViewController *)navController.topViewController;
								
								[feedViewController loadFeedsByCategory:0];
							}
							feedsTabBarController.selectedIndex = 0;
						}
					}];
				}];
            }
        }];
		
	}
}

//- (void)backButtonPressed:(id)sender {
//	[self.navigationController popViewControllerAnimated:YES];
//}

- (IBAction)signInButtonPressed:(id)sender {
	RegistrationViewController *rootController = (RegistrationViewController *)[self.navigationController.viewControllers objectAtIndex:0];
	[rootController showLogin:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)validateForm
{
    UIColor *color = [UIColor redColor];
    NSString *emailRegex = @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL valid = YES;
    
    if ([self.firstNameTextField.text isEqualToString:@""] || !self.firstNameTextField.text)
    {
        NSString *firstNamePlaceholderText = self.firstNameTextField.placeholder;
        self.firstNameTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:firstNamePlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    if ([self.lastNameTextField.text isEqualToString:@""] || !self.lastNameTextField.text)
    {
        NSString *lastNamePlaceholderText = self.lastNameTextField.placeholder;
        self.lastNameTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:lastNamePlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    if ([self.emailTextField.text isEqualToString:@""] || !self.emailTextField.text || ![emailTest evaluateWithObject:[self.emailTextField.text lowercaseString]])
    {
        [self.emailTextField setText:@""];
        NSString *emailPlaceholderText = self.emailTextField.placeholder;
        self.emailTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:emailPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    if ([self.passwordTextField.text isEqualToString:@""] || !self.passwordTextField.text)
    {
        NSString *passwordPlaceholderText = self.passwordTextField.placeholder;
        self.passwordTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:passwordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    if ([self.reEnterPasswordTextField.text isEqualToString:@""] || !self.reEnterPasswordTextField.text)
    {
        NSString *reEnterPasswordPlaceholderText = self.reEnterPasswordTextField.placeholder;
        self.reEnterPasswordTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:reEnterPasswordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    if (![self.passwordTextField.text isEqualToString:self.reEnterPasswordTextField.text])
    {
        [self.passwordTextField setText:@""];
        [self.reEnterPasswordTextField setText:@""];
        NSString *passwordPlaceholderText = self.passwordTextField.placeholder;
        self.passwordTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:passwordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        NSString *reEnterPasswordPlaceholderText = self.reEnterPasswordTextField.placeholder;
        self.reEnterPasswordTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:reEnterPasswordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    return  valid;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.firstNameTextField) {
		[self.lastNameTextField becomeFirstResponder];
	}
	else if(textField == self.lastNameTextField) {
		[self.emailTextField becomeFirstResponder];
	}
	else if(textField == self.emailTextField) {
		[self.passwordTextField becomeFirstResponder];
	}
	else if(textField == self.passwordTextField) {
		[self.reEnterPasswordTextField becomeFirstResponder];
	}
	else if(textField == self.reEnterPasswordTextField) {
		self.contentViewTopConstraint.constant = 0.0;
		[UIView animateWithDuration:0.3 animations:^{
			[self.view layoutIfNeeded];
		}];
		[textField resignFirstResponder];
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	self.activeField = textField;
	if(textField.frame.origin.y + textField.frame.size.height > self.view.bounds.size.height - KEYBOARD_HEIGHT) {
		[self.view layoutIfNeeded];
		float shiftY = textField.frame.origin.y + textField.frame.size.height - (self.view.bounds.size.height - KEYBOARD_HEIGHT);
		self.contentViewTopConstraint.constant = -shiftY;
		[UIView animateWithDuration:0.3 animations:^{
			[self.view layoutIfNeeded];
		}];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	self.activeField = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([[touch.view class] isSubclassOfClass:[UIView class]]) {
		self.contentViewTopConstraint.constant = 0.0;
		[UIView animateWithDuration:0.3 animations:^{
			[self.view layoutIfNeeded];
		}];
		[self.activeField resignFirstResponder];
    }
}

- (void)startLoading {
	self.transparentView.hidden = NO;
	[self.activityIndicator startAnimating];
}

@end
