//
//  PhactCell.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 2/10/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhactCell;

@protocol CellDelegate

- (void)deleteButtonClick:(PhactCell *)cell;
- (void)activateDeletionMode:(PhactCell *)cell;

@end

@interface PhactCell : UICollectionViewCell

@property (weak , nonatomic) id<CellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *phactImage;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UIButton *colorButton1;
@property (weak, nonatomic) IBOutlet UIButton *colorButton2;
@property (weak, nonatomic) IBOutlet UIButton *colorButton3;
@property (weak, nonatomic) IBOutlet UIButton *colorButton4;
@property (weak, nonatomic) IBOutlet UIButton *colorButton5;

@end
