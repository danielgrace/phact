//
//  UIImage+Additions.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/19/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

+ (id)imageWithSize:(CGSize)size color:(UIColor *)color;

- (UIImage *)duplicateImageWithSize:(CGSize)size;
- (UIImage *)maskWithImage:(UIImage *)maskImage;
- (UIImage *)duplicateImageWithOverlayImage:(UIImage *)overlayImage;
- (UIImage *)subImageWithRect:(CGRect)rect;
- (UIImage *)resizeImageWithInverseCapInsets:(UIEdgeInsets)insets toSize:(CGSize)size;

@end
