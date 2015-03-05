//
//  ChangePasswordViewController.h
//  Phact
//
//  Created by Tigran Kirakosyan on 12/6/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Customer;

@interface ChangePasswordViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) Customer *customer;
@property (assign, nonatomic) BOOL isResettingPassword;
@end
