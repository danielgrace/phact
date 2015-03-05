//
//  ChangePasswordViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 12/6/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "CustomTextField.h"
#import "Customer.h"
#import <QuartzCore/QuartzCore.h>
#import "PhactAppDelegate.h"

@interface ChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet CustomTextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *enterPasswordTextField;
@property (weak, nonatomic) IBOutlet CustomTextField *reEnterTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *savedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oldPasswordTopConstraint;

- (IBAction)saveButtonPressed:(id)sender;
@end

@implementation ChangePasswordViewController

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
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		self.oldPasswordTopConstraint.constant = 20.0;
	}
	[self.navigationItem setTitle:@"CHANGE PASSWORD"];
	
	self.savedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"popup-check.png"]];
    self.savedView.layer.borderColor = [UIColor grayColor].CGColor;
    self.savedView.layer.borderWidth = 1.0f;
    self.savedView.layer.cornerRadius = 10.0;
    self.savedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.savedView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.savedView.layer.shadowOpacity = 0.5;
    self.savedView.hidden = YES;
	
	if (self.isResettingPassword) {
		self.oldPasswordTextField.placeholder = @"Pin Code *";
	}
	else {
		self.oldPasswordTextField.placeholder = @"Old Password *";
	}
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
	backButton.bounds = CGRectMake(0, 0, 40, 44);
	[backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.oldPasswordTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)closeButtonPressed:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(id)sender {
	if ([self validateForm]) {
        [self.view endEditing:YES];
        
        NSString *newPassword = self.enterPasswordTextField.text;
        NSString *pinCode = self.oldPasswordTextField.text;
        
		Customer *customer = [[Customer alloc] init];
		customer.customerId = self.customer.customerId;
		customer.email = self.customer.email;
		self.saveButton.enabled = NO;
		self.navigationItem.rightBarButtonItem.enabled = NO;
		
		if(self.isResettingPassword) {
			[Customer resetPassword:pinCode password:newPassword onCompletion:^(id result, NSError *error) {
				if (!error) {
					self.savedView.hidden = NO;
					self.savedView.alpha = 0.0f;
					
					[UIView animateWithDuration:0.3 animations:^{
						self.savedView.alpha = 0.799f;
					} completion:^(BOOL finished){
						if(finished) [UIView animateWithDuration:1.5 animations:^{
							self.savedView.alpha = 0.8f;
						} completion:^(BOOL finished){
							if (finished)
							{
								self.savedView.hidden = YES;
								if (self.navigationController.visibleViewController == self) {
									[self.navigationController popViewControllerAnimated:YES];
								}
							}
						}];
					}];
				}
				else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
																	message: [error localizedDescription]
																   delegate: nil
														  cancelButtonTitle: @"OK"
														  otherButtonTitles: nil, nil];
					[alert show];
				}
				self.saveButton.enabled = YES;
				self.navigationItem.rightBarButtonItem.enabled = YES;
			}];
		}
		else {
			[Customer changePassword:newPassword onCompletion:^(id result, NSError *error) {
				if (!error) {
					
					[[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:kuserPasswd];
					[[NSUserDefaults standardUserDefaults] synchronize];
					
					ASIJSONRPCError *jsonRPCError = nil;
					[[PhactPrivateService sharedInstance] authenticate:&jsonRPCError];

					self.savedView.hidden = NO;
					self.savedView.alpha = 0.0f;
					
					[UIView animateWithDuration:0.3 animations:^{
						self.savedView.alpha = 0.799f;
					} completion:^(BOOL finished){
						if(finished) [UIView animateWithDuration:1.5 animations:^{
							self.savedView.alpha = 0.8f;
						} completion:^(BOOL finished){
							if (finished)
							{
								self.savedView.hidden = YES;
								if (self.navigationController.visibleViewController == self) {
									[self.navigationController popViewControllerAnimated:YES];
								}
							}
						}];
					}];
				}
				else {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
																	message: [error localizedDescription]
																   delegate: nil
														  cancelButtonTitle: @"OK"
														  otherButtonTitles: nil, nil];
					[alert show];
				}
				self.saveButton.enabled = YES;
				self.navigationItem.rightBarButtonItem.enabled = YES;
			}];
		}

	}
}

- (BOOL)validateForm {
	UIColor *color = [UIColor redColor];
    BOOL valid = YES;
    if ([self.oldPasswordTextField.text isEqualToString:@""] || !self.oldPasswordTextField.text) {
        NSString *oldPasswordPlaceholderText = self.oldPasswordTextField.placeholder;
		self.oldPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:oldPasswordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
		valid = NO;
	}
	if ([self.enterPasswordTextField.text isEqualToString:@""] || !self.enterPasswordTextField.text) {
        NSString *enterPasswordPlaceholderText = self.enterPasswordTextField.placeholder;
		self.enterPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:enterPasswordPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
		valid = NO;;
	}
	if ([self.reEnterTextField.text isEqualToString:@""] || !self.reEnterTextField.text) {
        NSString *reEnterPlaceholderText = self.reEnterTextField.placeholder;
		self.reEnterTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:reEnterPlaceholderText attributes:@{NSForegroundColorAttributeName: color}];
		valid = NO;
	}
	if (![self.enterPasswordTextField.text isEqualToString:self.reEnterTextField.text]) {
		self.enterPasswordTextField.text = @"";
		self.reEnterTextField.text = @"";
		self.enterPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.enterPasswordTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
		self.reEnterTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.reEnterTextField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
		valid = NO;
	}
	return valid;
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if(textField == self.oldPasswordTextField) {
		[self.enterPasswordTextField becomeFirstResponder];
	}
	else if(textField == self.enterPasswordTextField) {
		[self.reEnterTextField becomeFirstResponder];
	}
	else if(textField == self.reEnterTextField) {
		[textField resignFirstResponder];
	}
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	UIColor *color = [UIColor lightGrayColor];
	textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (range.location == 0) {
		UIColor *color = [UIColor lightGrayColor];
		textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
	}
	return YES;
}

@end
