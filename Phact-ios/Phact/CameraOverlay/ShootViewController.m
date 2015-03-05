//
//  ShootViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/18/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "ShootViewController.h"
#import "CaptureSessionManager.h"

#define PHACT_ALERT_TAG      2222

@interface ShootViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIButton *usePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *customButton;
@property (weak, nonatomic) IBOutlet UIImageView *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoViewImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;

///@property (assign,nonatomic) CGPoint scrollviewContentOffsetChange;

- (IBAction)retake:(id)sender;
- (IBAction)usePhoto:(id)sender;

@end

@implementation ShootViewController

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
        locationManager = [[CLLocationManager alloc] init];
		geocoder = [[CLGeocoder alloc] init];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
/**
	self.scrollView.delegate = self;
	self.scrollView.clipsToBounds = YES;
**/
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		self.contentTopConstraint.constant = 20.0;
	}
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
		self.contentTopConstraint.constant = 0.0;
		self.searchBarTopConstraint.constant = 20.0;
	}
	if(IS_WIDESCREEN)  {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
			self.imageViewHeightConstraint.constant = 568.0;
			self.contentViewHeightConstraint.constant = 612.0;
		}
		else {
			self.imageViewHeightConstraint.constant = 548.0;
			self.contentViewHeightConstraint.constant = 592.0;
		}
	}
	else {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
			self.imageViewHeightConstraint.constant = 480.0;
			self.contentViewHeightConstraint.constant = 524.0;
		}
		else {
			self.imageViewHeightConstraint.constant = 460.0;
			self.contentViewHeightConstraint.constant = 504.0;
		}
	}

	self.scrollView.delegate = self;
	self.scrollView.clipsToBounds = YES;
	[self.scrollView setScrollEnabled:YES];
	
	self.retakeButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:19.0];
	self.usePhotoButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:25.0];
	self.customButton.titleLabel.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:19.0];
	
	location = @"";
	locFullInfo = @"";
	[self getCurrentLocation];

/**
	self.infoViewImage.image = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"02")];

	int showInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ShootScreenInfoHidden"] intValue];
	if(showInfo == 0) {
		self.infoView.hidden = NO;
		self.infoView.alpha = 0.0f;
		[UIView animateWithDuration:0.3 animations:^{
			self.infoView.alpha = 1.0;
		} completion:^(BOOL finished){
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"ShootScreenInfoHidden"];
		}];
	}
**/
}
/**
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self updateZoom];
	self.scrollView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	self.scrollviewContentOffsetChange = self.scrollView.contentOffset;
}
**/

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
		[self.scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
		[self.scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:NO];
}

- (void)viewDidLayoutSubviews {
/*
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
		[self.scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:NO];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
		[self.scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:NO];
*/	
//	[self.scrollView scrollRectToVisible:CGRectMake(0.0, 460.0, 320.0, 44.0) animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return img;
}
**/
/*
- (UIImage *)captureView {
	
    float imageScale = sqrtf(powf(self.imageView.transform.a, 2.f) + powf(self.imageView.transform.c, 2.f));
    CGFloat widthScale = self.imageView.bounds.size.width / self.imageView.image.size.width;
    CGFloat heightScale = self.imageView.bounds.size.height / self.imageView.image.size.height;
    float contentScale = MIN(widthScale, heightScale);
    float effectiveScale = imageScale * contentScale;
	
    CGSize captureSize = CGSizeMake(self.scrollView.bounds.size.width / effectiveScale, self.scrollView.bounds.size.height / effectiveScale);
	
    NSLog(@"effectiveScale = %0.2f, captureSize = %@", effectiveScale, NSStringFromCGSize(captureSize));
	
    UIGraphicsBeginImageContextWithOptions(captureSize, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1/effectiveScale, 1/effectiveScale);
    [self.scrollView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return img;
}
*/
- (IBAction)retake:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)custom:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Intelligence" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phact", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = PHACT_ALERT_TAG;
	UITextField *textField = [alert textFieldAtIndex:0];
	textField.font = [UIFont systemFontOfSize:16.0];
	textField.placeholder = @"What are you Phacting?";
	textField.keyboardType = UIKeyboardTypeDefault;
	[alert show];
}

- (IBAction)usePhoto:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
/**
		self.usePhotoButon.hidden = YES;
		self.retakeButton.hidden = YES;
		self.bottomToolbar.hidden = YES;
		UIImage *image = [self imageWithView:self.view];
		
		self.usePhotoButton.hidden = NO;
		self.retakeButton.hidden = NO;
		self.bottomToolbar.hidden = NO;

        [self.delegate didFinishCapturing:image];
**/
        [self.delegate didFinishCapturing:self.imageView.image withBestGuessSearch:nil location:(NSString *)location locationFullInfo:locFullInfo];
    }];
}
/**
-(UIImageView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
	[self updateConstraints];
	
	self.scrollView.contentOffset = self.scrollviewContentOffsetChange;
//	self.scrollviewContentOffsetChange = CGPointZero;
}

- (void) updateConstraints {
	float imageWidth = self.imageView.image.size.width;
	float imageHeight = self.imageView.image.size.height;
	
	float viewWidth = self.view.bounds.size.width;
	float viewHeight = self.view.bounds.size.height;

	// center image if it is smaller than screen
	float hPadding = (viewWidth - self.scrollView.zoomScale * imageWidth) / 2;
	if (hPadding < 0) hPadding = 0;

	float vPadding = (viewHeight - self.scrollView.zoomScale * imageHeight) / 2;
	if (vPadding < 0) vPadding = 0;
	
	self.constraintLeft.constant = hPadding;
	self.constraintRight.constant = hPadding;
	
	self.constraintTop.constant = vPadding;
	self.constraintBottom.constant = vPadding;
}

// Zoom to show as much image as possible unless image is smaller than screen
- (void) updateZoom {
	float minZoom = MIN(self.view.bounds.size.width / self.imageView.image.size.width,
						self.view.bounds.size.height / self.imageView.image.size.height);
	
	if (minZoom > 1) minZoom = 1;
	
	self.scrollView.minimumZoomScale = minZoom;
	
	self.scrollView.zoomScale = minZoom;
}

- (IBAction)hideInfoButtonPressed:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		self.infoView.alpha = 0.0;
	} completion:^(BOOL finished){
		self.infoView.hidden = YES;
	}];
}
**/

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	float middlePos = 22.0;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
		middlePos = 42.0;

	if(targetContentOffset->y > middlePos) {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//			[scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:YES];
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[scrollView setContentOffset:CGPointMake(0, 64) animated:YES];
			}];
		else
			[scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];

		[self.searchBar endEditing:YES];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	float middlePos = 22.0;
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
		middlePos = 42.0;

	if(scrollView.contentOffset.y > middlePos) {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//			[scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:YES];
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[scrollView setContentOffset:CGPointMake(0, 64) animated:YES];
			}];
		else
			[scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];

		[self.searchBar endEditing:YES];
	}
	else {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//			[scrollView setContentOffset:CGPointMake(0.0, 22.0) animated:YES];
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				[scrollView setContentOffset:CGPointMake(0, 22) animated:YES];
			}];
		else
			[scrollView setContentOffset:CGPointZero animated:YES];

		[self.searchBar becomeFirstResponder];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate) {
		float middlePos = 22.0;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
			middlePos = 42.0;
	
		if(scrollView.contentOffset.y > middlePos) {
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//				[scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:YES];
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					[scrollView setContentOffset:CGPointMake(0, 64) animated:YES];
				}];
			else
				[scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];

			[self.searchBar endEditing:YES];
		}
		else {
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
//				[scrollView setContentOffset:CGPointMake(0.0, 22.0) animated:YES];
				[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					[scrollView setContentOffset:CGPointMake(0, 22) animated:YES];
				}];
			else
				[scrollView setContentOffset:CGPointZero animated:YES];

			[self.searchBar becomeFirstResponder];
		}
	}
}

#pragma mark - SearchBar Delegate -

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[self dismissViewControllerAnimated:NO completion:^{
		[self.delegate didFinishCapturing:self.imageView.image withBestGuessSearch:searchBar.text location:location locationFullInfo:locFullInfo];
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
		[self.scrollView setContentOffset:CGPointMake(0.0, 64.0) animated:YES];
	else
		[self.scrollView setContentOffset:CGPointMake(0.0, 44.0) animated:YES];

	[self.searchBar endEditing:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == PHACT_ALERT_TAG) {
		if (buttonIndex == 1) {
			[self dismissViewControllerAnimated:NO completion:^{
				NSString *text = [alertView textFieldAtIndex:0].text;
				[self.delegate didFinishCapturing:self.imageView.image withBestGuessSearch:text location:location locationFullInfo:locFullInfo];
			}];
		}
	}
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput) {
        if([[alertView textFieldAtIndex:0].text length] > 0) return YES;
        
		return NO;
    }
	return YES;
}

- (void)getCurrentLocation {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
#if DEBUG_MODE
    NSLog(@"didUpdateToLocation: %@", newLocation);
#endif
    CLLocation *currentLocation = newLocation;
    
	// Stop Location Manager
    [locationManager stopUpdatingLocation];
	
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
#if DEBUG_MODE
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
#endif
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
/*
			locFullInfo = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
						   placemark.subThoroughfare, placemark.thoroughfare,
						   placemark.postalCode, placemark.locality,
						   placemark.administrativeArea,
						   placemark.country];
*/
			if(placemark.areasOfInterest != nil) {
				for(int i = 0; i < placemark.areasOfInterest.count; i++) {
					NSString *area = [placemark.areasOfInterest objectAtIndex:i];
					if(i == placemark.areasOfInterest.count - 1)
						locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",area];
					else
						locFullInfo = [locFullInfo stringByAppendingFormat:@"%@ ",area];
				}
			}
			if(placemark.name != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.name];
			}
			if(placemark.subLocality != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.subLocality];
			}
			if(placemark.locality != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.locality];
			}
			if(placemark.subAdministrativeArea != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.subAdministrativeArea];
			}
			if(placemark.administrativeArea != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.administrativeArea];
			}
			if(placemark.country != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.country];
			}
			if(placemark.ocean != nil) {
				locFullInfo = [locFullInfo stringByAppendingFormat:@"%@,",placemark.ocean];
			}
			
			if((placemark.locality != nil) && (placemark.country != nil)) {
				location = [NSString stringWithFormat:@"%@, %@",
										   placemark.locality,
										   placemark.country];
			}
			else {
				if((placemark.locality == nil) && (placemark.country == nil))
					location = @"";
				else {
					NSString *locality = (placemark.locality == nil) ? @"" : placemark.locality;
					NSString *country = (placemark.country == nil) ? @"" : placemark.country;
					
					if([locality isEqualToString:@""]) {
						location = [NSString stringWithFormat:@"%@",country];
					}
					else {
						location = [NSString stringWithFormat:@"%@",locality];				}
				}
			}
			
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

@end
