//
//  ShootViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/18/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol CapturePictureProtocol <NSObject>

- (void)didFinishCapturing:(UIImage *)captureImage withBestGuessSearch:(NSString *)searchContext location:(NSString *)location locationFullInfo:(NSString *)locInfo;

@end

@interface ShootViewController : UIViewController <UIScrollViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
	NSString *location;
	NSString *locFullInfo;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong)  id<CapturePictureProtocol> delegate;

@end
