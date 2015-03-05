//
//  RegistrationViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 12/4/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "OpenProviderManager.h"
#import "OpenProviderConnector.h"
#import "FacebookConnector.h"
#import "TwitterConnector.h"
#import "Customer.h"
#import "ErrorManager.h"
#import "PhactAppDelegate.h"
#import "Philters.h"
#import "CustomerSettings.h"
#import "Contacts.h"
#import "FeedsTabBarController.h"
#import "FeedViewController.h"

@interface RegistrationViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBackgrHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupButtonTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *loginBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *signupBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *emailLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *signUp;
@property (weak, nonatomic) IBOutlet UIButton *facebookSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *emailSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *logIn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterSignupButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterLoginButtonTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logInButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint6;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopConstraint7;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) Customer *customer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpGesture;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownGesture;

@end

@implementation RegistrationViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		_swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
		_swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeDown:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.facebookLoginButton.alpha = 0.0;
	self.twitterLoginButton.alpha = 0.0;
	self.emailLoginButton.alpha = 0.0;
	self.signUp.alpha = 0.0;
	self.facebookSignupButton.alpha = 0.0;
	self.twitterSignupButton.alpha = 0.0;
	self.emailSignupButton.alpha = 0.0;
	self.logIn.alpha = 0.0;
	self.label1.alpha = 0.0;
	self.label2.alpha = 0.0;
	
	if(!IS_WIDESCREEN) {
		self.loginBackgrHeight.constant = 480.0;
//		self.signupBackgrHeight.constant = 480.0;
		self.contentTopConstraint.constant = -240.0;
		self.contentBottomConstraint.constant = -240.0;
		self.loginButtonTopConstraint.constant = -135.0;
		self.signupButtonTopConstraint.constant = 100.0;		
		
		float logoTopConstraint = 190.0;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
			logoTopConstraint = 210.0;
		}
		self.logoTopConstraint1.constant = logoTopConstraint;
		self.logoTopConstraint2.constant = logoTopConstraint;
		self.logoTopConstraint3.constant = logoTopConstraint;
		self.logoTopConstraint4.constant = logoTopConstraint;
		self.logoTopConstraint5.constant = logoTopConstraint;
		self.logoTopConstraint6.constant = logoTopConstraint;
		self.logoTopConstraint7.constant = logoTopConstraint;
	}
	else {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
			self.logoTopConstraint1.constant = 234.0;
			self.logoTopConstraint2.constant = 234.0;
			self.logoTopConstraint3.constant = 234.0;
			self.logoTopConstraint4.constant = 234.0;
			self.logoTopConstraint5.constant = 234.0;
			self.logoTopConstraint6.constant = 234.0;
			self.logoTopConstraint7.constant = 234.0;
		}
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
			self.contentTopConstraint.constant = -284.0;
		}
	}
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		self.loginBackgrHeight.constant -= 20.0;
//		self.signupBackgrHeight.constant -= 20.0;
	}

    self.loginButton.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:28.0];
    self.signupButton.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:28.0];
    self.emailLoginButton.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:20.0];
    self.emailSignupButton.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:20.0];
    self.logIn.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:18.0];
    self.signUp.titleLabel.font = [UIFont fontWithName:@"NewsGothic_Lights" size:18.0];
	
	self.swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
	[self.view addGestureRecognizer:self.swipeUpGesture];
	self.swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
	[self.view addGestureRecognizer:self.swipeDownGesture];
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

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)gesture {
	if(self.contentTopConstraint.constant == -240.0 || self.contentTopConstraint.constant == -284.0)
		return;
	if(self.logIn.alpha == 0.0)
		[self showSignup:YES];
}

- (void)handleSwipeDown:(UISwipeGestureRecognizer *)gesture {
	if(self.contentTopConstraint.constant == -240.0 || self.contentTopConstraint.constant == -284.0)
		return;
	if(self.signUp.alpha == 0.0)
		[self showLogin:YES];
}

- (void)showLogin:(BOOL)animated {
	float endY = 480.0;
	float shiftY = 460.0;
	if(IS_WIDESCREEN) {
		shiftY = 548.0;
		endY = 568.0;
	}

	self.contentTopConstraint.constant = 0.0;
	self.contentBottomConstraint.constant = -568.0;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		endY = 460.0;
		if(IS_WIDESCREEN) {
			endY = 548.0;
		}
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		self.contentTopConstraint.constant = -20.0;
		endY = 460.0;
		if(IS_WIDESCREEN) {
			shiftY = 548.0;
			endY = 548.0;
		}
	}
	
	if(animated) {
		[UIView animateWithDuration:0.7 animations:^{
			self.facebookSignupButton.alpha = 0.0;
			self.twitterSignupButton.alpha = 0.0;
			self.emailSignupButton.alpha = 0.0;
			self.logIn.alpha = 0.0;
			[self.contentView layoutIfNeeded];
			self.facebookLoginButton.alpha = 1.0;
			self.twitterLoginButton.alpha = 1.0;
			self.emailLoginButton.alpha = 1.0;
			self.signUp.alpha = 1.0;
			self.label1.alpha = 1.0;

			NSMutableArray *frameValues = [[NSMutableArray alloc] initWithCapacity:11];
			for(int i = 0; i < self.view.subviews.count; i++) {
				[frameValues removeAllObjects];
				UIImageView *logoImageView = nil;
				id subview = [self.view.subviews objectAtIndex:i];
				if([subview isKindOfClass:[UIImageView class]]) {
					logoImageView = subview;
					CGPoint center = logoImageView.center;
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];

					float posY = (center.y + shiftY/(i*3) < endY) ? center.y + shiftY/(i*3) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/(i*2) < endY) ? center.y + shiftY/(i*2) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/(i*2) < endY) ? center.y + shiftY/(i*2) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					
					posY = (1.0/(i*3) + 1.0/(i*2) + 1.0/(i*2) + 6.0/i < 1) ? center.y + shiftY*(1 - 1.0/(i*3) - 1.0/(i*2) - 1.0/(i*2) - 6.0/i) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];

					CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
					anim1.values = frameValues;
					anim1.keyTimes = @[@0,@0.1,@0.2,@0.3,@0.4,@0.5,@0.6,@0.7,@0.8,@0.9,@1];
					anim1.calculationMode = kCAAnimationLinear;
					anim1.duration = 0.75;
					
					[logoImageView.layer addAnimation:anim1 forKey:nil];
				}
			}
		}
		completion:^(BOOL finished){
			self.logoTopConstraint1.constant = self.logoTopConstraint1.constant + shiftY;
			self.logoTopConstraint2.constant = self.logoTopConstraint2.constant + shiftY;
			self.logoTopConstraint3.constant = self.logoTopConstraint3.constant + shiftY;
			self.logoTopConstraint4.constant = self.logoTopConstraint4.constant + shiftY;
			self.logoTopConstraint5.constant = self.logoTopConstraint5.constant + shiftY;
			self.logoTopConstraint6.constant = self.logoTopConstraint6.constant + shiftY;
			self.logoTopConstraint7.constant = self.logoTopConstraint7.constant + shiftY;
		}];
	}
	else {
		self.facebookSignupButton.alpha = 0.0;
		self.twitterSignupButton.alpha = 0.0;
		self.emailSignupButton.alpha = 0.0;
		self.logIn.alpha = 0.0;
		[self.contentView layoutIfNeeded];
		self.facebookLoginButton.alpha = 1.0;
		self.twitterLoginButton.alpha = 1.0;
		self.emailLoginButton.alpha = 1.0;
		self.signUp.alpha = 1.0;
		self.label1.alpha = 1.0;
		
		self.logoTopConstraint1.constant = self.logoTopConstraint1.constant + shiftY;
		self.logoTopConstraint2.constant = self.logoTopConstraint2.constant + shiftY;
		self.logoTopConstraint3.constant = self.logoTopConstraint3.constant + shiftY;
		self.logoTopConstraint4.constant = self.logoTopConstraint4.constant + shiftY;
		self.logoTopConstraint5.constant = self.logoTopConstraint5.constant + shiftY;
		self.logoTopConstraint6.constant = self.logoTopConstraint6.constant + shiftY;
		self.logoTopConstraint7.constant = self.logoTopConstraint7.constant + shiftY;
	}
	
	if(IS_WIDESCREEN) {
		self.twitterLoginButtonTopConstraint.constant = -363.0;
	}
	else {
		self.twitterLoginButtonTopConstraint.constant = -319.0;
	}
}

- (void)showSignup:(BOOL)animated {
	
	float shiftY = 460.0;
	if(IS_WIDESCREEN) {
		shiftY = 548.0;
	}
	
	self.contentBottomConstraint.constant = -20.0;
	if(IS_WIDESCREEN) {
		self.contentTopConstraint.constant = -548.0;
	}
	else {
		self.contentTopConstraint.constant = -460.0;
	}
	self.logInButtonBottomConstraint.constant = -80.0;
	
	float endY = 20.0;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		endY = 0.0;
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		endY = 0.0;
		shiftY = 460.0;
		if(IS_WIDESCREEN) {
			shiftY = 548.0;
		}
	}
	if(animated) {
		[UIView animateWithDuration:0.7 animations:^{
			
			NSMutableArray *frameValues = [[NSMutableArray alloc] initWithCapacity:11];
			for(NSInteger i = 0; i < self.view.subviews.count; i++) {
				[frameValues removeAllObjects];
				UIImageView *logoImageView = nil;
				id subview = [self.view.subviews objectAtIndex:i];
				if([subview isKindOfClass:[UIImageView class]]) {
					logoImageView = subview;
					CGPoint center = logoImageView.center;
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					
					NSInteger j = self.view.subviews.count - i - 1;
					
					float posY = (center.y - shiftY/(j*3) > endY) ? center.y - shiftY/(j*3) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/(j*2) > endY) ? center.y - shiftY/(j*2) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/(j*2) > endY) ? center.y - shiftY/(j*2) : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					posY = (center.y - shiftY/j > endY) ? center.y - shiftY/j : endY;
					center = CGPointMake(center.x, posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					
					posY = (1.0/(j*3) + 1.0/(j*2) + 1.0/(j*2) + 6.0/j < 1) ? center.y-shiftY*(1 - 1.0/(j*3) - 1.0/(j*2) - 1.0/(j*2) - 6.0/j) : endY;
					center = CGPointMake(center.x, (posY < endY) ? endY : posY);
					[frameValues addObject:[NSNumber valueWithCGPoint:center]];
					
					CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
					anim1.values = frameValues;
					anim1.keyTimes = @[@0,@0.1,@0.2,@0.3,@0.4,@0.5,@0.6,@0.7,@0.8,@0.9,@1];
					anim1.calculationMode = kCAAnimationLinear;
					anim1.duration = 0.75;
					
					[logoImageView.layer addAnimation:anim1 forKey:nil];
				}
			}
			self.loginButton.alpha = 0.0;
			self.signupButton.alpha = 0.0;
			self.signUp.alpha = 0.0;
			self.facebookLoginButton.alpha = 0.0;
			self.twitterLoginButton.alpha = 0.0;
			self.emailLoginButton.alpha = 0.0;
			[self.contentView layoutIfNeeded];
			self.facebookSignupButton.alpha = 1.0;
			self.twitterSignupButton.alpha = 1.0;
			self.emailSignupButton.alpha = 1.0;
			self.logIn.alpha = 1.0;
			self.label2.alpha = 1.0;
		}
		completion:^(BOOL finished){
			self.logoTopConstraint1.constant = self.logoTopConstraint1.constant - shiftY;
			self.logoTopConstraint2.constant = self.logoTopConstraint2.constant - shiftY;
			self.logoTopConstraint3.constant = self.logoTopConstraint3.constant - shiftY;
			self.logoTopConstraint4.constant = self.logoTopConstraint4.constant - shiftY;
			self.logoTopConstraint5.constant = self.logoTopConstraint5.constant - shiftY;
			self.logoTopConstraint6.constant = self.logoTopConstraint6.constant - shiftY;
			self.logoTopConstraint7.constant = self.logoTopConstraint7.constant - shiftY;
		}];
	}
	else {
		self.loginButton.alpha = 0.0;
		self.signupButton.alpha = 0.0;
		self.signUp.alpha = 0.0;
		self.facebookLoginButton.alpha = 0.0;
		self.twitterLoginButton.alpha = 0.0;
		self.emailLoginButton.alpha = 0.0;
		[self.contentView layoutIfNeeded];
		self.facebookSignupButton.alpha = 1.0;
		self.twitterSignupButton.alpha = 1.0;
		self.emailSignupButton.alpha = 1.0;
		self.logIn.alpha = 1.0;
		self.label2.alpha = 1.0;

		self.logoTopConstraint1.constant = self.logoTopConstraint1.constant - shiftY;
		self.logoTopConstraint2.constant = self.logoTopConstraint2.constant - shiftY;
		self.logoTopConstraint3.constant = self.logoTopConstraint3.constant - shiftY;
		self.logoTopConstraint4.constant = self.logoTopConstraint4.constant - shiftY;
		self.logoTopConstraint5.constant = self.logoTopConstraint5.constant - shiftY;
		self.logoTopConstraint6.constant = self.logoTopConstraint6.constant - shiftY;
		self.logoTopConstraint7.constant = self.logoTopConstraint7.constant - shiftY;
	}
	
	if(IS_WIDESCREEN) {
		self.twitterSignupButtonTopConstraint.constant = -363.0;
	}
	else {
		self.twitterSignupButtonTopConstraint.constant = -319.0;
	}
}

- (IBAction)loginButtonPressed:(id)sender {
	self.contentTopConstraint.constant = 0.0;
	
	float shiftY = 240.0;
	float endY = 480.0;
	if(IS_WIDESCREEN) {
		shiftY = 284.0;
		endY = 568.0;
	}

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		self.contentTopConstraint.constant = -20.0;
		shiftY = 220.0;
		endY = 460.0;
		if(IS_WIDESCREEN) {
			shiftY = 264.0;
			endY = 548.0;
		}
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		endY = 460.0;
		if(IS_WIDESCREEN) {
			endY = 548.0;
		}
	}
	[UIView animateWithDuration:0.7 animations:^{
		self.loginButton.alpha = 0.0;
		self.signupButton.alpha = 0.0;
		[self.contentView layoutIfNeeded];
		self.facebookLoginButton.alpha = 1.0;
		self.twitterLoginButton.alpha = 1.0;
		self.emailLoginButton.alpha = 1.0;
		self.signUp.alpha = 1.0;
		self.label1.alpha = 1.0;
		
		NSMutableArray *frameValues = [[NSMutableArray alloc] initWithCapacity:7];
		for(int i = 0; i < self.view.subviews.count; i++) {
			[frameValues removeAllObjects];
			UIImageView *logoImageView = nil;
			id subview = [self.view.subviews objectAtIndex:i];
			if([subview isKindOfClass:[UIImageView class]]) {
				logoImageView = subview;
				CGPoint center = logoImageView.center;
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];

				float posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y + shiftY/i < endY) ? center.y + shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (5.0/i < 1) ? center.y + shiftY*(1 - 5.0/i) : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];

				CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
				anim1.values = frameValues;
				anim1.keyTimes = @[@0,@0.16,@0.33,@0.5,@0.66,@0.83,@1];
				anim1.calculationMode = kCAAnimationLinear;
				anim1.duration = 0.75;
				
				[logoImageView.layer addAnimation:anim1 forKey:nil];
			}
		}
	}
	completion:^(BOOL finished){
		self.logoTopConstraint1.constant = self.logoTopConstraint1.constant + shiftY;
		self.logoTopConstraint2.constant = self.logoTopConstraint2.constant + shiftY;
		self.logoTopConstraint3.constant = self.logoTopConstraint3.constant + shiftY;
		self.logoTopConstraint4.constant = self.logoTopConstraint4.constant + shiftY;
		self.logoTopConstraint5.constant = self.logoTopConstraint5.constant + shiftY;
		self.logoTopConstraint6.constant = self.logoTopConstraint6.constant + shiftY;
		self.logoTopConstraint7.constant = self.logoTopConstraint7.constant + shiftY;
	}];

	if(IS_WIDESCREEN) {
		self.twitterLoginButtonTopConstraint.constant = -363.0;
	}
	else {
		self.twitterLoginButtonTopConstraint.constant = -319.0;
	}
}

- (IBAction)signupButtonPressed:(id)sender {
	float shiftY = 220.0;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		shiftY = 240.0;
	}

	float endY = 20.0;
	if(IS_WIDESCREEN) {
		shiftY = 264.0;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
			shiftY = 284.0;
		}
	}
	
	self.contentBottomConstraint.constant = -20.0;
	if(IS_WIDESCREEN) {
		self.contentTopConstraint.constant = -548.0;
	}
	else {
		self.contentTopConstraint.constant = -460.0;
	}
	self.logInButtonBottomConstraint.constant = -80.0;
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		endY = 0.0;
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		endY = 0.0;
	}
	[UIView animateWithDuration:0.7 animations:^{
		
		NSMutableArray *frameValues = [[NSMutableArray alloc] initWithCapacity:7];
		for(int i = 0; i < self.view.subviews.count; i++) {
			[frameValues removeAllObjects];
			UIImageView *logoImageView = nil;
			id subview = [self.view.subviews objectAtIndex:i];
			if([subview isKindOfClass:[UIImageView class]]) {
				logoImageView = subview;
				CGPoint center = logoImageView.center;
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				
				float posY = (center.y - shiftY/(i*2) > endY) ? center.y - shiftY/(i*2) : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y - shiftY/i > endY) ? center.y - shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y - shiftY/i > endY) ? center.y - shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y - shiftY/i > endY) ? center.y - shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (center.y - shiftY/i > endY) ? center.y - shiftY/i : endY;
				center = CGPointMake(center.x, posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				posY = (1.0/(i*2) + 4.0/i < 1) ? center.y - shiftY*(1 - 1.0/(i*2) - 4.0/i) : endY;
				center = CGPointMake(center.x, (posY < endY) ? endY : posY);
				[frameValues addObject:[NSNumber valueWithCGPoint:center]];
				
				CAKeyframeAnimation *anim1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
				anim1.values = frameValues;
				anim1.keyTimes = @[@0,@0.16,@0.33,@0.5,@0.66,@0.83,@1];
				anim1.calculationMode = kCAAnimationLinear;
				anim1.duration = 0.75;
				
				[logoImageView.layer addAnimation:anim1 forKey:nil];
			}
		}
		self.loginButton.alpha = 0.0;
		self.signupButton.alpha = 0.0;
		[self.contentView layoutIfNeeded];
		self.facebookSignupButton.alpha = 1.0;
		self.twitterSignupButton.alpha = 1.0;
		self.emailSignupButton.alpha = 1.0;
		self.logIn.alpha = 1.0;
		self.label2.alpha = 1.0;
	}
	completion:^(BOOL finished){
		self.logoTopConstraint1.constant = self.logoTopConstraint1.constant - shiftY;
		self.logoTopConstraint2.constant = self.logoTopConstraint2.constant - shiftY;
		self.logoTopConstraint3.constant = self.logoTopConstraint3.constant - shiftY;
		self.logoTopConstraint4.constant = self.logoTopConstraint4.constant - shiftY;
		self.logoTopConstraint5.constant = self.logoTopConstraint5.constant - shiftY;
		self.logoTopConstraint6.constant = self.logoTopConstraint6.constant - shiftY;
		self.logoTopConstraint7.constant = self.logoTopConstraint7.constant - shiftY;
	}];

	if(IS_WIDESCREEN) {
		self.twitterSignupButtonTopConstraint.constant = -363.0;
	}
	else {
		self.twitterSignupButtonTopConstraint.constant = -319.0;
	}
}

- (IBAction)signUpPressed:(id)sender {
	[self showSignup:YES];
}

- (IBAction)logInPressed:(id)sender {
	[self showLogin:YES];
}

- (IBAction)emailSignupButtonPressed:(id)sender {
	SignUpViewController *signUpViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
	[self.navigationController pushViewController:signUpViewController animated:YES];
}

- (IBAction)emailLoginButtonPressed:(id)sender {
	LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	[self.navigationController pushViewController:loginViewController animated:YES];

}

- (IBAction)facebookButtonPressed:(id)sender {
	[NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];
    [self signInWithOpenProviderConnector:[[OpenProviderManager instance] facebookConnector]];
}

- (IBAction)twitterButtonPressed:(id)sender {
    [NSThread detachNewThreadSelector:@selector(startLoading) toTarget:self withObject:nil];
	[self signInWithOpenProviderConnector:[[OpenProviderManager instance] twitterConnector]];
}

- (void)signInWithOpenProviderConnector:(OpenProviderConnector *)connector {
	[connector authorizeWithCallback:^(NSError *error) {
		if (error) {
			[self.activityIndicator stopAnimating];
			self.transparentView.hidden = YES;
			[ErrorManager showErrorAlertWithError:error];
		} else {
			[connector retrieveBasicUserInfoWithCallback:^(NSDictionary *userInfo, NSError *error) {
				if (error) {
					[self.activityIndicator stopAnimating];
					self.transparentView.hidden = YES;
					[ErrorManager showErrorAlertWithError:error];
				} else {
                    if([connector isKindOfClass:[FacebookConnector class]])
                        [self facebookLogin:[userInfo objectForKey:@"accessToken"]];
                    else
                        [self twitterLogin:[userInfo objectForKey:@"userId"]
                                    username:[userInfo objectForKey:@"userName"]
                                    firstname:[userInfo objectForKey:@"firstName"]
                                  lastname:[userInfo objectForKey:@"lastName"]
									avatar:[userInfo objectForKey:@"avatarURL"]];
				}
			}];
		}
	}];
}

-(void)facebookLogin:(NSString *)accessToken
{
    [Customer fbConnect:accessToken onCompletion:^(id methodResults, NSError *error) {
        
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
        else
        {
            self.customer = methodResults;
            [self login:self.customer.email password:self.customer.encryptedPassword regType:RegisterType_Facebook];
        }
    }];
}

-(void)twitterLogin:(NSString *)userid username:(NSString *)username firstname:(NSString *)firstname lastname:(NSString *)lastname avatar:(NSString *)avatar
{
    [Customer twitterConnect:userid username:username firstname:firstname lastname:lastname avatar:avatar onCompletion:^(id methodResults, NSError *error) {
        
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
        else
        {
            self.customer = methodResults;
            [self login:self.customer.email password:self.customer.encryptedPassword regType:RegisterType_Twitter];
        }
    }];
}

-(void) login:(NSString *)userName password:(NSString *)password regType:(RegisterType)regType
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
            self.customer.regType = regType;
			
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
                        if(!error){
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
