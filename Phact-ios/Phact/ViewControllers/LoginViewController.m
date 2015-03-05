//
//  LoginViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/11/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomTextField.h"
#import "PhactAppDelegate.h"
#import "OpenProviderManager.h"
#import "OpenProviderConnector.h"
#import "Customer.h"
#import "ErrorManager.h"
#import "Philters.h"
#import "ChangePasswordViewController.h"
#import "RegistrationViewController.h"
#import "CustomerSettings.h"
#import "Contacts.h"
#import "FeedsTabBarController.h"
#import "FeedViewController.h"

#define KEYBOARD_HEIGHT		216

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet CustomTextField *usernameTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *checkEmailPopupView;
@property (weak, nonatomic) IBOutlet UILabel *checkEmailLabel;
@property (assign, nonatomic) UITextField *activeField;
@property (strong, nonatomic) Customer *customer;

@end

@implementation LoginViewController

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
    
	if(!IS_WIDESCREEN) {
		self.emailTopConstraint.constant = 130.0;
	}	
    
    self.checkEmailPopupView.backgroundColor = [UIColor blackColor];
    self.checkEmailPopupView.alpha = 0.8f;
    self.checkEmailPopupView.layer.cornerRadius = 10.0;
    self.checkEmailPopupView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.checkEmailPopupView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.checkEmailPopupView.layer.shadowOpacity = 0.5;
//    self.checkEmailLabel.font = [UIFont fontWithName:@"CoconOT-Regular" size:13.0];
    self.checkEmailLabel.textColor = [UIColor whiteColor];
    self.checkEmailLabel.text = @"Please check your email!";
	self.checkEmailPopupView.hidden = YES;
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

- (IBAction)loginButtonPressed:(id)sender {
	if ([self validateForm]) {
		[self.usernameTextField resignFirstResponder];
		[self.passwordTextField resignFirstResponder];
		
		[NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];
		[self login:self.usernameTextField.text password:self.passwordTextField.text];
	}
}

- (IBAction)signUpButtonPressed:(id)sender {
	RegistrationViewController *rootController = (RegistrationViewController *)[self.navigationController.viewControllers objectAtIndex:0];
	[rootController showSignup:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Password Reset" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reset", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 100;
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.font = [UIFont fontWithName:@"CoconOT-Regular" size:14.0];
	textField.placeholder = @"Email";
	textField.keyboardType = UIKeyboardTypeEmailAddress;
	[alert show];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 100) {
		if (buttonIndex == 1) {
			
            if (self.activityIndicator.hidden)
            {
                self.transparentView.hidden = NO;
                [self.activityIndicator startAnimating];
            }
            NSString *email = [alertView textFieldAtIndex:0].text;
            [Customer forgotPassword:email onCompletion:^(id result, NSError *error) {
                if (!error) {
                    [self.activityIndicator stopAnimating];
                    self.transparentView.hidden = YES;
                    
                    self.checkEmailPopupView.hidden = NO;
                    self.checkEmailPopupView.alpha = 0.0f;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.checkEmailPopupView.alpha = 0.799f;
                    } completion:^(BOOL finished){
                        if(finished) [UIView animateWithDuration:2
                                                      animations:^{
                                                          self.checkEmailPopupView.alpha = 0.8f;
                                                      } completion:^(BOOL finished){
                                                          if (finished)self.checkEmailPopupView.hidden = YES;
                                                              ChangePasswordViewController *changePasswordViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
                                                              changePasswordViewController.isResettingPassword = YES;
                                                              [self.navigationController pushViewController:changePasswordViewController animated:YES];
                                                      }];
                    }];
                }
                else
                {
                    [self.activityIndicator stopAnimating];
                    self.transparentView.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                    message: [error localizedDescription]
                                                                   delegate: nil
                                                          cancelButtonTitle: @"OK"
                                                          otherButtonTitles: nil, nil];
                    [alert show];
                }
            }];
		}
	}
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
    
	if ([self.usernameTextField.text isEqualToString:@""] || !self.usernameTextField.text || ![emailTest evaluateWithObject:[self.usernameTextField.text lowercaseString]])
    {
        [self.usernameTextField setText:@""];
        NSString *emailPlaceholderText = self.usernameTextField.placeholder;
        self.usernameTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:emailPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }

    if ([self.passwordTextField.text isEqualToString:@""] || !self.passwordTextField.text)
    {
        NSString *passwordPlaceholderText = self.passwordTextField.placeholder;
        self.passwordTextField.attributedPlaceholder =  [[NSAttributedString alloc] initWithString:passwordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
        valid = NO;
    }
    return  valid;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.usernameTextField) {
		[self.passwordTextField becomeFirstResponder];
	}
	else if(textField == self.passwordTextField) {
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
	if(self.contentViewTopConstraint.constant == 0.0) {
		if(self.loginButton.frame.origin.y + self.loginButton.frame.size.height > self.view.bounds.size.height - KEYBOARD_HEIGHT) {
			float shiftY = self.loginButton.frame.origin.y + self.loginButton.frame.size.height - (self.view.bounds.size.height - KEYBOARD_HEIGHT) + 10.0;
			self.contentViewTopConstraint.constant = -shiftY;
			[UIView animateWithDuration:0.3 animations:^{
				[self.view layoutIfNeeded];
			}];
		}
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

-(void) login:(NSString *)userName password:(NSString *)password
{
    [Customer login:userName passwd:password onCompletion:^(id methodResults, NSError *error) {
		[self.activityIndicator stopAnimating];
		self.transparentView.hidden = YES;

        if(error){
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
        else
        {
            self.customer = methodResults;
			self.customer.regType = RegisterType_Email;
            
			[CustomerSettings retrieveSettingsWithCustomer:^(id methodResults, NSError *error) {
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
					
					[[NSUserDefaults standardUserDefaults] setObject:self.customer.email forKey:kuserLogin];
					[[NSUserDefaults standardUserDefaults] setObject:self.customer.encryptedPassword forKey:kuserPasswd];
					[[NSUserDefaults standardUserDefaults] setObject:self.customer.firstName forKey:kuserFirstname];
					[[NSUserDefaults standardUserDefaults] setObject:self.customer.lastName forKey:kuserLastname];
					[[NSUserDefaults standardUserDefaults] setObject:self.customer.customerAvatarURL forKey:kuserAvatarUrl];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.customer.regType ] forKey:kuserRegType];
                    
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
                    
					Contacts *contacts = [Contacts sharedInstance];
					contacts.bSendContacts = YES;
					[contacts registerAddressBookChange];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kfacebookFriendAccess];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:ktwitterFriendAccess];
					[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kaddressBookAccess];

                    [[PhactPrivateService sharedInstance] findFriends:^(id methodResults, NSError *error) {
                        if(!error)
                        {
                        }
                        else {
                        }
                    }];
                    
					[app registerDeviceToken:^(id result, NSError *error) {
						if (!error) {
#if DEBUG_MODE
							NSLog(@"result = %@",result);
#endif
							[app updateNotificationBadge];
						}
						else
						{
							NSLog(@"RegisterDeviceToken Error: %@", [error description]);
						}
					}];
					
					[self dismissViewControllerAnimated:NO completion:^{
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
				}				
			}];
        }
    }];
}

- (void)startLoading {
	self.transparentView.hidden = NO;
	[self.activityIndicator startAnimating];
}

@end
