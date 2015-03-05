//
//  PhilterResultsViewController.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/25/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PhilterResultsViewController : UIViewController {
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@property (strong, nonatomic) UIImage *backgImage;
@property (assign, nonatomic) BOOL cameraSourceType;
@property (strong, nonatomic) NSURL *imageURL;
@property (copy, nonatomic)	  NSString *bestGuessContext;
@property (copy, nonatomic)	  NSString *location;
@property (copy, nonatomic)	  NSString *locFullInfo;

//- (void)performSavePhactActivity:(UIActivity *)activity;
//- (void)performSendPhactToFriendsActivity:(UIActivity *)activity;

@end
