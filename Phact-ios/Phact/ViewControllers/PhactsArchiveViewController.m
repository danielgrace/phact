//
//  PhactsArchiveViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/7/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PhactsArchiveViewController.h"
#import "FeedsTabBarController.h"
#import "PhactAppDelegate.h"
#import "OverlayViewController.h"
#import "PhactViewController.h"
#import "UIView+Animation.h"
#import "AsyncImageCache.h"
#import "UIColor-Expanded.h"
#import "PhactCell.h"
#import "Phacts.h"
#import "Phact.h"

@interface PhactsArchiveViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTopLayoutConstraint;
@property (strong, nonatomic) UIBarButtonItem *tagButtonItem;
@property (strong, nonatomic) UIBarButtonItem *menuButtonItem;

@property (strong, nonatomic) NSMutableArray *checkedPhactIds;
@property (strong, nonatomic) Phacts *phacts;
@property (assign, nonatomic) NSInteger categoryId;

@end

@implementation PhactsArchiveViewController

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
    
	self.infoView.image = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"no_phacts")];
    self.categoryId = 0;
    
    self.checkedPhactIds = [NSMutableArray array];
    
	if(self.mode == 0) {
		UIImage *tagButtonImage = [UIImage imageNamed:@"icon_phact_tag.png"];
		UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[tagButton setImage:tagButtonImage forState:UIControlStateNormal];
		tagButton.bounds = CGRectMake(0, 0, 40, 44);
		[tagButton addTarget:self action:@selector(tagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		self.tagButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tagButton];
		self.tagButtonItem.width = 0;
		
		FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
		if (feedsTabBarController) {
			UIButton *menuButton = feedsTabBarController.menuButton;
			self.menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
			self.menuButtonItem.width = 0;
			
			feedsTabBarController.selectedPhactIds = self.checkedPhactIds;
		}
	}
	else {
		UIImage *backButtonImage = [UIImage imageNamed:@"icon_back"];
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton setImage:backButtonImage forState:UIControlStateNormal];
		backButton.bounds = CGRectMake(0, 0, 40, 44);
		[backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
		backButtonItem.width = 0;
		self.navigationItem.leftBarButtonItem = backButtonItem;
	}
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.infoTopLayoutConstraint.constant = 64;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if(self.mode == 0) {
		UIImage *cameraButtonImage = [UIImage imageNamed:@"icon_camera_feed"];
		UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
		cameraButton.bounds = CGRectMake(0, 0, 40, 44);
		[cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
		cameraButtonItem.width = 0;
		self.navigationItem.rightBarButtonItem = cameraButtonItem;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if(self.mode == 0) {
		self.navigationItem.leftBarButtonItem = self.menuButtonItem;
	}
}

- (void)backButtonPressed:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)tagButtonPressed:(id)sender {
    FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
    feedsTabBarController.selectedPhactIds = self.checkedPhactIds;
    [feedsTabBarController showLeftSidebarAnimated:YES];
}

- (void)loadPhactsByCategory:(NSInteger)categoryId categoryName:(NSString *)categoryName
{
    self.categoryId = categoryId;
    [self loadPhacts:categoryName];
}

- (void) loadPhacts:(NSString *)categoryName
{    
    self.navigationItem.title = [categoryName uppercaseString];
    [self.checkedPhactIds removeAllObjects];
    
	self.infoView.hidden = YES;
    if (self.loadingIndicator.hidden)
    {
        [self.navigationController.view addSubview: self.transparentView];
        [self.loadingIndicator startAnimating];
    }
    [Phacts loadPhactsByCategory:self.categoryId onCompletion:^(id result, NSError *error) {
        
        [self.transparentView removeFromSuperview];
        [self.loadingIndicator stopAnimating];
        
        if (!error) {
            
            self.phacts = (Phacts *)result;
            if(self.phacts)
            {
#if DEBUG_MODE
                for(int i = 0; i < self.phacts.phacts.count; i++) {
                    Phact *ph = [self.phacts.phacts objectAtIndex:i];
                    NSLog(@"id = %lu",(unsigned long)ph.ident);
                    NSLog(@"philter = %@",ph.philterName);
                    NSLog(@"description = %@",ph.desc;
                    NSLog(@"photo = %@",ph.image);
                    NSLog(@"image = %@",ph.printedImage);
                    NSLog(@"date = %f",ph.createdDate);
                    NSLog(@"location = %@",ph.location);
                }
#endif
                
				self.infoView.hidden = YES;
                [self.collectionView reloadData];
            }
        }
        else
        {
            self.phacts = nil;
			self.infoView.hidden = NO;
            [self.collectionView reloadData];
        }
    }];
}

- (void)loadOwnPhacts
{
    self.navigationItem.title = @"PHACTS";
    
	self.infoView.hidden = YES;
    if (self.loadingIndicator.hidden)
    {
        [self.navigationController.view addSubview: self.transparentView];
        [self.loadingIndicator startAnimating];
    }
    [Phacts loadOwnPhacts:^(id result, NSError *error) {
        
        [self.transparentView removeFromSuperview];
        [self.loadingIndicator stopAnimating];
        
        if (!error) {
            
            self.phacts = (Phacts *)result;
            if(self.phacts)
            {
#if DEBUG_MODE
                for(int i = 0; i < self.phacts.phacts.count; i++) {
                    Phact *ph = [self.phacts.phacts objectAtIndex:i];
                    NSLog(@"id = %lu",(unsigned long)ph.ident);
                    NSLog(@"philter = %@",ph.philterName);
                    NSLog(@"description = %@",ph.desc);
                    NSLog(@"photo = %@",ph.image);
                    NSLog(@"image = %@",ph.printedImage);
                    NSLog(@"date = %f",ph.createdDate);
                    NSLog(@"location = %@",ph.location);
                }
#endif
				self.infoView.hidden = YES;
                [self.collectionView reloadData];
            }
        }
        else
        {
            self.phacts = nil;
			self.infoView.hidden = NO;
            [self.collectionView reloadData];
        }
    }];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        Phact *phact = [self.phacts.phacts objectAtIndex:indexPath.row];
        
        if([self.checkedPhactIds  containsObject:@(phact.ident)])
            [self.checkedPhactIds removeObject:@(phact.ident)];
        else
            [self.checkedPhactIds addObject:@(phact.ident)];
        
        if(([self.checkedPhactIds count] > 0))
            self.navigationItem.leftBarButtonItem = self.tagButtonItem;
        else
            self.navigationItem.leftBarButtonItem = self.menuButtonItem;
            
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {

	return [self.phacts.phacts count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhactCell *cell = (PhactCell*)[cv dequeueReusableCellWithReuseIdentifier:@"PhactCell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    Phact *phact = [self.phacts.phacts objectAtIndex:indexPath.row];
    
    UIImage *image = [self.checkedPhactIds  containsObject:@(phact.ident)] ? [UIImage imageNamed:@"archive_checked.png"] : [UIImage imageNamed:@"archive_unchecked.png"];

    [cell.checkButton setBackgroundImage:image forState:UIControlStateNormal];
    [cell.checkButton addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor colorWithRed:197.0/255.0 green:197.0/255.0 blue:197.0/255.0 alpha:1].CGColor;
    
    [cell.deleteButton setHidden:YES];
    
    cell.colorButton1.backgroundColor = [UIColor clearColor];
    cell.colorButton2.backgroundColor = [UIColor clearColor];
    cell.colorButton3.backgroundColor = [UIColor clearColor];
    cell.colorButton4.backgroundColor = [UIColor clearColor];
    cell.colorButton5.backgroundColor = [UIColor clearColor];

	if(self.mode == 0)
		cell.checkButton.hidden = NO;
	else
		cell.checkButton.hidden = YES;

    cell.phactImage.image = nil;
    if([phact.image length] > 0)
    {
        [[AsyncImageCache mainCache] retrieveImageWithURL:phact.image callback:^(UIImage *result, NSError *error, BOOL cached) {
			if (!error && [result isKindOfClass:[UIImage class]]) {
				cell.phactImage.image = result;
			}
			else {
				cell.phactImage.image = nil;
			}
            NSArray *colorArray = phact.colors;
            if(colorArray && [colorArray count] > 0)
            {
                cell.colorButton1.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:0]];
                if([colorArray count] > 1)
                    cell.colorButton2.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:1]];
                if([colorArray count] > 2)
                    cell.colorButton3.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:2]];
                if([colorArray count] > 3)
                    cell.colorButton4.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:3]];
                if([colorArray count] > 4)
                    cell.colorButton5.backgroundColor = [UIColor colorWithHexString:[colorArray objectAtIndex:4]];
            }
         }];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return [[UICollectionReusableView alloc] init];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(145, 145);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    Phact *phact = [self.phacts.phacts objectAtIndex:indexPath.row];
    PhactViewController *phactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhactViewController"];
	phactViewController.phactId = phact.ident;
    phactViewController.phactImageURL = phact.printedImage;
    [self.navigationController pushViewController:phactViewController animated:YES];
    [self.collectionView reloadData];
}


-(void)deleteButtonClick:(PhactCell *)cell{

    [self.collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        Phact *phact = [self.phacts.phacts objectAtIndex:indexPath.row];
        
        [Phact deletePhact:phact.ident onCompletion:^(id result, NSError *error) {
            if (!error) {
                [self.phacts.phacts removeObjectAtIndex:indexPath.row];
                [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
				
				if(self.phacts.phacts.count == 0)
					self.infoView.hidden = NO;
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
        
    } completion:^(BOOL finished) {
        
    }];
}


-(void)activateDeletionMode:(PhactCell *)cell{
    
    for(PhactCell *cell1 in self.collectionView.visibleCells){
        [cell1.deleteButton setHidden:YES];
    }
    [cell.deleteButton setHidden:NO];
}

@end
