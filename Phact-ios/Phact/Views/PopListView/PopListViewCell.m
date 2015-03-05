//
//  PopListViewCell.m
//  Phact
//
//  Created by Tigran Kirakosyan on 2/6/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import "PopListViewCell.h"

@implementation PopListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
		
		_label = [[UILabel alloc] init];
        _label.backgroundColor = [UIColor clearColor];
		_label.textAlignment = NSTextAlignmentLeft;
		_label.font = [UIFont fontWithName:@"NewsGothicBT-Light" size:16.0];
        _label.textColor = [UIColor colorWithRed:43/255.0 green:43/255.0 blue:43/255.0 alpha:1.0];
		_icon = [[UIView alloc] init];
		[self.contentView addSubview:_label];
		[self.contentView addSubview:_icon];
		
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	
	CGRect contentRect = self.contentView.bounds;
	CGFloat boundsX = contentRect.origin.x;
	self.icon.frame = CGRectMake(boundsX + 18, 10, 30, 30);
	self.label.frame = CGRectMake(boundsX + 66, 10, 140, 30);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
