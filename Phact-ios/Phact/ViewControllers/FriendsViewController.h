//
//  FriendsViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/14/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class Friends;

typedef enum {
    FindMode_Selection = 0,
    FindMode_View = 1,
} FindMode;

@interface FriendsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,MFMailComposeViewControllerDelegate>

@property (assign, nonatomic) NSInteger phactId;
@property (strong, nonatomic) UIImage *phactImage;
@property (assign, nonatomic) NSInteger mode;
@property (assign, nonatomic) NSInteger layoutType;

@end
