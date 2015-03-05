//
//  CaptureSessionManager.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

@interface CaptureSessionManager : NSObject {

}

@property (strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIImage *stillImage;
@property (nonatomic, assign) float cameraZoomFactor;

- (void)addVideoPreviewLayer;
- (void)addStillImageOutput;
- (void)captureStillImage;
- (void)addVideoInputFrontCamera:(BOOL)front;
- (void)toggleCamera:(BOOL)front;
- (void)toggleFlashlight:(BOOL)flash;
- (BOOL)hasFlash;
- (void)addFocusMode:(CGPoint) aPoint;
- (void)setZoomFactor:(float)zoom;

@end
