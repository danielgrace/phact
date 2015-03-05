//
//  CustomTextField.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/12/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
	return [super textRectForBounds:CGRectInset( bounds , 10 , 0 )];
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [super editingRectForBounds:CGRectInset( bounds , 10 , 0 )];
}

@end
