//
//  PhilterCell.m
//  Phact
//
//  Created by Tigran Kirakosyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import "PhilterCell.h"

@implementation PhilterCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
/*	self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
*/ 
}

- (void)markItem {
	
	self.contentView.backgroundColor = self.backgColor;
	[UIView animateWithDuration:0.5 animations:^{
		self.contentView.backgroundColor = [UIColor colorWithRed:28/255.0 green:137/255.0 blue:215/255.0 alpha:1.0];
	} completion:^(BOOL finished){
		if(finished) [UIView animateWithDuration:0.5 animations:^{
			self.contentView.backgroundColor = self.backgColor;
		} completion:^(BOOL finished){
		}];
	}];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
	
	if(highlighted)
		self.contentView.backgroundColor = self.highlightColor;
	else
		self.contentView.backgroundColor = self.backgColor;
/*
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = 0.5;
    }
    else {
        self.alpha = 1.f;
    }
*/
    [self setNeedsDisplay];
}

@end
