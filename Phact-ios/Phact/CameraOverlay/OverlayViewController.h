//
//  OverlayViewController.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "ShootViewController.h"

@interface OverlayViewController : UIViewController <CapturePictureProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate> {
	CGFloat beginGestureScale;
	CGFloat effectiveScale;
}
@property (retain) CaptureSessionManager *captureManager;

- (void)shootPicture;
- (void)changeCameraSelection;
- (void)toggleFlash;

@end
