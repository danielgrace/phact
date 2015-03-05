//
//  DimView.h
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DimViewDelegate;

@interface DimView : UIView

@property (weak, nonatomic) IBOutlet id<DimViewDelegate> delegate;

@end

@protocol DimViewDelegate <NSObject>

- (BOOL)dimView:(DimView *)view pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end