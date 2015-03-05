//
//  ImageUtils.h
//  Phact
//
//  Created by Tigran Kirakosyan on 3/12/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage *)mergedImageOfSize:(CGSize)size fromBackgroundImage:(UIImage *)backgroundImage andImage:(UIImage *)image withFrame:(CGRect)imageFrame;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize quality:(CGInterpolationQuality)quality;
+ (UIImage *)normalizedImage:(UIImage *)image;

@end
