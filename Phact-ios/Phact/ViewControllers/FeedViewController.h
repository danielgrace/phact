//
//  FeedViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/5/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedPaginator.h"
#import "SwipeTableViewCell.h"

@interface FeedViewController : UIViewController<PaginatorDelegate, UIScrollViewDelegate,SwipeTableViewCellDelegate> {
	
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FeedPaginator *feedPaginator;

@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)loadFeedsByCategory:(NSInteger)categoryId;

@end
