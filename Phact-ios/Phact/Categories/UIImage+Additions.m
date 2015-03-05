//
//  UIImage+Additions.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (id)imageWithSize:(CGSize)size color:(UIColor *)color {
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[color set];
	CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)duplicateImageWithSize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
	[self drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)maskWithImage:(UIImage *)maskImage {
	CGImageRef maskRef = maskImage.CGImage;
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, NO);
	
	CGImageRef masked = CGImageCreateWithMask(self.CGImage, mask);
	CGImageRelease(mask);
	
	UIImage *maskedImage = [UIImage imageWithCGImage:masked scale:self.scale orientation:UIImageOrientationUp];
	
	CGImageRelease(masked);
	
	return maskedImage;
}

- (UIImage *)duplicateImageWithOverlayImage:(UIImage *)overlayImage {
	UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
	[self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
	[overlayImage drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

- (UIImage *)subImageWithRect:(CGRect)rect {
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.scale, self.scale);
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, CGRectApplyAffineTransform(rect, scaleTransform));
	UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
	CGImageRelease(imageRef);
	return result;
}

- (UIImage *)resizeImageWithInverseCapInsets:(UIEdgeInsets)insets toSize:(CGSize)size {
	UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
	
	CGSize insetUnit = CGSizeMake((insets.left + insets.right > 0) ? (size.width - (self.size.width - insets.left - insets.right)) / (insets.left + insets.right) : 0,
								  (insets.top + insets.bottom > 0) ? (size.height - (self.size.height - insets.top - insets.bottom)) / (insets.top + insets.bottom) : 0);
	UIEdgeInsets newInsets = UIEdgeInsetsMake(insets.top * insetUnit.height, insets.left * insetUnit.width,
											  insets.bottom * insetUnit.height, insets.right * insetUnit.width);
	
	CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.scale, self.scale);
	CGRect frame = CGRectMake(insets.left, insets.top, self.size.width - insets.left - insets.right, self.size.height - insets.top - insets.bottom);
	frame = CGRectApplyAffineTransform(frame, scaleTransform);
	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
	UIImage *fixedSubImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
	CGImageRelease(imageRef);
	frame = CGRectMake(newInsets.left, newInsets.top, size.width - newInsets.left - newInsets.right, size.height - newInsets.top - newInsets.bottom);
	[fixedSubImage drawInRect:frame];
	
	if (insets.left > 0) {
		CGRect frame = CGRectMake(0, 0, insets.left, self.size.height - insets.bottom);
		frame = CGRectApplyAffineTransform(frame, scaleTransform);
		imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
		UIImage *leftSubImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(imageRef);
		frame = CGRectMake(0, 0, newInsets.left, size.height - newInsets.bottom);
		[leftSubImage drawInRect:frame];
	}
	if (insets.top > 0) {
		CGRect frame = CGRectMake(insets.left, 0, self.size.width - insets.left, insets.top);
		frame = CGRectApplyAffineTransform(frame, scaleTransform);
		imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
		UIImage *topSubImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(imageRef);
		frame = CGRectMake(newInsets.left, 0, size.width - newInsets.left, newInsets.top);
		[topSubImage drawInRect:frame];
	}
	if (insets.right > 0) {
		CGRect frame = CGRectMake(self.size.width - insets.right, insets.top, insets.right, self.size.height - insets.top);
		frame = CGRectApplyAffineTransform(frame, scaleTransform);
		imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
		UIImage *rightSubImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(imageRef);
		frame = CGRectMake(size.width - newInsets.right, newInsets.top, newInsets.right, size.height - newInsets.top);
		[rightSubImage drawInRect:frame];
	}
	if (insets.bottom > 0) {
		CGRect frame = CGRectMake(0, self.size.height - insets.bottom, self.size.width - insets.right, insets.bottom);
		frame = CGRectApplyAffineTransform(frame, scaleTransform);
		imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
		UIImage *bottomSubImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
		CGImageRelease(imageRef);
		frame = CGRectMake(0, size.height - newInsets.bottom, size.width - newInsets.right, newInsets.bottom);
		[bottomSubImage drawInRect:frame];
	}
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
