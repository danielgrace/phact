//
//  PhilterSettingsViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/9/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhilterSettingsViewController.h"
#import "Customer.h"
#import "Philters.h"
#import "PhilterCell.h"
#import "CollectionHeaderView.h"
#import "UIViewController+Animation.h"

#define SECTION_COUNT 2

@interface PhilterSettingsViewController ()

@property(nonatomic, assign) BOOL needSyncPhilters;
@property(nonatomic, strong) NSMutableArray *activePhilters;
@property(nonatomic, strong) NSMutableArray *inactivePhilters;
@property(nonatomic, strong) NSDictionary *philterIcons;
@property(nonatomic, strong) NSMutableArray *sections;

@end

@implementation PhilterSettingsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Philters.plist"];
		NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:resourcePath];
		_philterIcons = [[NSDictionary alloc] initWithDictionary:[dict objectForKey:@"PhilterIcons"]];
		
		_activePhilters = [[NSMutableArray alloc] initWithCapacity:3];
		_inactivePhilters = [[NSMutableArray alloc] initWithCapacity:3];
        
        self.sections = [[NSMutableArray alloc] initWithCapacity:SECTION_COUNT];
    }
    return self;
}

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
    
    self.navigationItem.title = @"PHILTER SETTINGS";
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
	backButton.bounds = CGRectMake(0, 0, 40, 44);
	[backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	backButtonItem.width = 0;
	self.navigationItem.leftBarButtonItem = backButtonItem;
    
    [self.collectionView setDraggable:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	// synchronize philters with server
	if(self.needSyncPhilters) {
		[self.customer.philters updatePhiltersWithCustomer:self.customer.customerId onCompletion:^(id methodResults, NSError *error) {
			if(error) {
                
			}
			else {
				self.needSyncPhilters = NO;
			}
		}];
	}
}

- (void)setCustomer:(Customer *)customer {
    if (_customer) {
		[self removeCustomerObservers:_customer];
	}
	_customer = customer;
	if (_customer) {
		[self addCustomerObservers:_customer];
    }
}

- (void)addCustomerObservers:(Customer *)customer {
	[_customer addObserver:self forKeyPath:@"philters" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:NULL];
}

- (void)removeCustomerObservers:(Customer *)customer {
	[_customer removeObserver:self forKeyPath:@"philters"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.customer) {
		id newValue = [change objectForKey:NSKeyValueChangeNewKey];
		if ([keyPath isEqualToString:@"philters"]) {
			Philters *philters = newValue;
			[self.activePhilters setArray:philters.activePhilters];
			[self.inactivePhilters setArray:philters.inActivePhilters];
			[self.sections removeAllObjects];
            [self.sections addObject:self.activePhilters];
            [self.sections addObject:self.inactivePhilters];
//			[self.collectionView reloadData];
		}
	}
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        
        CollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        NSString *title = nil;
        if(indexPath.section == 0)
            title = [[NSString alloc]initWithFormat:@"Active Philters"];
        else
            title = [NSString stringWithFormat:@"Drag here to deactivate"];

        headerView.title.text = title;
        headerView.title.textColor = [UIColor colorWithRed:103.0/255.0 green:103.0/255.0 blue:103.0/255.0 alpha:1.0];
        headerView.title.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
        //       UIImage *headerImage = [UIImage imageNamed:@"header_banner.png"];
        //        headerView.backgroundImage.image = headerImage;
       
        return headerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return CGSizeMake(0,0);
    else if ((section == 1) && ([self.inactivePhilters count] > 0))
        return CGSizeMake(0,0);
    else
        return CGSizeMake(280,35);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.sections objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhilterCell *cell = (PhilterCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"PhilterCell" forIndexPath:indexPath];
    NSMutableArray *data = [self.sections objectAtIndex:indexPath.section];
    
    NSString *title = [data objectAtIndex:indexPath.item];
    cell.title.text = title;
    cell.title.textColor = [UIColor whiteColor];
    cell.title.font = [UIFont fontWithName:@"NewsGothic_Lights" size:18.0];
    
    UIImage *image = nil;
    
    NSString *imageName = [self.philterIcons objectForKey:title];
	if(imageName == nil) {
		image = [UIImage imageNamed:@"philter_icon_people.png"];
	}
	else {
		image = [UIImage imageNamed:imageName];
    }
    
    if(indexPath.section == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:120.0/255.0 blue:0 alpha:1];
    }
    else
    {
        cell.backgroundColor = [UIColor colorWithRed:206.0/255.0 green:206.0/255.0 blue:206.0/255.0 alpha:1];
    }

    cell.icon.image = image;
//	cell.backgColor = cell.backgroundColor;
	cell.highlightColor = [UIColor grayColor];
    
    return cell;
}

- (BOOL)collectionView:(CollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if((indexPath.section == 0) && [[self.sections objectAtIndex:indexPath.section] count] == 1)
          return NO;

    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (BOOL)collectionView:(CollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    BOOL retValue = NO;
    NSMutableArray *data1 = [self.sections objectAtIndex:fromIndexPath.section];
    NSMutableArray *data2 = [self.sections objectAtIndex:toIndexPath.section];
    NSString *index = [data1 objectAtIndex:fromIndexPath.item];
    
    [data1 removeObjectAtIndex:fromIndexPath.item];
    [data2 insertObject:index atIndex:toIndexPath.item];

    if(toIndexPath.section == 0)
    {
        if([[self.sections objectAtIndex:toIndexPath.section] count] > 3)
        {
            NSString *removeIndex = [data2 lastObject];
            [data2 removeLastObject];
            [data1 insertObject:removeIndex atIndex:0];
            retValue = YES;
        }
    }
    
    [self.activePhilters setArray:[self.sections objectAtIndex:0]];
    [self.inactivePhilters setArray:[self.sections objectAtIndex:1]];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.activePhilters forKey:@"TopPhilters"];
	[[NSUserDefaults standardUserDefaults] setObject:self.inactivePhilters forKey:@"MorePhilters"];
	[[NSUserDefaults standardUserDefaults] synchronize];

    [self.customer.philters.activePhilters setArray:self.activePhilters];
	[self.customer.philters.inActivePhilters setArray:self.inactivePhilters];
	
	self.needSyncPhilters = YES;

    return retValue;
}

- (void)dealloc {
	if (_customer) {
		[self removeCustomerObservers:_customer];
	}
}

- (void)backButtonPressed:(id)sender {
    [self popViewController:^(){
    }];
}


@end
