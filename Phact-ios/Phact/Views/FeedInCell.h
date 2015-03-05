//
//  UnreadFeedCell.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeTableViewCell.h"

@interface FeedInCell : SwipeTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *phactImage;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *desc;
@property (weak, nonatomic) IBOutlet UILabel *createdDate;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationWidthConstraint;

@property (assign, nonatomic) NSInteger feedId;

@end
