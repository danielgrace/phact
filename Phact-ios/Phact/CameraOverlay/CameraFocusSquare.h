//
//  CameraFocusSquare.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 12/28/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraFocusSquare : UIImageView

- (id)initWithImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame;
- (void) setPos:(CGPoint) point;

@end
