//
//  DimView.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "DimView.h"

@implementation DimView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if ([self.delegate respondsToSelector:@selector(dimView:pointInside:withEvent:)]) {
		return [self.delegate dimView:self pointInside:point withEvent:event];
	} else {
		return [super pointInside:point withEvent:event];
	}
}

@end
