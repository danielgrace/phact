//
//  ImageUtils.m
//  Phact
//
//  Created by Tigran Kirakosyan on 3/12/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "ImageUtils.h"
#import "UIImage+Resize.h"

@implementation ImageUtils

+ (UIImage *)mergedImageOfSize:(CGSize)size fromBackgroundImage:(UIImage *)backgroundImage andImage:(UIImage *)image withFrame:(CGRect)imageFrame {
        
	CGFloat scaleFactor = 1.0;

	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
	void *bitmapData;
	int bitmapByteCount;
	int bitmapBytesPerRow;
	
	bitmapBytesPerRow = (size.width * 4);
	bitmapByteCount = (bitmapBytesPerRow * size.height);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	bitmapData = calloc(bitmapByteCount, sizeof(unsigned char));
	if (bitmapData == NULL) {
        CGColorSpaceRelease(colorSpace);
		NSLog(@"Error: %@", @"Memory not allocated!");
		return nil;
	}
	context = CGBitmapContextCreate(bitmapData, size.width, size.height, 8, bitmapBytesPerRow, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
	if (context == NULL) {
		free(bitmapData);
        CGColorSpaceRelease(colorSpace);
		NSLog(@"Error: %@", @"Context not created!");
		return nil;
	}
	CGColorSpaceRelease(colorSpace);
	CGContextScaleCTM(context, scaleFactor, scaleFactor);
    
	CGRect frame = CGRectMake(0, 0, size.width, size.height);
    
    CGContextDrawImage(context, frame, backgroundImage.CGImage);    
    
    imageFrame.origin.y = size.height - imageFrame.size.height - imageFrame.origin.y;
    
    CGContextDrawImage(context, imageFrame, image.CGImage);
    
	CGImageRef resultCGImage = CGBitmapContextCreateImage(context);
	UIImage *resultImage = [UIImage imageWithCGImage:resultCGImage scale:scaleFactor orientation:UIImageOrientationUp];
	
	free(bitmapData);
	CGContextRelease(context);
///	free(bitmapData);
	CGImageRelease(resultCGImage);

	return resultImage;
}


+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize quality:(CGInterpolationQuality)quality {
    UIImage *scaledImage = nil;
    float width = newSize.width;
    float height = newSize.height;
    CGSize size1 = image.size;
    if( size1.width > width || size1.height > height ) {
        CGSize size = image.size;
        if(size.width > size.height) {
            size1 = CGSizeMake((size.width/size.height)*size1.height,size1.height);
        }
        else {
            size1 = CGSizeMake(size1.width,(size.height/size.width)*size1.width);
        }
        
        if(size1.width > width) {
            size1 = CGSizeMake((width/size1.width)*size1.width,(width/size1.width)*size1.height);
        }
        if(size1.height > height) {
            size1 = CGSizeMake((height/size1.height)*size1.width,(height/size1.height)*size1.height);
        }
        
        scaledImage = [image resizedImage:size1 interpolationQuality:quality];
    }
    else {
        scaledImage = image;
    }
    return scaledImage;
}

+ (UIImage *)normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
