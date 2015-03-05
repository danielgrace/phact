//
//  PhilterResultsViewController.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/25/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhilterResultsViewController.h"
#import "Phact.h"
#import "Phacts.h"
#import "FeedViewController.h"
#import "Customer.h"
#import "NSData+Base64.h"
#import "PhactAppDelegate.h"
#import "FriendsViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

#import "ASIHTTPRequest.h"
#import "NSString+Base64.h"

#import "PhactCategories.h"
#import "PhactCategory.h"
#import "PopListView.h"
#import "ImageUtils.h"
#import <ImageIO/ImageIO.h>

#define PHACT_RESULT_ALERT_TAG      1234
#define PHACT_RESULT_ALERT_TAG1     1235
#define	PHACT_HEIGHT				160.0

@interface PhilterResultsViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *phactView;
@property (weak, nonatomic) IBOutlet UIImageView *philterIcon;
@property (weak, nonatomic) IBOutlet UILabel *philterName;
@property (weak, nonatomic) IBOutlet UILabel *phactDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phactTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *phactHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topToolbarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *topToolbar;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UIButton *categoriesButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UILabel *placesLabel;
@property (weak, nonatomic) IBOutlet UIView *savedView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *loadSaveLabel;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIImageView *infoViewImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeInfoTopConstraint;

@property (nonatomic, strong) NSMutableArray *philterResults;
@property (nonatomic, strong) NSDictionary *philterIcons;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *tempPhilterResults;
@property (nonatomic, strong) UIImage *phactImage;
@property (nonatomic, assign) NSTimeInterval phactDate;
@property (nonatomic) BOOL sentRequest;
@property (strong, atomic) ALAssetsLibrary *library;
@property (assign, nonatomic) NSInteger phactId;
@property (nonatomic, strong) NSMutableArray *savedPhacts;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSMutableArray *selectedCategories;
@property (nonatomic, strong) UIImage *resizedImage;
@property (nonatomic, assign) BOOL bCycle;
@property (nonatomic, copy) NSString *locInfo;

@end

@implementation PhilterResultsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Philters.plist"];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:resourcePath];
		_philterIcons = [[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"PhilterIcons"]];
		_philterResults = [[NSMutableArray alloc] init];
		_tempPhilterResults = [[NSMutableArray alloc] initWithArray:self.philterResults];
		
		PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
		_categories = [[NSMutableArray alloc] initWithArray:app.customer.categories.categoriesArray];
		_selectedCategories = [[NSMutableArray alloc] init];
		
		_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

		_library = [[ALAssetsLibrary alloc] init];
		_savedPhacts = [[NSMutableArray alloc] init];
		geocoder = [[CLGeocoder alloc] init];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
    self.sentRequest = NO;
    
    self.refreshButton.hidden = YES;
	self.categoriesButton.hidden = YES;
	self.locationIcon.hidden = YES;
	self.locationLabel.hidden = YES;
    self.okButton.hidden = YES;
    self.closeButton.hidden = YES;
	self.searchButton.hidden = YES;
    
	self.backgroundImageView.image = self.backgImage;
    self.philterName.font = [UIFont fontWithName:@"NewsGothic_Lights" size:18.0];
    self.phactDescription.font = [UIFont fontWithName:@"NewsGothic_Lights" size:17.0];

	[self.phactView addGestureRecognizer:self.tapGesture];

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		if(!IS_WIDESCREEN) {
			self.phactTopConstraint.constant = 256.0;
		}
		else {
			self.phactTopConstraint.constant = 344.0;
		}
		self.closeInfoTopConstraint.constant += 13.0;
	}
	else {
		if(!IS_WIDESCREEN) {
			self.phactTopConstraint.constant = 238.0;
		}
		else {
			self.phactTopConstraint.constant = 324.0;
		}
		self.topToolbarTopConstraint.constant = -68.0;
	}
    
    self.savedView.backgroundColor = [UIColor blackColor]; //[UIColor colorWithPatternImage:[UIImage imageNamed:@"popup-check.png"]];
    self.savedView.layer.borderColor = [UIColor clearColor].CGColor;
    self.savedView.layer.borderWidth = 1.0f;
    self.savedView.layer.cornerRadius = 10.0;
    self.savedView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.savedView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.savedView.layer.shadowOpacity = 0.5;
    self.savedView.hidden = YES;
	
///	self.infoViewImage.image = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"01")];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.savedView.hidden = YES;

    if(!self.sentRequest)
    {
        if (self.loadingIndicator.hidden)
        {
            self.transparentView.hidden = NO;
            self.savedView.hidden = NO;
            [self.loadingIndicator startAnimating];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    [self imageSearch];
	
	if(self.bestGuessContext == nil)
		[self imageStoreAndSearch];
    else
		[self searchByBestGuess];
}
/**
- (void)showInfoScreen {
	int showInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ResultScreenInfoHidden"] intValue];
	if(showInfo == 0) {
		self.infoView.hidden = NO;
		self.infoView.alpha = 0.0f;
		[UIView animateWithDuration:0.3 animations:^{
			self.infoView.alpha = 1.0;
		} completion:^(BOOL finished){
			[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:@"ResultScreenInfoHidden"];
		}];
	}
}

- (IBAction)hideInfoButtonPressed:(id)sender {
	[UIView animateWithDuration:0.3 animations:^{
		self.infoView.alpha = 0.0;
	} completion:^(BOOL finished){
		self.infoView.hidden = YES;
	}];
}
**/

- (void)sendSearchByBestGuess {
	[Phacts searchByBestGuess:self.bestGuessContext location:self.locInfo onCompletion:^(id result, NSError *error) {
		[self.loadingIndicator stopAnimating];
		self.transparentView.hidden = YES;
		self.savedView.hidden = YES;
		self.sentRequest = YES;
		
		if (!error) {
			self.refreshButton.hidden = NO;
			self.categoriesButton.hidden = NO;
			self.locationIcon.hidden = NO;
			self.locationLabel.hidden = NO;
			self.okButton.hidden = NO;
			self.closeButton.hidden = NO;
			self.searchButton.hidden = NO;
			
			Phacts *phacts = (Phacts *)result;
			if(phacts)
			{
				if(phacts.phacts)
				{
					[self.philterResults setArray:phacts.phacts];
					[self.tempPhilterResults setArray:phacts.phacts];
				}
				
				///					self.currentIndex = arc4random() % self.philterResults.count;
				self.currentIndex = 0;
				self.bCycle = YES;
				
				Phact *phact = [self.philterResults objectAtIndex:self.currentIndex];
				self.philterIcon.image = [UIImage imageNamed:[self.philterIcons objectForKey:[phact.philterName uppercaseString]]];
				self.philterName.text = [phact.philterName uppercaseString];
				self.phactDescription.text = phact.desc;
				
				NSDate *now = [NSDate date];
				self.phactDate = [now timeIntervalSince1970];
#if DEBUG_MODE
				for(int i = 0; i < phacts.phacts.count; i++) {
					Phact *ph = [phacts.phacts objectAtIndex:i];
					NSLog(@"description length = %lu",(unsigned long)[ph.desc length]);
				}
#endif
			}
			///				[self showInfoScreen];
		}
		else
		{
			self.sentRequest = YES;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
															message: [error localizedDescription]
														   delegate: self
												  cancelButtonTitle: @"OK"
												  otherButtonTitles: nil, nil];
			alert.tag = PHACT_RESULT_ALERT_TAG;
			[alert show];
		}
	}];
}


- (void)searchByBestGuess {
    if(!self.sentRequest) {
		self.locInfo = @"";
		self.locationLabel.text = @"";
		self.loadSaveLabel.text = @"Retrieving...";
		UIImage *normalizedImage = [ImageUtils normalizedImage:self.backgImage];
		CGSize size = CGSizeMake(320.0, 480.0);
		if(IS_WIDESCREEN)
			size = CGSizeMake(320.0, 568.0);
		
		self.resizedImage = [ImageUtils imageWithImage:normalizedImage scaledToSize:size quality:kCGInterpolationHigh];
		
		if (self.imageURL) {
			ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
				CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
				[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
					if (error == nil && [placemarks count] > 0) {
						placemark = [placemarks lastObject];
						
						if(placemark.areasOfInterest != nil) {
							for(int i = 0; i < placemark.areasOfInterest.count; i++) {
								NSString *area = [placemark.areasOfInterest objectAtIndex:i];
								if(i == placemark.areasOfInterest.count - 1)
									self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",area];
								else
									self.locInfo = [self.locInfo stringByAppendingFormat:@"%@ ",area];
							}
						}
						if(placemark.name != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.name];
						}
						if(placemark.subLocality != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.subLocality];
						}
						if(placemark.locality != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.locality];
						}
						if(placemark.subAdministrativeArea != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.subAdministrativeArea];
						}
						if(placemark.administrativeArea != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.administrativeArea];
						}
						if(placemark.country != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.country];
						}
						if(placemark.ocean != nil) {
							self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.ocean];
						}

						if((placemark.locality != nil) && (placemark.country != nil)) {
							self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",
													   placemark.locality,
													   placemark.country];
						}
						else {
							if((placemark.locality == nil) && (placemark.country == nil))
								self.locationLabel.text = @"";
							else {
								NSString *locality = (placemark.locality == nil) ? @"" : placemark.locality;
								NSString *country = (placemark.country == nil) ? @"" : placemark.country;
								
								if([locality isEqualToString:@""]) {
									self.locationLabel.text = [NSString stringWithFormat:@"%@",country];
								}
								else {
									self.locationLabel.text = [NSString stringWithFormat:@"%@",locality];				}
							}
						}
					}
					[self sendSearchByBestGuess];
				}];
			};
			ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error) {
				NSLog(@"can't get image - %@", [error localizedDescription]);
			};
			ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
			[assetsLib assetForURL:self.imageURL resultBlock:resultblock failureBlock:failureblock];
		}
		else {
			self.locationLabel.text = self.location;
			self.locInfo = self.locFullInfo;
			
			[self sendSearchByBestGuess];
		}
		if(self.cameraSourceType) {
			self.locationLabel.text = self.location;
		}
	}
}

- (void)imageStoreAndSearch
{
    if(!self.sentRequest)
    {
		self.locInfo = @"";
        self.loadSaveLabel.text = @"Uploading...";
		UIImage *normalizedImage = [ImageUtils normalizedImage:self.backgImage];
		CGSize size = CGSizeMake(320.0, 480.0);
		if(IS_WIDESCREEN)
			size = CGSizeMake(320.0, 568.0);
		
		self.resizedImage = [ImageUtils imageWithImage:normalizedImage scaledToSize:size quality:kCGInterpolationHigh];
		
       NSData *imageData = UIImageJPEGRepresentation(self.resizedImage, 0.5f);
        [[PhactPrivateService sharedInstance] storeImage:[imageData base64EncodedString] option:self.cameraSourceType onCompletion:^(id result, NSError *error) {
            if (!error) {
                if (result && [result isKindOfClass:[NSDictionary class]])
                {
                    NSString *imageUrl = [result objectForKey:@"url"];
					self.locationLabel.text = @"";
					
					if (self.imageURL) {
						ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
							CLLocation *location = [myasset valueForProperty:ALAssetPropertyLocation];
							[geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
								if (error == nil && [placemarks count] > 0) {
									placemark = [placemarks lastObject];
									if(placemark.areasOfInterest != nil) {
										for(int i = 0; i < placemark.areasOfInterest.count; i++) {
											NSString *area = [placemark.areasOfInterest objectAtIndex:i];
											if(i == placemark.areasOfInterest.count - 1)
												self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",area];
											else
												self.locInfo = [self.locInfo stringByAppendingFormat:@"%@ ",area];
										}
									}
									if(placemark.name != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.name];
									}
									if(placemark.subLocality != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.subLocality];
									}
									if(placemark.locality != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.locality];
									}
									if(placemark.subAdministrativeArea != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.subAdministrativeArea];
									}
									if(placemark.administrativeArea != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.administrativeArea];
									}
									if(placemark.country != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.country];
									}
									if(placemark.ocean != nil) {
										self.locInfo = [self.locInfo stringByAppendingFormat:@"%@,",placemark.ocean];
									}
									if((placemark.locality != nil) && (placemark.country != nil)) {
										self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",
																   placemark.locality,
																   placemark.country];
									}
									else {
										if((placemark.locality == nil) && (placemark.country == nil))
											self.locationLabel.text = @"";
										else {
											NSString *locality = (placemark.locality == nil) ? @"" : placemark.locality;
											NSString *country = (placemark.country == nil) ? @"" : placemark.country;
											
											if([locality isEqualToString:@""]) {
												self.locationLabel.text = [NSString stringWithFormat:@"%@",country];
											}
											else {
												self.locationLabel.text = [NSString stringWithFormat:@"%@",locality];				}
										}
									}
								}
							}];
						};
						ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *error) {
							NSLog(@"can't get image - %@", [error localizedDescription]);
						};
						ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
						[assetsLib assetForURL:self.imageURL resultBlock:resultblock failureBlock:failureblock];
					}

					self.loadSaveLabel.text = @"Searching...";
                    [self sendCurlRequest:imageUrl];
					
					if(self.cameraSourceType) {
						self.locationLabel.text = self.location;
						self.locInfo = self.locFullInfo;
					}
                }
            }
            else
            {
				[self.loadingIndicator stopAnimating];
				self.savedView.hidden = YES;
				self.transparentView.hidden = YES;
				self.sentRequest = YES;

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                message: [error localizedDescription]
                                                               delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil, nil];
                alert.tag = PHACT_RESULT_ALERT_TAG;
                [alert show];
            }
        }];
    }
}

-(void) sendCurlRequest:(NSString *) url
{

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL: [NSURL URLWithString:url ]];
    
    [request addRequestHeader:@"User-Agent" value:@"AMozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36"];
    [request addRequestHeader:@"Referer" value:@"https://www.google.com"];
    [request addRequestHeader:@"Connection" value:@"Keep-Alive"];
    
    [request setValidatesSecureCertificate:NO];
    [request setRequestMethod:@"GET"];
    [request setTimeOutSeconds:20];
    [request setDelegate:self];
    [request setDidFinishSelector: @selector(ASIJSONRPCFinished:)];
    [request setDidFailSelector: @selector(ASIJSONRPCFailed:)];

    [request startAsynchronous];
}

- (void)ASIJSONRPCFailed:(ASIHTTPRequest *)request {
   
    NSError *error = [request error];
    
#if DEBUG_MODE
    NSLog(@"************************ERROR*********************************");
    NSLog(@"response error:%@",[error localizedDescription]);
#endif

    [self.loadingIndicator stopAnimating];
    self.savedView.hidden = YES;
    self.transparentView.hidden = YES;
    self.sentRequest = YES;

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                    message: [error localizedDescription]
                                                   delegate: self
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil, nil];
	alert.tag = PHACT_RESULT_ALERT_TAG;
    [alert show];
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL {
    
    if ([request responseStatusCode ] != 307 && (![request shouldUseRFC2616RedirectBehaviour] || [request responseStatusCode] == 303)) {
        
//        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [request addRequestHeader:@"User-Agent" value:@"AMozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36"];
        [request addRequestHeader:@"Referer" value:@"https://www.google.com"];
        [request addRequestHeader:@"Connection" value:@"Keep-Alive"];
        [request redirectToURL:newURL];
    }
}

- (void)ASIJSONRPCFinished:(ASIHTTPRequest *)request {
    
#if DEBUG_MODE
    NSLog(@"*********************************************************");
    NSLog(@"response:%@",[request responseString]);
    NSLog(@"ASIJSONRPCFinished response code = %d", [request responseStatusCode]);
#endif

	self.loadSaveLabel.text = @"Retrieving...";
    NSString *encodeString = [NSString base64String:[request responseString]];
#if DEBUG_MODE
	NSLog(@"doSearch : location - %@",self.locationLabel.text);
#endif
    [Phacts doSearch:encodeString location:self.locInfo onCompletion:^(id result, NSError *error) {
        [self.loadingIndicator stopAnimating];
        self.transparentView.hidden = YES;
        self.savedView.hidden = YES;
        self.sentRequest = YES;
        
        if (!error) {
            
            self.refreshButton.hidden = NO;
            self.categoriesButton.hidden = NO;
            self.locationIcon.hidden = NO;
            self.locationLabel.hidden = NO;
            self.okButton.hidden = NO;
            self.closeButton.hidden = NO;
			self.searchButton.hidden = NO;
            
            Phacts *phacts = (Phacts *)result;
            if(phacts)
            {
                if(phacts.phacts)
                {
                    [self.philterResults setArray:phacts.phacts];
                    [self.tempPhilterResults setArray:phacts.phacts];
                }
                
///                self.currentIndex = arc4random() % self.philterResults.count;
				self.currentIndex = 0;
				self.bCycle = YES;
                
                Phact *phact = [self.philterResults objectAtIndex:self.currentIndex];
                self.philterIcon.image = [UIImage imageNamed:[self.philterIcons objectForKey:[phact.philterName uppercaseString]]];
                self.philterName.text = [phact.philterName uppercaseString];
                self.phactDescription.text = phact.desc;
                ///                    self.placesLabel.text = ([phacts.geolocation isKindOfClass:[NSNull class]]) ? @"" : phacts.geolocation;
                
                NSDate *now = [NSDate date];
                self.phactDate = [now timeIntervalSince1970];
#if DEBUG_MODE
                for(int i = 0; i < phacts.phacts.count; i++) {
                    Phact *ph = [phacts.phacts objectAtIndex:i];
                    NSLog(@"description length = %lu",(unsigned long)[ph.desc length]);
                }
#endif
            }
///			[self showInfoScreen];
        }
        else
        {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Intelligence" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phact", nil];
			alert.alertViewStyle = UIAlertViewStylePlainTextInput;
			alert.tag = PHACT_RESULT_ALERT_TAG1;
			UITextField *textField = [alert textFieldAtIndex:0];
			textField.font = [UIFont systemFontOfSize:16.0];
			textField.placeholder = @"What are you Phacting?";
			textField.keyboardType = UIKeyboardTypeDefault;
			[alert show];
        }
    }];
}


-(void) imageSearch
{
    if(!self.sentRequest)
    {
        NSData *imageData = UIImageJPEGRepresentation(self.backgImage, 1.0f);
        
        [Phacts imageSearch:[imageData base64EncodedString] onCompletion:^(id result, NSError *error) {
            [self.loadingIndicator stopAnimating];
            self.transparentView.hidden = YES;
            self.savedView.hidden = YES;
            self.sentRequest = YES;
            
            if (!error) {
                
                self.refreshButton.hidden = NO;
                self.categoriesButton.hidden = NO;
                self.locationIcon.hidden = NO;
                self.locationLabel.hidden = NO;
                self.okButton.hidden = NO;
                self.closeButton.hidden = NO;
				self.searchButton.hidden = NO;
                
                Phacts *phacts = (Phacts *)result;
                if(phacts)
                {
                    if(phacts.phacts)
                    {
                        [self.philterResults setArray:phacts.phacts];
                        [self.tempPhilterResults setArray:phacts.phacts];
                    }
                    
///                    self.currentIndex = arc4random() % self.philterResults.count;
					self.currentIndex = 0;
					self.bCycle = YES;
                    
                    Phact *phact = [self.philterResults objectAtIndex:self.currentIndex];
                    self.philterIcon.image = [UIImage imageNamed:[self.philterIcons objectForKey:[phact.philterName uppercaseString]]];
                    self.philterName.text = [phact.philterName uppercaseString];
                    self.phactDescription.text = phact.desc;
                    ///                    self.placesLabel.text = ([phacts.geolocation isKindOfClass:[NSNull class]]) ? @"" : phacts.geolocation;
                    
					NSDate *now = [NSDate date];
					self.phactDate = [now timeIntervalSince1970];
#if DEBUG_MODE
					for(int i = 0; i < phacts.phacts.count; i++) {
						Phact *ph = [phacts.phacts objectAtIndex:i];
						NSLog(@"description length = %lu",(unsigned long)[ph.desc length]);
					}
#endif
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: nil
                                                                message: [error localizedDescription]
                                                               delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil, nil];
                alert.tag = PHACT_RESULT_ALERT_TAG;
                [alert show];
            }
        }];
		self.locationLabel.text = @"";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openFriendsList {
	FriendsViewController *friendsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsViewController"];
	friendsViewController.phactId = self.phactId;
	friendsViewController.phactImage = self.phactImage;
	friendsViewController.mode = FindMode_View;
	friendsViewController.layoutType = 1;
	[self.navigationController pushViewController:friendsViewController animated:YES];
	
	[self.loadingIndicator stopAnimating];
	self.transparentView.hidden = YES;
	self.savedView.hidden = YES;
}

- (IBAction)friendsButtonPressed:(id)sender {
	self.phactImage = [self getPhactImage];

    if (self.loadingIndicator.hidden)
    {
        self.transparentView.hidden = NO;
        [self.loadingIndicator startAnimating];
        
        self.loadSaveLabel.text = @" Saving...";
        self.savedView.hidden = NO;
        self.savedView.alpha = 0.0f;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.savedView.alpha = 0.799f;
        } completion:^(BOOL finished){
            if(finished) [UIView animateWithDuration:1.5 animations:^{
                self.savedView.alpha = 0.8f;
            } completion:^(BOOL finished){
            }];
        }];
    }

    Phact *phact = nil;
    if([self.tempPhilterResults count] == 0)
        phact = [[Phact alloc] init];
    else
        phact = [self.tempPhilterResults objectAtIndex:self.currentIndex];
    
	NSData *imageData = UIImageJPEGRepresentation(self.resizedImage, 1.0f);
	NSData *printedImageData = UIImageJPEGRepresentation(self.phactImage, 1.0f);
	phact.image = [imageData base64EncodedString];
	phact.printedImage = [printedImageData base64EncodedString];
	phact.createdDate = self.phactDate;
	phact.location = self.locationLabel.text;
	
	NSMutableArray *categoryIds = [[NSMutableArray alloc] init];
	for(int i = 0; i < self.selectedCategories.count; i++) {
		PhactCategory *phactCategory = [self.categories objectAtIndex:[[self.selectedCategories objectAtIndex:0] integerValue]];
		[categoryIds addObject:[NSNumber numberWithInteger:phactCategory.categoryId]];
	}
	phact.categories = [[NSMutableArray alloc] initWithArray:categoryIds];

	NSInteger index = [self.savedPhacts indexOfObject:[NSNumber numberWithInteger:phact.ident]];
	if(index == NSNotFound) {
		[self savePhact:phact completion:^(BOOL finished) {
			if(finished) {
				phact.ident = self.phactId;
				[self.savedPhacts addObject:[NSNumber numberWithInteger:self.phactId]];
				[self openFriendsList];
			}
		}];
	}
	else {
		self.phactId = phact.ident;
		[self openFriendsList];
	}
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
	if(self.phactHeight.constant == PHACT_HEIGHT) {
		float height = self.phactDescription.frame.size.height;
		CGSize labelSize = [self.phactDescription.text sizeWithFont:self.phactDescription.font
												  constrainedToSize: CGSizeMake(self.phactDescription.frame.size.width, 400)
													  lineBreakMode:self.phactDescription.lineBreakMode];
        
        CGFloat labelHeight = labelSize.height;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
			labelHeight = labelSize.height+3.0;
        
		if(self.phactHeight.constant + labelHeight - height - PHACT_HEIGHT > 10.0) {
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
				if(!IS_WIDESCREEN) {
					self.phactTopConstraint.constant = 256.0 - (labelHeight - height);
				}
				else {
					self.phactTopConstraint.constant = 344.0 - (labelHeight - height);
				}
			}
			else {
				if(!IS_WIDESCREEN) {
					self.phactTopConstraint.constant = 238.0 - (labelHeight - height);
				}
				else {
					self.phactTopConstraint.constant = 324.0 - (labelHeight - height);
				}
			}
			self.phactHeight.constant += labelHeight - height;
		}
	}
	else {
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
			if(!IS_WIDESCREEN) {
				self.phactTopConstraint.constant = 256.0;
			}
			else {
				self.phactTopConstraint.constant = 344.0;
			}
		}
		else {
			if(!IS_WIDESCREEN) {
				self.phactTopConstraint.constant = 238.0;
			}
			else {
				self.phactTopConstraint.constant = 324.0;
			}
		}
		self.phactHeight.constant = PHACT_HEIGHT;
	}

	[UIView animateWithDuration:0.3 animations:^{
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
	}];
	
}

- (IBAction)closeButtonPressed:(id)sender {
	[self dismissViewControllerAnimated:NO completion:nil];
}
/***
- (IBAction)shareButtonPressed:(id)sender {

    self.phactImage = [self getPhactImage];
	ActivityProvider *activity = [[ActivityProvider alloc] init];
	
	UIImage *imageAtt = self.phactImage;
	NSArray *items = @[activity, imageAtt];

	SaveActivity *saveActivity = [[SaveActivity alloc] init];
	saveActivity.performController = self;

	SendToFriendsActivity *shareWithFriendsActivity = [[SendToFriendsActivity alloc] init];
	shareWithFriendsActivity.performController = self;

	NSArray *acts = @[saveActivity,shareWithFriendsActivity];
	UIActivityViewController *activityView = [[UIActivityViewController alloc]
											   initWithActivityItems:items
											   applicationActivities:acts];
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
		[activityView setExcludedActivityTypes:
		 @[UIActivityTypeAssignToContact,
		   UIActivityTypeCopyToPasteboard,
		   UIActivityTypePrint,
		   UIActivityTypeSaveToCameraRoll,
		   UIActivityTypePostToWeibo,
		   UIActivityTypeMessage]];
	}
	else {
		[activityView setExcludedActivityTypes:
		 @[UIActivityTypeAssignToContact,
		   UIActivityTypeCopyToPasteboard,
		   UIActivityTypePrint,
		   UIActivityTypeSaveToCameraRoll,
		   UIActivityTypePostToWeibo,
		   UIActivityTypeMessage,
		   UIActivityTypePostToFlickr,
		   UIActivityTypePostToVimeo,
		   UIActivityTypePostToTencentWeibo,
		   UIActivityTypeAirDrop]];
	}

	[self presentViewController:activityView animated:YES completion:nil];
	[activityView setCompletionHandler:^(NSString *act, BOOL done)
	 {
		 NSString *serviceMsg = nil;
		 if ( [act isEqualToString:UIActivityTypeMail] ) {
			 if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
				 PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
				 app.window.frame =  CGRectMake(0.0, 20.0, app.window.frame.size.width, app.window.frame.size.height);
				 app.window.bounds = CGRectMake(0.0, 20.0, app.window.frame.size.width, app.window.frame.size.height);
			 }
			 serviceMsg = @"Mail sended!";
		 }
		 if ( [act isEqualToString:UIActivityTypePostToTwitter] )  serviceMsg = @"Post on twitter, ok!";
		 if ( [act isEqualToString:UIActivityTypePostToFacebook] ) serviceMsg = @"Post on facebook, ok!";
///		 if ( [act isEqualToString:@"SaveActivity"] ) serviceMsg = @"Saved!";
///		 if ( [act isEqualToString:@"ShareWithFriendsActivity"] ) serviceMsg = @"Saved!";
		 
		 if ( done )
		 {
			 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:serviceMsg message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			 [alert show];
		 }
	 }];
}
***/

- (IBAction)categoryButtonPressed:(id)sender {
	PopListView *plv = [[PopListView alloc] initWithTitle:@"Choose Label" options:self.categories selectedOptions:self.selectedCategories handler:^(NSArray *indexes) {
		[self.selectedCategories setArray:indexes];
	}];
	[plv showInView:self.view animated:YES];
}

- (IBAction)syncButtonPressed:(id)sender {
	if(self.tempPhilterResults.count <= self.currentIndex)
		return;
	
	float height = self.phactDescription.frame.size.height;
/***
	Phact *phact = [self.tempPhilterResults objectAtIndex:self.currentIndex];

	[self.tempPhilterResults removeObjectAtIndex:self.currentIndex];
	if(self.tempPhilterResults.count == 0) {
		[self.tempPhilterResults setArray:self.philterResults];
		for(int i = 0; i <  self.tempPhilterResults.count; i++) {
			Phact *item = [self.tempPhilterResults objectAtIndex:i];
			if([item.philterName isEqualToString:[phact.philterName uppercaseString]]) {
				[self.tempPhilterResults removeObjectAtIndex:i];
				break;
			}
		}
	}

	self.currentIndex = arc4random() % self.tempPhilterResults.count;
***/
	if((self.currentIndex + 1) % self.tempPhilterResults.count == 0) {
		if(self.bCycle) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Intelligence" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phact", nil];
			alert.alertViewStyle = UIAlertViewStylePlainTextInput;
			alert.tag = PHACT_RESULT_ALERT_TAG;
			UITextField *textField = [alert textFieldAtIndex:0];
			textField.font = [UIFont systemFontOfSize:16.0];
			textField.placeholder = @"What are you Phacting?";
			textField.keyboardType = UIKeyboardTypeDefault;
			[alert show];
			
			self.bCycle = NO;
			return;
		}
		else
			self.bCycle = YES;
	}
	self.currentIndex = (self.currentIndex + 1) % self.tempPhilterResults.count;
	
	[UIView animateWithDuration:0.4 animations:^{
		self.phactView.alpha = 0.0f;
	} completion:^(BOOL finished){
		Phact *phact = [self.tempPhilterResults objectAtIndex:self.currentIndex];
		self.philterIcon.image = [UIImage imageNamed:[self.philterIcons objectForKey:[phact.philterName uppercaseString]]];
		self.philterName.text = [phact.philterName uppercaseString];
		self.phactDescription.text = phact.desc;
		
		if(self.phactHeight.constant != PHACT_HEIGHT) {
			CGSize labelSize = [self.phactDescription.text sizeWithFont:self.phactDescription.font
													  constrainedToSize: CGSizeMake(self.phactDescription.frame.size.width, 400)
														  lineBreakMode:self.phactDescription.lineBreakMode];
			
			CGFloat labelHeight = labelSize.height;
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
				labelHeight = labelSize.height+3.0;
			if(self.phactHeight.constant + labelHeight - height - PHACT_HEIGHT > 10.0) {
				if(labelHeight > height)
					self.phactTopConstraint.constant -= fabsf(labelHeight - height);
				else
					self.phactTopConstraint.constant += height - labelHeight;
				
				
				self.phactHeight.constant += labelHeight - height;
			}
			else {
				
				if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
					if(!IS_WIDESCREEN) { 
						self.phactTopConstraint.constant = 256.0;
					}
					else {
						self.phactTopConstraint.constant = 344.0;
					}
				}
				else {
					if(!IS_WIDESCREEN) {
						self.phactTopConstraint.constant = 238.0;
					}
					else {
						self.phactTopConstraint.constant = 324.0;
					}
				}

				self.phactHeight.constant = PHACT_HEIGHT;
			}
		}

		if(finished) [UIView animateWithDuration:0.4 animations:^{
			self.phactView.alpha = 1.0f;
		} completion:^(BOOL finished){
			if (finished)
			{
			}
		}];
	}];
}

- (void)savePhact:(Phact *)phact completion:(void (^)(BOOL finished))completion{
	[phact savePhact:^(id result, NSError *error) {
		if (!error) {
			Phact *phact = (Phact *)result;
			if(phact)
			{
#if DEBUG_MODE
				NSLog(@"Saved PhactID = %lu",(unsigned long)phact.ident);
#endif
				[self.library saveImage:self.phactImage toAlbum:@"Phact" withCompletionBlock:^(NSError *error) {
					if (error != nil) {
						NSLog(@"Error: %@", [error description]);
					}
				}];
                self.phactId = phact.ident;
                
                completion(YES);
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
            
            completion(NO);
		}
	}];
}

/***
- (void)performSavePhactActivity:(UIActivity *)activity {
///	PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
///	NSString *username = app.customer.email;
///	Phact *phact = [self.tempPhilterResults objectAtIndex:self.currentIndex];
///	UIImage *thumbnailImage = [self.phactImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill
///																   bounds:CGSizeMake(80.0, 120.0)
///													 interpolationQuality:kCGInterpolationMedium];

	// send save phact request to server: self.phactImage, phact.philterName, phact.desc
	Phact *phact = [self.tempPhilterResults objectAtIndex:self.currentIndex];
	NSData *imageData = UIImageJPEGRepresentation(self.backgImage, 1.0f);
	NSData *printedImageData = UIImageJPEGRepresentation(self.phactImage, 1.0f);
	phact.image = [imageData base64EncodedString];
	phact.printedImage = [printedImageData base64EncodedString];
	phact.createdDate = self.phactDate;
	phact.location = self.locationLabel.text;
	
    [self savePhact:phact completion:nil];

	[activity activityDidFinish:NO];
}

- (void)performSendPhactToFriendsActivity:(UIActivity *)activity {
    [self friendsButtonPressed:nil];
	[activity activityDidFinish:NO];
}
***/

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, [[UIScreen mainScreen] scale]);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return img;
}

- (UIImage *)getPhactImage {
	if(self.phactHeight.constant == PHACT_HEIGHT) {
		float height = self.phactDescription.frame.size.height;
		CGSize labelSize = [self.phactDescription.text sizeWithFont:self.phactDescription.font
												  constrainedToSize: CGSizeMake(self.phactDescription.frame.size.width, 400)
													  lineBreakMode:self.phactDescription.lineBreakMode];
        
        CGFloat labelHeight = labelSize.height;
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
			labelHeight = labelSize.height+3.0;

		if(self.phactHeight.constant + labelHeight - height - PHACT_HEIGHT > 10.0) {
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
				if(!IS_WIDESCREEN) {
					self.phactTopConstraint.constant = 256.0 - (labelHeight - height);
				}
				else {
					self.phactTopConstraint.constant = 344.0 - (labelHeight - height);
				}
			}
			else {
				if(!IS_WIDESCREEN) {
					self.phactTopConstraint.constant = 238.0 - (labelHeight - height);
				}
				else {
					self.phactTopConstraint.constant = 324.0 - (labelHeight - height);
				}
			}
			self.phactHeight.constant += labelHeight - height;
		}
	}
	//	[UIView animateWithDuration:0.2 animations:^{
	[self.view layoutIfNeeded];
	//	} completion:^(BOOL finished) {
	self.topToolbar.hidden = YES;
	self.refreshButton.hidden = YES;
	self.categoriesButton.hidden = YES;
	self.locationIcon.hidden = YES;
	self.locationLabel.hidden = YES;
	self.okButton.hidden = YES;
	self.searchButton.hidden = YES;
	
	UIImage *image = [self imageWithView:self.view];
	
	self.topToolbar.hidden = NO;
	self.refreshButton.hidden = NO;
	self.categoriesButton.hidden = NO;
	self.locationIcon.hidden = NO;
	self.locationLabel.hidden = NO;
	self.okButton.hidden = NO;
	self.searchButton.hidden = NO;
	//	}];
	
	return image;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ((alertView.tag == PHACT_RESULT_ALERT_TAG) || (alertView.tag == PHACT_RESULT_ALERT_TAG1)) {
		if (buttonIndex == 1) {
			if (self.loadingIndicator.hidden)
			{
				self.transparentView.hidden = NO;
				self.savedView.hidden = NO;
				[self.loadingIndicator startAnimating];
			}

            NSString *text = [alertView textFieldAtIndex:0].text;
			[Phacts searchByBestGuess:text location:self.locInfo onCompletion:^(id result, NSError *error) {
				[self.loadingIndicator stopAnimating];
				self.transparentView.hidden = YES;
				self.savedView.hidden = YES;
				self.sentRequest = YES;
				
				if (!error) {
					
					self.refreshButton.hidden = NO;
					self.categoriesButton.hidden = NO;
					self.locationIcon.hidden = NO;
					self.locationLabel.hidden = NO;
					self.okButton.hidden = NO;
					self.closeButton.hidden = NO;
					self.searchButton.hidden = NO;
					
					Phacts *phacts = (Phacts *)result;
					if(phacts)
					{
						if(phacts.phacts)
						{
							[self.philterResults setArray:phacts.phacts];
							[self.tempPhilterResults setArray:phacts.phacts];
						}
						
///						self.currentIndex = arc4random() % self.philterResults.count;
						self.currentIndex = 0;
						self.bCycle = YES;
						
						Phact *phact = [self.philterResults objectAtIndex:self.currentIndex];
						self.philterIcon.image = [UIImage imageNamed:[self.philterIcons objectForKey:[phact.philterName uppercaseString]]];
						self.philterName.text = [phact.philterName uppercaseString];
						self.phactDescription.text = phact.desc;
						///                    self.placesLabel.text = ([phacts.geolocation isKindOfClass:[NSNull class]]) ? @"" : phacts.geolocation;
						
						NSDate *now = [NSDate date];
						self.phactDate = [now timeIntervalSince1970];
#if DEBUG_MODE
						for(int i = 0; i < phacts.phacts.count; i++) {
							Phact *ph = [phacts.phacts objectAtIndex:i];
							NSLog(@"description length = %lu",(unsigned long)[ph.desc length]);
						}
#endif
					}
///					[self showInfoScreen];
				}
				else
				{
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Intelligence" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phact", nil];
					alert.alertViewStyle = UIAlertViewStylePlainTextInput;
					alert.tag = PHACT_RESULT_ALERT_TAG1;
					UITextField *textField = [alert textFieldAtIndex:0];
					textField.font = [UIFont systemFontOfSize:16.0];
					textField.placeholder = @"What are you Phacting?";
					textField.keyboardType = UIKeyboardTypeDefault;
					[alert show];
				}
			}];
			if(self.cameraSourceType) {
				self.locationLabel.text = self.location;
			}
		}
		else {
			if((alertView.tag == PHACT_RESULT_ALERT_TAG1) || (alertView.tag == PHACT_RESULT_ALERT_TAG && [[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]))
///			if(![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"])
				[self dismissViewControllerAnimated:NO completion:nil];
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

@end

