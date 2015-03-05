//
//  OverlayViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "OverlayViewController.h"
#import "SettingsViewController.h"
#import "PhilterSettingsViewController.h"
#import "PhactAppDelegate.h"
#import "PhilterResultsViewController.h"
#import "FeedViewController.h"
#import "UIView+Animation.h"
#import "UIViewController+Animation.h"
#import "CameraFocusSquare.h"
#import "FeedsTabBarController.h"
#import "ProfileViewController.h"
#import "ImageUtils.h"

@interface OverlayViewController ()

@property(nonatomic) BOOL isFrontCameraSelected;
@property(nonatomic) BOOL isFlashModeSelected;
@property(nonatomic) BOOL cameraSourceType;

@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *shootButton;
@property (weak, nonatomic) IBOutlet UIButton *feedButton;
@property (weak, nonatomic) IBOutlet UIButton *galleryButton;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (strong, nonatomic) CameraFocusSquare* camFocus;
@property (strong, nonatomic) NSURL *imageURL;

- (IBAction)flashButtonPressed:(id)sender;
- (IBAction)shootButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;
- (IBAction)feedButtonPressed:(id)sender;

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

@end

@implementation OverlayViewController

@synthesize captureManager;

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
    self.isFrontCameraSelected = NO;
    self.isFlashModeSelected = NO;
    
    [super viewDidLoad];
	
	self.shootButton.exclusiveTouch = YES;

	[self setCaptureManager:[[CaptureSessionManager alloc] init]];
    
	[[self captureManager] addVideoInputFrontCamera:self.isFrontCameraSelected]; // set to YES for Front Camera, No for Back camera
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double screenWidth = screenRect.size.width;
    double screenHeight = screenRect.size.height;

    [[self captureManager] addFocusMode:CGPointMake(screenWidth/2, screenHeight/2)];
    
    [[self captureManager] addStillImageOutput];
    
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
    [[[self captureManager] previewLayer] setBounds:layerRect];
    [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];

//    [self.view bringSubviewToFront:self.flashButton];

    if([[self captureManager] hasFlash])
        [self.view bringSubviewToFront:self.flashButton];
    else
        self.flashButton.hidden = YES;

    [self.view bringSubviewToFront:self.galleryButton];
    [self.view bringSubviewToFront:self.settingsButton];
    [self.view bringSubviewToFront:self.shootButton];
    [self.view bringSubviewToFront:self.feedButton];
    [self.view bringSubviewToFront:self.profileButton];
	
	effectiveScale = 1.0;
	
	UIPinchGestureRecognizer *recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchFrom:)];
	recognizer.delegate = self;
	[self.view addGestureRecognizer:recognizer];

	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
	longPressGesture.minimumPressDuration = .050;
	longPressGesture.delegate = self;
	[self.view addGestureRecognizer:longPressGesture];

    _camFocus = [[CameraFocusSquare alloc] initWithImage:[UIImage imageNamed:@"focus_icon.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openShootView) name:kImageCapturedSuccessfully object:nil];
    
	[[captureManager captureSession] startRunning];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double screenWidth = screenRect.size.width;
    double screenHeight = screenRect.size.height;

    [self setCameraFocusOnPosition:CGPointMake(screenWidth/2, screenHeight/2)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) changeCameraSelection
{
    [self.captureManager.captureSession stopRunning];
    
    self.isFrontCameraSelected =  self.isFrontCameraSelected ? NO : YES;
    [[self captureManager] toggleCamera:self.isFrontCameraSelected];

    [self.captureManager.captureSession startRunning];
}

-(void) toggleFlash
{
    self.isFlashModeSelected =  self.isFlashModeSelected ? NO : YES;
    [[self captureManager] toggleFlashlight:self.isFlashModeSelected];
}

- (void)shootPicture{
    [[self captureManager] captureStillImage];
}

-(void)openShootView
{
	self.cameraSourceType = YES;
	self.imageURL = nil;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ShootViewController *shootVC = [storyboard instantiateViewControllerWithIdentifier:@"ShootViewController"];
    shootVC.modalPresentationStyle = UIModalPresentationFullScreen;
    shootVC.delegate = self;
    
    [self presentViewController:shootVC animated:NO completion:nil];
    shootVC.imageView.image = [[self captureManager] stillImage];
}

- (void)saveImageToPhotoAlbum
{
    UIImageWriteToSavedPhotosAlbum([[self captureManager] stillImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (IBAction)flashButtonPressed:(id)sender {
    
    [self toggleFlash];
    
    if (self.isFlashModeSelected)
        [self.flashButton setImage:[UIImage imageNamed:@"icon_flash.png"] forState:UIControlStateNormal];
    else
        [self.flashButton setImage:[UIImage imageNamed:@"icon_no_flash.png"] forState:UIControlStateNormal];
}

- (IBAction)galleryButtonPressed:(id)sender {
    
    [self startMediaBrowserFromViewController: self
                                usingDelegate: self];
}


- (IBAction)shootButtonPressed:(id)sender {
    
    [self shootPicture];
}

- (IBAction)settingsButtonPressed:(id)sender {
    
	PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
///	SettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
	Customer *customer = [app getCustomerProfile];
///	settingsViewController.customer = customer;
    PhilterSettingsViewController *philterSettingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhilterSettingsViewController"];
    philterSettingsViewController.customer = customer;
///	UINavigationController *settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
///    [app.rootViewController pushViewController:settingsNavigationController completion:^(){
///    }];
	UINavigationController *philterSettingsNavigationController = [[UINavigationController alloc] initWithRootViewController:philterSettingsViewController];
    [app.rootViewController pushViewController:philterSettingsNavigationController completion:^(){
    }];
}

- (IBAction)feedButtonPressed:(id)sender {
    PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
    FeedsTabBarController *feedsTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedsTabBarController"];

    [self.view popView:feedsTabBarController.view duration:0.4 completion:^(){
        app.window.rootViewController = feedsTabBarController;
        app.rootViewController = feedsTabBarController;
    }];
}

- (IBAction)profileButtonPressed:(id)sender {
    PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
    FeedsTabBarController *feedsTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedsTabBarController"];
	
	UINavigationController *navController = [feedsTabBarController.viewControllers objectAtIndex:2];
	ProfileViewController *profileViewController = (ProfileViewController *)navController.topViewController;
	profileViewController.customer = app.customer;
	
    [self.view popView:feedsTabBarController.view duration:0.4 completion:^(){
        app.window.rootViewController = feedsTabBarController;
        app.rootViewController = feedsTabBarController;
		
		feedsTabBarController.selectedIndex = 2;
    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didFinishCapturing:(UIImage *)captureImage withBestGuessSearch:(NSString *)searchContext location:(NSString *)location locationFullInfo:(NSString *)locInfo
{
    // start wizard
	UINavigationController *philterResultsNavigationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhilterResultsNavigationController"];
	PhilterResultsViewController *rootController = (PhilterResultsViewController *)philterResultsNavigationViewController.topViewController;
/***
	UIImage *resizedImage = captureImage;
	if(self.cameraSourceType) {
		UIImage *normalizedImage = [ImageUtils normalizedImage:captureImage];
		CGSize size = CGSizeMake(320.0, 480.0);
		if(IS_WIDESCREEN)
			size = CGSizeMake(320.0, 568.0);

		resizedImage = [ImageUtils imageWithImage:normalizedImage scaledToSize:size quality:kCGInterpolationHigh];
	}
***/
	
	rootController.backgImage = captureImage;
	rootController.cameraSourceType = self.cameraSourceType;
	rootController.imageURL = self.imageURL;
	rootController.bestGuessContext = searchContext;
	rootController.location = location;
	rootController.locFullInfo = locInfo;
	
	[self presentViewController:philterResultsNavigationViewController animated:NO completion:^{
	}];
}

-(void) setCameraFocusOnPosition:(CGPoint)point
{
    [[self captureManager] addFocusMode:point];
    
    if (self.camFocus)
    {
        [self.camFocus removeFromSuperview];
    }
    
    [self.camFocus setPos:point];
    [self.view addSubview:self.camFocus];
    [self.camFocus setNeedsDisplay];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelay:1.5];
    [UIView setAnimationDuration:1.5];
    [self.camFocus setAlpha:0.0];
    [UIView commitAnimations];
}


- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary/*UIImagePickerControllerSourceTypeSavedPhotosAlbum*/;
    
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    
    [controller presentViewController: mediaUI animated: YES completion:nil];
    
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
	else {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage* originalImage = nil;
        originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if(originalImage == nil)
        {
            originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        if(originalImage == nil)
        {
            originalImage = [info objectForKey:UIImagePickerControllerCropRect];
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShootViewController *shootVC = [storyboard instantiateViewControllerWithIdentifier:@"ShootViewController"];
        shootVC.modalPresentationStyle = UIModalPresentationFullScreen;
        shootVC.delegate = self;
		
        [self presentViewController:shootVC animated:NO completion:nil];
/***
		shootVC.imageView.contentMode = UIViewContentModeCenter;
		
		NSLog(@"originalImage : %.2f:%.2f",originalImage.size.width,originalImage.size.height);
		CGSize size = CGSizeMake(320.0, 480.0);
		if(IS_WIDESCREEN)
			size = CGSizeMake(320.0, 568.0);
		
		UIImage *normalizedImage = [ImageUtils normalizedImage:originalImage];
		UIImage *resizedImage = [ImageUtils imageWithImage:normalizedImage scaledToSize:size quality:kCGInterpolationHigh];

		NSLog(@"resizedImage : %.2f:%.2f",resizedImage.size.width,resizedImage.size.height);
***/
        shootVC.imageView.image = originalImage;
		self.cameraSourceType = NO;
		self.imageURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    }];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
		beginGestureScale = effectiveScale;
	}
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if ( touch.view == self.view )
		return YES;
	return NO;
}

- (void)didLongPress:(UILongPressGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:gesture.view];
	
	if (gesture.state == UIGestureRecognizerStateBegan){
		[self setCameraFocusOnPosition:touchPoint];
	}
}

- (void)handlePinchFrom:(UIPinchGestureRecognizer *)recognizer {
	AVCaptureVideoPreviewLayer *previewLayer = [self captureManager].previewLayer;
	BOOL allTouchesAreOnThePreviewLayer = YES;
	NSUInteger numTouches = [recognizer numberOfTouches], i;
	for ( i = 0; i < numTouches; ++i ) {
		CGPoint location = [recognizer locationOfTouch:i inView:self.view];
		CGPoint convertedLocation = [previewLayer convertPoint:location fromLayer:previewLayer.superlayer];
		if ( ! [previewLayer containsPoint:convertedLocation] ) {
			allTouchesAreOnThePreviewLayer = NO;
			break;
		}
	}
	
	if ( allTouchesAreOnThePreviewLayer ) {
		effectiveScale = beginGestureScale * recognizer.scale;
		
		if(effectiveScale < 1.0)
			effectiveScale = 1.0;

		if(effectiveScale > 5.0)
			effectiveScale = 5.0;

		[self makeAndApplyAffineTransform];
		[[self captureManager] setZoomFactor:effectiveScale];
	}
}

- (void)makeAndApplyAffineTransform {
	CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
	affineTransform = CGAffineTransformScale(affineTransform, effectiveScale, effectiveScale);
	[CATransaction begin];
	[CATransaction setAnimationDuration:.025];
	[[self captureManager].previewLayer setAffineTransform:affineTransform];
	[CATransaction commit];
}

@end

