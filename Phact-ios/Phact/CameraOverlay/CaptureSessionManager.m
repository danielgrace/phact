//
//  CaptureSessionManager.m
//  Phact
//
//  Created by Mikayel Gyurjyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>

@interface CaptureSessionManager() {
    AVCaptureDeviceInput *frontFacingCameraDeviceInput;
    AVCaptureDeviceInput *backFacingCameraDeviceInput;
}
@property (retain) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
		_cameraZoomFactor = 1.0;
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoInputFrontCamera:(BOOL)front {
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            else {
                frontCamera = device;
            }
        }
    }
    
    NSError *error = nil;
    frontFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
    backFacingCameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];

    if (front) {
        if (!error) {
            if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
                [[self captureSession] addInput:frontFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add front facing video input");
            }
        }
    } else {
        if (!error) {
            if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
                [[self captureSession] addInput:backFacingCameraDeviceInput];
            } else {
                NSLog(@"Couldn't add back facing video input");
            }
        }
    }
}


-(void) addFocusMode:(CGPoint) aPoint
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    double screenWidth = screenRect.size.width;
    double screenHeight = screenRect.size.height;
    double focus_x = aPoint.x/screenWidth;
    double focus_y = aPoint.y/screenHeight;
    
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] && [device lockForConfiguration:&error]){
        [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        if ([device isFocusPointOfInterestSupported])
            [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];

        if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
            [device setExposureMode:AVCaptureExposureModeAutoExpose];
        }

        [device unlockForConfiguration];
    }
}

-(void)toggleCamera:(BOOL)front
{
    [[self captureSession] beginConfiguration];

    if (front)
    {
        [[self captureSession] removeInput:backFacingCameraDeviceInput];
        if ([[self captureSession] canAddInput:frontFacingCameraDeviceInput]) {
            [[self captureSession] addInput:frontFacingCameraDeviceInput];
        } else {
            NSLog(@"Couldn't add front facing video input");
        }
    } else
    {
        [[self captureSession] removeInput:frontFacingCameraDeviceInput];
        if ([[self captureSession] canAddInput:backFacingCameraDeviceInput]) {
            [[self captureSession] addInput:backFacingCameraDeviceInput];
        } else {
            NSLog(@"Couldn't add back facing video input");
        }
    }
    
    [[self captureSession] commitConfiguration];
}

- (void)addStillImageOutput
{
    [self setStillImageOutput:[[AVCaptureStillImageOutput alloc] init] ];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [[self stillImageOutput] setOutputSettings:outputSettings];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{
    AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) {
            break;
        }
	}
	
	[videoConnection setVideoScaleAndCropFactor:self.cameraZoomFactor];

#if DEBUG_MODE
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
#endif
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection
                                                         completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                             CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                             if (exifAttachments) {
#if DEBUG_MODE
                                                                 NSLog(@"attachements: %@", exifAttachments);
#endif
                                                             } else {
#if DEBUG_MODE
                                                                 NSLog(@"no attachments");
#endif
                                                             }
                                                             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                             UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                             [self setStillImage:image];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                         }];
}


- (void)toggleFlashlight:(BOOL) flash
{
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (flash) {
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (BOOL) hasFlash
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return [device hasFlash];
}

- (void)setZoomFactor:(float)zoom {
	self.cameraZoomFactor = zoom;
}

- (void)dealloc {

	[[self captureSession] stopRunning];

	previewLayer = nil;
    captureSession = nil;
    stillImageOutput = nil;
    stillImage = nil;
}

@end
