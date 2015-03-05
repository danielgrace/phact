//
//  PhactViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/23/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PhactViewController.h"
#import "FriendsViewController.h"
#import "AsyncImageCache.h"

@interface PhactViewController ()
@property (nonatomic, weak) IBOutlet UIImageView *phactImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@end

@implementation PhactViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.navigationItem.title = @"PHACT";
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
	backButton.bounds = CGRectMake(0, 0, 40, 44);
	[backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = backButtonItem;
	
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
	self.topLayoutConstraint.constant = 64.0;
	
	if([self.phactImageURL length] > 0)
    { 
		if (self.loadingIndicator.hidden)
			[self.loadingIndicator startAnimating];
		
        [[AsyncImageCache mainCache] retrieveImageWithURL:self.phactImageURL callback:^(UIImage *result, NSError *error, BOOL cached) {
			if ([result isKindOfClass:[UIImage class]]) {
				self.phactImageView.image = result;
				
				UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
				[shareButton setImage:[UIImage imageNamed:@"icon_friends"] forState:UIControlStateNormal];
				shareButton.bounds = CGRectMake(0, 0, 40, 44);
				[shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
				UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
				shareButtonItem.width = 0;
				self.navigationItem.rightBarButtonItem = shareButtonItem;
			}
			[self.loadingIndicator stopAnimating];
        }];
    }
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

- (void)backButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)shareButtonPressed:(id)sender {
	FriendsViewController *friendsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
	friendsViewController.phactId = self.phactId;
	friendsViewController.phactImage = self.phactImageView.image;
	friendsViewController.mode = FindMode_View;
	friendsViewController.layoutType = 1;
	[self.navigationController pushViewController:friendsViewController animated:YES];
}

@end
