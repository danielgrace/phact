//
//  FeedCell.m
//  Phact
//
//  Created by Tigran Kirakosyan on 1/20/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "FeedOutCell.h"

@implementation FeedOutCell

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
/*
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
	
	if(highlighted)
		self.contentView.backgroundColor = [UIColor lightGrayColor];
	else
		self.contentView.backgroundColor = [UIColor clearColor];
	
    [self setNeedsDisplay];
}
*/
@end
