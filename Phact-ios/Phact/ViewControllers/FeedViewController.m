//
//  FeedViewController.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/5/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "FeedViewController.h"
#import "PhactAppDelegate.h"
#import "OverlayViewController.h"
#import "UIView+Animation.h"
#import "FeedOutCell.h"
#import "FeedInCell.h"
#import "Feed.h"
#import "Phacts.h"
#import "AsyncImageCache.h"
#import "PhactViewController.h"
#import "FeedsTabBarController.h"

#define CELL_HEIGHT             100

@interface FeedViewController ()
@property (weak, nonatomic) IBOutlet UIView *transparentView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *infoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoTopLayoutConstraint;
@property (strong, nonatomic) NSMutableArray *markAsReadList;

- (void)cameraButtonPressed:(id)sender;
- (void)loadFeeds;

@end

@implementation FeedViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
		_markAsReadList = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"PHLOW";
	self.infoView.image = [UIImage imageNamed:ASSET_BY_SCREEN_HEIGHT(@"no_feeds")];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.topLayoutConstraint.constant = 64;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        self.infoTopLayoutConstraint.constant = 64;

    [self setupTableViewFooter];
    
	if (self.loadingIndicator.hidden)
	{
		self.transparentView.hidden = NO;
		[self.loadingIndicator startAnimating];
	}
    // set up the paginator
    self.feedPaginator = [[FeedPaginator alloc] initWithPageSize:10 delegate:self];
    [self.feedPaginator fetchFirstPage];
    
    // If you set the seperator inset on iOS 6 you get a NSInvalidArgumentException...weird
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // Makes the horizontal row seperator stretch the entire length of the table view
    }

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	UIImage *cameraButtonImage = [UIImage imageNamed:@"icon_camera_feed"];
	UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
	cameraButton.bounds = CGRectMake(0, 0, 40, 44);
	[cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
	cameraButtonItem.width = 0;
	self.navigationItem.rightBarButtonItem = cameraButtonItem;
/*
	FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
	if (feedsTabBarController) {
		UIButton *menuButton = feedsTabBarController.menuButton;
		UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
		menuButtonItem.width = 0;
		self.navigationItem.leftBarButtonItem = menuButtonItem;
	}
*/ 
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
	if (feedsTabBarController) {
		UIButton *menuButton = feedsTabBarController.menuButton;
		UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
		menuButtonItem.width = 0;
		self.navigationItem.leftBarButtonItem = menuButtonItem;
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	self.navigationItem.rightBarButtonItem = nil;
	
	if(self.markAsReadList.count > 0) {
		[Phacts markPhactsAsRead:self.markAsReadList onCompletion:^(id result, NSError *error) {
			if (!error) {
//				NSLog(@"markPhactsAsRead : result = %d",[result intValue]);
				PhactAppDelegate *app = (PhactAppDelegate *)[UIApplication sharedApplication].delegate;
				[app updateNotificationBadge];
				[self.markAsReadList removeAllObjects];
			}
			else
			{
				NSLog(@"markPhactsAsRead Error = %@",[error localizedDescription]);
			}
		}];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)loadFeeds {
	self.infoView.hidden = YES;
	if (self.loadingIndicator.hidden)
	{
		self.transparentView.hidden = NO;
		[self.loadingIndicator startAnimating];
	}
    [self.feedPaginator fetchFirstPage];
}

- (void)loadFeedsByCategory:(NSInteger)categoryId
{
    self.feedPaginator.categoryId = categoryId;
    [self loadFeeds];
}

#pragma mark - Actions

- (void)fetchNextPage
{
    [self.feedPaginator fetchNextPage];
	
	[self updateTableViewFooter:NO];
	
    [self.activityIndicator startAnimating];
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.tableView.tableFooterView = footerView;
}

- (void)updateTableViewFooter:(BOOL)lastPage
{
	if(lastPage) {
        self.footerLabel.text = @"";
	}
	else {
		if ([self.feedPaginator.results count] != 0)
		{
			self.footerLabel.text = @"Loading More";
		} else
		{
			self.footerLabel.text = @"";
		}
	}
    
    [self.footerLabel setNeedsDisplay];
}

- (void)clearButtonPressed:(id)sender
{
    [self.feedPaginator fetchFirstPage];
}

#pragma mark - Paginator delegate methods

- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
	[self.loadingIndicator stopAnimating];
	self.transparentView.hidden = YES;
	
    // update tableview footer
    [self updateTableViewFooter:YES];
    [self.activityIndicator stopAnimating];
	
	if([self.feedPaginator.results count] == 0) {
		self.infoView.hidden = NO;
		return;
	}
	self.infoView.hidden = YES;
    
    // update tableview content
    // easy way : call [tableView reloadData];
    // nicer way : use insertRowsAtIndexPaths:withAnimation:
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSInteger i = [self.feedPaginator.results count] - [results count];
    
    for(int j = 0; j < results.count; j++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
/*
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
*/
	[self.tableView reloadData];
}

- (void)paginatorDidReset:(id)paginator
{
    [self.tableView reloadData];
    [self updateTableViewFooter:NO];
}

- (void)paginatorDidFailToRespond:(id)paginator
{
    // Todo
}

#pragma mark - TableView delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId1 = @"FeedOutCell";
    static NSString *cellId2 = @"FeedInCell";
    Feed *feed = [self.feedPaginator.results objectAtIndex:indexPath.row];
	
	SwipeTableViewCell *cell;
	FeedOutCell *cell1;
	FeedInCell *cell2;

	if(([feed.direction isEqualToString:@"out"])) {
		cell1 = (FeedOutCell *)[tableView dequeueReusableCellWithIdentifier:cellId1 forIndexPath:indexPath];
		cell = cell1;
	}
	else {
		cell2 = (FeedInCell *)[tableView dequeueReusableCellWithIdentifier:cellId2 forIndexPath:indexPath];
		cell = cell2;
	}
    
    SwipeTableViewCell __weak *weakCell = cell;
    
    [cell setAppearanceWithBlock:^{
        weakCell.rightUtilityButtons = [self rightButtons];
        weakCell.delegate = self;
        weakCell.containingTableView = tableView;
    } force:NO];
    
    [cell setCellHeight:cell.frame.size.height];

	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.clipsToBounds = YES;
    
    NSString *username = [NSString stringWithFormat:@"%@",([feed.direction isEqualToString:@"in"]) ? feed.usernameFrom : feed.usernameTo];
    
	if(([feed.direction isEqualToString:@"out"])) {
		cell1.feedId = feed.feedId;
		cell1.friendName.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
		cell1.friendName.text = username;
		cell1.desc.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:13.0];
		cell1.desc.text = feed.desc;
		cell1.location.text = feed.location;
		cell1.location.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:12.0];
		cell1.createdDate.text = feed.sharedDate;
		cell1.createdDate.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:13.0];
		
		if(feed.markAsRead) {
			cell1.markUnreadIcon.image = [UIImage imageNamed:@"icon_seen.png"];
		}
		else {
			cell1.markUnreadIcon.image = [UIImage imageNamed:@"icon_notseen.png"];
		}
			cell1.accessoryType = UITableViewCellAccessoryNone;
			
	}
	else {		
		if(feed.markAsRead) {
			cell2.contentView.backgroundColor = [UIColor clearColor];
		}
		else {
			cell2.contentView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1];
		}

		cell2.feedId = feed.phactId;
		cell2.friendName.text = username;
		cell2.friendName.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
		cell2.desc.text = feed.desc;
		cell2.desc.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:13.0];
		cell2.location.text = feed.location;
		cell2.location.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:12.0];
		
		CGSize labelSize = [feed.location sizeWithFont:cell2.location.font
												  constrainedToSize: CGSizeMake(150.0, cell2.location.frame.size.height)
													  lineBreakMode:cell2.location.lineBreakMode];
		cell2.locationWidthConstraint.constant = labelSize.width;

		cell2.createdDate.text = feed.sharedDate;
		cell2.createdDate.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:13.0];
		cell2.accessoryType = UITableViewCellAccessoryNone;
	}
    
    if([feed.phactImageURL length] > 0)
    {
        [[AsyncImageCache mainCache] retrieveImageWithURL:feed.phactImageURL callback:^(UIImage *result, NSError *error, BOOL cached) {
			UIImage *avatar = nil;
			if ([result isKindOfClass:[UIImage class]]) {
				avatar = result;
			}
			else {
				avatar = [UIImage imageNamed:@"icon.png"];
			}
			if(([feed.direction isEqualToString:@"out"])) {
				cell1.phactImage.image = avatar;
				cell1.phactImage.clipsToBounds = YES;
			}
			else {
				cell2.phactImage.image = avatar;
				cell2.phactImage.clipsToBounds = YES;
			}
        }];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feedPaginator.results count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

    Feed *feed = [self.feedPaginator.results objectAtIndex:indexPath.row];
	if(([feed.direction isEqualToString:@"in"])) {
		FeedInCell *cell = (FeedInCell *)[tableView cellForRowAtIndexPath:indexPath];
		
		if(!feed.markAsRead) {
			feed.markAsRead = YES;
			cell.contentView.backgroundColor = [UIColor clearColor];
			
			NSInteger index = [self.markAsReadList indexOfObject:[NSNumber numberWithInteger:feed.feedId]];
			if(index == NSNotFound)
				[self.markAsReadList addObject:[NSNumber numberWithInteger:feed.feedId]];
			
			[tableView reloadData];
		}
	}
	
	PhactViewController *phactViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhactViewController"];
	phactViewController.phactId = feed.phactId;
	phactViewController.phactImageURL = feed.phactPrintedImageURL;
	[self.navigationController pushViewController:phactViewController animated:YES];
}

- (void)swipeableTableViewCell:(SwipeTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    Feed *feed = [self.feedPaginator.results objectAtIndex:cellIndexPath.row];

    switch (index) {
        case 0:
        {
            // Select category button was pressed
						
            [cell hideUtilityButtonsAnimated:YES];
			
			FeedsTabBarController *feedsTabBarController = [FeedsTabBarController findFromViewController:self];
            NSMutableArray *phactIds = [NSMutableArray arrayWithObject:[NSNumber numberWithInteger:feed.phactId]];
			feedsTabBarController.selectedPhactIds = phactIds;
			[feedsTabBarController showLeftSidebarAnimated:YES];
			
			UIView *selectedView = cell;
			CGPoint center = [selectedView.superview convertPoint:selectedView.center toView:nil];
			selectedView.bounds = CGRectMake(0.0, 0.0, cell.bounds.size.width, cell.bounds.size.height);
			if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
				selectedView.center = center;
			else
				selectedView.center = CGPointMake(center.x, center.y - 20.0);
	
			selectedView.tag = 1000;
			
			[UIView animateWithDuration:0.8 animations:^{
				[feedsTabBarController.view addSubview:selectedView];
				selectedView.center = CGPointMake(selectedView.center.x - 50.0, selectedView.center.y);
			}];
			
			selectedView.userInteractionEnabled = NO;
            break;
        }
        case 1:
        {
            // Delete button was pressed
            [Feed hideFromFeed:feed.feedId onCompletion:^(id result, NSError *error) {
                if (!error) {
                    [self.feedPaginator.results removeObjectAtIndex:cellIndexPath.row];
                    [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
					
					if(self.feedPaginator.results.count == 0)
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
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SwipeTableViewCell *)cell {
    return YES;
}


- (NSArray *)rightButtons
{   
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
                                                icon:[UIImage imageNamed:@"swipe_add.png"]];
    [rightUtilityButtons addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0]
                                                icon:[UIImage imageNamed:@"swipe_delete.png"]];
    
    return rightUtilityButtons;
    
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        // ask next page only if we haven't reached last page
        if(![self.feedPaginator reachedLastPage])
        {
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}

@end
