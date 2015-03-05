//
//  UtilityButtonView.h
//  Phact
//
//  Created by Mikayel Gyurjyan on 1/29/14.
//  Copyright (c) 2014 BigBek. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SwipeTableViewCell;

@interface UtilityButtonTapGestureRecognizer : UITapGestureRecognizer

@property (nonatomic) NSUInteger buttonIndex;

@end


@interface UtilityButtonView : UIView

@property (nonatomic, strong) NSArray *utilityButtons;
@property (nonatomic) CGFloat utilityButtonWidth;
@property (nonatomic, weak) SwipeTableViewCell *parentCell;
@property (nonatomic) SEL utilityButtonSelector;
@property (nonatomic) CGFloat height;

- (id)initWithUtilityButtons:(NSArray *)utilityButtons parentCell:(SwipeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector;

- (id)initWithFrame:(CGRect)frame utilityButtons:(NSArray *)utilityButtons parentCell:(SwipeTableViewCell *)parentCell utilityButtonSelector:(SEL)utilityButtonSelector;

- (void)populateUtilityButtons;
- (CGFloat)utilityButtonsWidth;

@end
