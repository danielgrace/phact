//
//  PhilterCell.h
//  Phact
//
//  Created by Tigran Kirakosyan on 11/14/13.
//  Copyright (c) 2013 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhilterCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *icon;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) UIColor *backgColor;
@property (strong, nonatomic) UIColor *highlightColor;

- (void)markItem;

@end
