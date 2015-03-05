//
//  SettingsViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Customer;

@interface SettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Customer *customer;

@end
